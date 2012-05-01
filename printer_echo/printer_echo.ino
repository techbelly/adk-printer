#include <Max3421e.h>
#include <Usb.h>
#include <AndroidAccessory.h>
#include <SoftwareSerial.h>
#include <SPI.h>
#include "rfid.h"

char applicationName[] = "Printer"; 
char accessoryName[]   = "Mega_ADK"; 
char companyName[]     = "Techbelly";
char versionNumber[]   = "1.0";
char serialNumber[]    = "1";
char url[] = "http://github.com/techbelly/printer-adk"; 
AndroidAccessory android(companyName, applicationName,accessoryName,versionNumber,url,serialNumber);

const byte printer_TX_Pin = 7; // this is the yellow wire
const byte printer_RX_Pin = 6; // this is the green wire

SoftwareSerial *printer;
#define PRINTER_WRITE(b) printer->write(b)

void initPrinter() {
  printer = new SoftwareSerial(printer_RX_Pin, printer_TX_Pin);
  printer->begin(19200);
}

void initAndroid() {
  android.powerOn();
}

void initRFID() {
  SPI.begin();
  pinMode(chipSelectPin,OUTPUT);              
  pinMode(NRSTPD,OUTPUT);               

  MFRC522_Init();  
}

void setup() {
  Serial.begin( 9600 );
  initPrinter();
  initAndroid();
  initRFID();
}

void readToPrinter() {
  if (android.isConnected()) { 
      while (android.available()) {
        int val = android.read();
        PRINTER_WRITE(val);
      }
    } 
}

uchar serNum[16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
uchar status;
uchar str[MAX_LEN] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
uchar x[2] = {0,0};

String s = "";

void writeFromRFID() {

  status = MFRC522_Request(PICC_REQIDL, str);	  
 
  if (status == MI_OK) { 
      Serial.println("Found a card ");
      Serial.print(str[0],HEX);
      Serial.print(" , ");
      Serial.print(str[1],HEX);
      Serial.println(" ");
      delay(200);
      status = MFRC522_Anticoll(str);

      MFRC522_Halt();	
      if (status == MI_OK) {
        memcpy(serNum, str, 5);

      
      for(int i=0;i<5;i++) {
        uchar d = serNum[i];
        Serial.println(d);
        if (d == 0) {
          s = s + "0";
        }
        if (d < 16) {
          s = s + "0";
        }
        s = s + String(d,HEX);
      }
      Serial.println(s);

      for(int i=0;i<s.length();i++) {
        x[0] = s.charAt(i);
        if (android.isConnected()) { 
          android.write((char)x[0]);
        }
        Serial.println("Writing");
        Serial.println((char)x[0]);
      }
      if (android.isConnected()) { 
         android.write('\n');
      }
    }

    s = "";
  }	
}

void loop() {
 readToPrinter();
 writeFromRFID();
 delay(500);
}


