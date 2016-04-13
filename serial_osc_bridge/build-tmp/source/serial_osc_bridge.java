import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class serial_osc_bridge extends PApplet {




 
Serial myPort; //let's get that data flowing out of arudio to processing by 
//going to the the serial port and seeing what's there! 


OscP5 oscP5;
NetAddress myRemoteLocation;

int receiveAtPort = 9000;
int sendToPort= 6448;  

int lf = 10;    // Linefeed in ASCII.  
float num =0.0f;  //this variable holds the change
String myString = null; //all data from arduino 


public void setup() {
  
  frameRate(25);

  /* start oscP5, listening for incoming messages at port 12000 */
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
  myPort = new Serial(this, "/dev/tty.usbmodem1411",9600); //pick the right port and
  //set the speed were' going to check the port at. If you ever see just noise in the arduino serial montior
  // output window, check to make sure the port speed matches the arduino sketch settings too. 
  //Other common effups are to not have the arduino serial monitor closed when trying to read it on 
  //processing. if you do this processing can't get the data b/c the window already has locked onto the port 
}


public void draw() {
  background(0); 
  while (myPort.available() > 0) { //hey while there's data at the port 
    myString = myPort.readStringUntil(lf); //read it until you hit the end of the line. 
    
    //and save it into the myString variable 
    if (myString != null) { //if we did that successfully 
    //print(myString);  // Prints String 
    num=PApplet.parseFloat(myString);  // Converts and prints int
    println(num); //prints coverted data as a number verses as a word. 
    }
  }
  myPort.clear(); // clean up the port so it's ready for new data  
 
  OscMessage myMessage = new OscMessage("/compass");
  myMessage.add(num);
  oscP5.send(myMessage, myRemoteLocation); 
  //println(myMessage.arguments());
}

public void mousePressed() {
  /* in the following different ways of creating osc messages are shown by example */
  OscMessage myMessage = new OscMessage("/compass");
  
  myMessage.add(num); /* add an int to the osc message */
  //myMessage.add(12.34); /* add a float to the osc message */
  // myMessage.add("some text"); /* add a string to the osc message */
  // myMessage.add(new byte[] {0x00, 0x01, 0x10, 0x20}); /* add a byte blob to the osc message */
  // myMessage.add(new int[] {1,2,3,4}); /* add an int array to the osc message */

  /* send the message */
  oscP5.send(myMessage, myRemoteLocation); 
  println(myMessage.arguments());
}


/* incoming osc message are forwarded to the oscEvent method. */
public void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}
  public void settings() {  size(400,400); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "serial_osc_bridge" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
