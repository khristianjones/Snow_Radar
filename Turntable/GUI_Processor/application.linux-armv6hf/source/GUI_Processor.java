import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class GUI_Processor extends PApplet {

 //import ControlP5 library


int Set_Rev=1;
int Set_RPM=1;
boolean run=false;
String x;

Serial port;

ControlP5 cp5; //create ControlP5 object
PFont font;

public void setup(){ //same as arduino program

      //window size, (width, height)
  
  printArray(Serial.list());   //prints all available serial ports
  
  port = new Serial(this, "/dev/ttyACM0", 9600);  //i have connected arduino to com3, it would be different in linux and mac os
  
  //lets add buton to empty window
  
  cp5 = new ControlP5(this);
  font = createFont("calibri light bold", 20);    // custom fonts for buttons and title
  
  cp5.addSlider("Set_RPM")     //Sets number of Revolutions per minute
    .setPosition(100, 50)  //x and y coordinates of upper left corner of button
    .setSize(120, 70)      //(width, height)
    .setFont(font)
    .setRange(1,3)
    .setNumberOfTickMarks(3)
  ;   

  cp5.addSlider("Set_Rev")     //"Sets number of Revolutions
    .setPosition(100, 150)  //x and y coordinates of upper left corner of button
    .setSize(120, 70)      //(width, height)
    .setFont(font)
    .setRange(1,10)
    .setNumberOfTickMarks(10)
  ;

  cp5.addButton("Run")     //Run button
    .setPosition(100, 250)  //x and y coordinates of upper left corner of button
    .setSize(120, 70)      //(width, height)
    .setFont(font)
  ;
  
  cp5.addButton("alloff")     //
    .setPosition(100, 350)  //x and y coordinates of upper left corner of button
    .setSize(120, 70)      //(width, height)
    .setFont(font)
  ;
}

public void draw(){  //same as loop in arduino
  background(150, 0 , 150); // background color of window (r, g, b) or (0 to 255)
  
  //lets give title to our window
  fill(0, 255, 0);               //text color (r, g, b)
  textFont(font);
  text("TURN TABLE Control", 70, 30);  // ("text", x coordinate, y coordinat)
  }




//lets add some functions to our buttons
//so whe you press any button, it sends perticular char over serial port


public void Run(){
  port.write(Set_RPM+"a");
  delay(500);
  port.write(Set_Rev+"b");
  delay(500);
  port.write('r');
  delay(500);
  run=true;
  println("run");
}

public void alloff(){
  port.write('f');
}
  public void settings() {  size(450, 450); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--stop-color=#cccccc", "GUI_Processor" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
