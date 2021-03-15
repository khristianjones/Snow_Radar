import controlP5.*; //import ControlP5 library
import processing.serial.*;

int Set_Rev=1;
int Set_RPM=1;
boolean run=false;
String x;
int num_ports;
boolean device_detected=false;
String[] port_list;
String detected_port = "";

Serial port;

ControlP5 cp5; //create ControlP5 object
PFont font;

void setup(){ //same as arduino program

  size(600, 600);    //window size, (width, height)
  
  printArray(Serial.list());   //prints all available serial ports
  num_ports=Serial.list().length;
  port_list = new String[num_ports];
  for (int i=0; i<num_ports; i++){
     port_list[i]=Serial.list()[i];
  }

  
  port = new Serial(this, "/dev/ttyACM0", 9600);  //i have connected arduino to com3, it would be different in linux and mac os
  
  //lets add buton to empty window
  
  cp5 = new ControlP5(this);
  font = createFont("calibri light bold", 18);    // custom fonts for buttons and title
  
  cp5.addSlider("Set_RPM")     //Sets number of Revolutions per minute
    .setPosition(200, 150)  //x and y coordinates of upper left corner of button
    .setSize(120, 70)      //(width, height)
    .setFont(font)
    .setRange(1,3)
    .setNumberOfTickMarks(3)
  ;   

  cp5.addSlider("Set_Rev")     //"Sets number of Revolutions
    .setPosition(200, 250)  //x and y coordinates of upper left corner of button
    .setSize(120, 70)      //(width, height)
    .setFont(font)
    .setRange(1,10)
    .setNumberOfTickMarks(10)
  ;

  cp5.addButton("Run")     //Run button
    .setPosition(200, 350)  //x and y coordinates of upper left corner of button
    .setSize(120, 70)      //(width, height)
    .setFont(font)
  ;
  
  cp5.addButton("alloff")     //
    .setPosition(200, 450)  //x and y coordinates of upper left corner of button
    .setSize(120, 70)      //(width, height)
    .setFont(font)
  ;
}

void draw(){  //same as loop in arduino
  background(0); // background color of window (r, g, b) or (0 to 255)
  
  //lets give title to our window
  fill(0, 255, 0);               //text color (r, g, b)
  textFont(font);
  text("TURN TABLE Control", 70, 30);  // ("text", x coordinate, y coordinat)

  

  
}



//lets add some functions to our buttons
//so whe you press any button, it sends perticular char over serial port

void Connect(){
  port = new Serial(this, detected_port, 9600);
}


void Run(){
  port.write(Set_RPM+"a");
  delay(500);
  port.write(Set_Rev+"b");
  delay(500);
  port.write('r');
  delay(500);
  run=true;
  println("run");
}

void alloff(){
  port.write('f');
}
