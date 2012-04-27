#include <Max3421e.h>
#include <Usb.h>
#include <AndroidAccessory.h>
#include <SoftwareSerial.h>

// accessory descriptor. It's how Arduino identifies itself to Android
char applicationName[] = "Printer"; //the app on your phone
char accessoryName[] = "Mega_ADK"; // your Arduino board
char companyName[] = "Techbelly";

// make up anything you want for these
char versionNumber[] = "1.0";
char serialNumber[] = "1";
char url[] = "http://github.com/techbelly/printer-adk"; // the URL of your app online

// led variables
const byte printer_TX_Pin = 7; // this is the yellow wire
const byte printer_RX_Pin = 6; // this is the green wire

int timer;

// initialize the accessory:
AndroidAccessory usb(companyName, applicationName,
accessoryName,versionNumber,url,serialNumber);

SoftwareSerial *printer;
#define PRINTER_WRITE(b) printer->write(b)



void initPrinter() {
  printer = new SoftwareSerial(printer_RX_Pin, printer_TX_Pin);
  printer->begin(19200);
}

void setup() {
  Serial.begin( 9600 );
  initPrinter();
  usb.powerOn();
}

void loop() {
  byte msg[255];
  /* Print to usb */
  if(millis()-timer>1000) { // sending 10 times per second
    if (usb.isConnected()) { // isConnected makes sure the USB connection is ope
      while (usb.available()) {
        int val = usb.read();
        PRINTER_WRITE(val);
      }
    } else {
      Serial.println( "Waiting for connection");
    }
    timer = millis();
  }
}









