import cc.arduino.*;
import processing.net.*;

Client client;
String data;

ArduinoAdkUsb arduino;

boolean touch = false;

String printerId = "BEBEBEBE";
String printerType = "A2-raw";

void setup() {
  
  arduino = new ArduinoAdkUsb( this );

  if ( arduino.list() != null )
    arduino.connect( arduino.list()[0] );

  /* Lock PORTRAIT view */
  orientation( PORTRAIT );
  downloadData();
}

void draw() {
  connected( arduino.isConnected() );
  
  if (client.available() > 0) {
    parseData();
  }
  
  if (arduino.isConnected()) {
    downloadData();
    delay(1000);    
  }
}



void downloadData() {
  client= new Client(this,"printer.gofreerange.com",80); 
  client.write("GET "); client.write("/printer/"); client.write(printerId); client.write(" HTTP/1.0\r\n");
  client.write("Host: printer.gofreerange.com:80\r\n");
  client.write("Accept: application/vnd.freerange.printer."); client.write(printerType); client.write("\r\n");
  client.write("\r\n");
  println("Trying to download data");
}

void parseData() {
  println("Trying to parse data");

  boolean parsingHeader = true;
  int interest_piqued = 0;
  
  while(client.available() > 0) {
      if (parsingHeader) {
          char c = client.readChar();
          if (interest_piqued == 0) {
            if (c == '\n') {
              interest_piqued = 1;
            }
          } else if (interest_piqued == 1) {
            if (c == '\r') {
              interest_piqued = 2;
            } else {
              interest_piqued = 0;
            }
          } else if (interest_piqued == 2) {
            if (c == '\n') {
               parsingHeader = false;
            }
          }
       } else {
          arduino.write((byte)client.read());
        }
      }
    client.stop();
}

void onStop() {
  finish();
}

void connected( boolean state ) {
  pushMatrix();
  translate( 20, 20 );
  if ( state )
    fill( 0, 255, 0 );
  else
    fill( 255, 0, 0 );
  rect( 0, 0, 30, 30 );
  popMatrix();
}


