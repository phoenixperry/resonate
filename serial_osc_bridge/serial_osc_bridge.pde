import oscP5.*;
import netP5.*;
import processing.serial.*; 
Serial myPort; //let's get that data flowing out of arudio to processing by 
//going to the the serial port and seeing what's there! 

//this stuff is the OSC code from processing to Wekinator 
OscP5 oscP5;
NetAddress myRemoteLocation;

int receiveAtPort = 12000; //get the info  back from wekinator 
int sendToPort= 6448;   //send info to wekinator 
float numFromWekinator = 0; 
int lf = 10;    // Linefeed in ASCII.  
float num =0.0;  //this variable holds the change for the sensor 
String myString = null; //all data from arduino 


void setup() {
  size(650,650);
  frameRate(25);

  /* start oscP5, listening for incoming messages at receiveAtPort address, 9000 */
  oscP5 = new OscP5(this,receiveAtPort);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress("127.0.0.1", sendToPort);

  //let's list the serial ports we have 
  println(Serial.list()); 

  myPort = new Serial(this, "/dev/cu.usbmodem1421",9600); //pick the right port and
  //set the speed were' going to check the port at. If you ever see just noise in the arduino serial montior
  // output window, check to make sure the port speed matches the arduino sketch settings too. 
  //Other common effups are to not have the arduino serial monitor closed when trying to read it on 
  //processing. if you do this processing can't get the data b/c the window already has locked onto the port 
}


void draw() {

  background(0); //because my soul is black bwahahahah... 
  while (myPort.available() > 0) { //hey while there's data at the port 
    myString = myPort.readStringUntil(lf); //read it until you hit the end of the line. 
    
    //and save it into the myString variable 
    if (myString != null) { //if we did that successfully 
    //print(myString);  // Prints String 
    num=float(myString);  // Converts and prints int
   // println(num); //prints coverted data as a number verses as a word. 
    }
  }
  myPort.clear(); // clean up the port so it's ready for new data  
 
  //set up a new message 
  OscMessage myMessage = new OscMessage("/processing_output/");
  //add the sensor value to it 
  myMessage.add(num);
  //sling it like a fry cook over to wekinator 
  oscP5.send(myMessage, myRemoteLocation); 
  //sometimes it's useful to see what you're sending. uncomment for that. 
  //if you just print it, you'll see if you're sending and i or an f or a s but that's just
  //short hand for the type of data. To see the actual values, you'll need this function. 
  //println(myMessage.arguments()); 

  //let's just make sure our LED is off in arduino. spoilers, this is how to send 
  //serial from processing back to arduino. :) 
  sendSerial('0'); 
  
   fill(255); 
   ellipse(width/2, height/2, numFromWekinator*300, numFromWekinator*300); 
}

//you could also do this on an event like mousePressed 
void mousePressed() {
  /* in the following different ways of creating osc messages are shown by example */
  OscMessage myMessage = new OscMessage("/processing_output/");
  
  myMessage.add(num); /* add an int to the osc message */
  //myMessage.add(12.34); /* add a float to the osc message */
  // myMessage.add("some text"); /* add a string to the osc message */
  // myMessage.add(new byte[] {0x00, 0x01, 0x10, 0x20}); /* add a byte blob to the osc message */
  // myMessage.add(new int[] {1,2,3,4}); /* add an int array to the osc message */

  /* send the message */
  oscP5.send(myMessage, myRemoteLocation); 
  println(myMessage.arguments());

  //now let's go the other way back to arduino 
  sendSerial('1'); 
}


/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
  Object[] vals = theOscMessage.arguments(); 
  numFromWekinator = (Float)vals[0]; 
  println(numFromWekinator, "I am the osc val from wekinator"); 
 
}

//I just made up this function - it's not special. It's a multi-purose sender 
void sendSerial(char valueToSend){
  myPort.write(valueToSend);          
  
} 
void stop(){
  myPort.stop(); 
  
  oscP5.stop(); 
  
  
} 