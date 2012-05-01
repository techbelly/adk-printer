import cc.arduino.*;
import processing.net.*;

ArduinoAdkUsb arduino;
Reader reader;
String[] log;
int logline;

void log(String s) {
  log[logline] = s;
  logline = (logline + 1) % 5;
  if (arduino.isConnected()) {
    for(int i = 0; i < s.length(); i++) {
      arduino.write(s.charAt(i));
    }
    arduino.write('\n');
  }
}

class Reader extends Thread {
  
  int wait; 
  String id;
  PApplet app; 

  Reader (int w, PApplet a) {
    wait = w;
    id = "";
    app = a;
  }
  
  void run ()  {
    while (true) {
      if (arduino.isConnected()) {
         while (arduino.available() > 0) {
           char c = arduino.readChar();
           log("Reading data "+c);
           if (c == '\n') {
             Fetcher f = new Fetcher(id,app);
             f.start();
           } else {
             id = id + c;
           }
         } 
      }
       try {
        sleep((long)(wait));
      } catch (Exception e) {
      }
    }
  }
}

class Fetcher extends Thread {
 
 String id;
 Client client;
 PApplet app; 
 
 Fetcher(String s,PApplet a) {
   id = s;
   app = a;
 } 
 
 void downloadData() {
  client = new Client(app,"printer.gofreerange.com",80); 
  client.write("GET "); client.write("/printer/"); client.write(id); client.write(" HTTP/1.0\r\n");
  client.write("Host: printer.gofreerange.com:80\r\n");
  client.write("Accept: application/vnd.freerange.printer."); client.write("A2-raw"); client.write("\r\n");
  client.write("\r\n");
  log("Trying to download data");
  log("Printer id "+id);
 }
 
 void consumeHeader() {
   boolean parsingHeader = true;
   int interest_piqued = 0;
   while(client.available() > 0 && parsingHeader) {
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
   }
 }
 
 void run() {
   downloadData();
   while (client.available() == 0) {
      try {
        sleep(100);
      } catch (Exception e) {
      }
   }
   consumeHeader();
   while(client.available() > 0) {
     char c = client.readChar();
     arduino.write((byte)c);  
   }
   client.stop();
 }
}


void setup() {

  arduino = new ArduinoAdkUsb( this );
  log = new String[5];  
  
  if ( arduino.list() != null )
    arduino.connect( arduino.list()[0] );

  orientation( PORTRAIT );
  reader = new Reader(500,this);
  reader.start();
  log("Starting");
}

void draw() {
  connected( arduino.isConnected() );
  for(int i = 0; i < 5; i++) {
    if (log[i] != null) {
      text(log[i],20,i*50+100);
    }
  }
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


