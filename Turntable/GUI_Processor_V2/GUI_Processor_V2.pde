/*------------------------------------------------------------------------------------
Graphic Interface for Using the Stepper motor for the SUB Zero Lab
Discription in applet itself

Khristian Jones, 2019 
   
------------------------------------------------------------------------------------*/
import controlP5.*;
import processing.serial.*;

Serial serial_port = null;        // the serial port

// serial port buttons
Button btn_serial_up;              // move up through the serial port list
Button btn_serial_dn;              // move down through the serial port list
Button btn_serial_connect;         // connect to the selected serial port
Button btn_serial_disconnect;      // disconnect from the serial port
Button btn_serial_list_refresh;    // refresh the serial port list
String serial_list;                // list of serial ports
int serial_list_index = 0;         // currently selected serial port 
int num_serial_ports = 0;          // number of serial ports in the list
int Set_Rev=1;
int Set_RPM=1;
boolean run=false;
boolean is_connected=false;

String s = new String("1. Plug in power supply. A green LED should be flashing 3 times. If not, unplug and replug in power supply cable");
String s2=s+"\n2. Plug in blue Serial Port cable. Click refresh button";
String s3=s2+"\n3. Use up and down arrows to select a port. If using Windows, the device will be listed under COM";
String s4=s3+" If using Linux, the device will be listed as ACM+#. Press the connect button. The green connect indicator should be lit";
String s5=s4+"\n4. Select input parameters. Press Run";
String s6=s5+"\n5. Either wait for motor to finish spinningor press OFF button. Press disconnect button and exit window";


ControlP5 cp5;
PFont font;
PFont font2;

void setup() {
  // set the window size
  size (640, 480);
  
  // create the buttons
  btn_serial_up = new Button("^", 140, 10, 40, 20);
  btn_serial_dn = new Button("v", 140, 50, 40, 20);
  btn_serial_connect = new Button("Connect", 190, 10, 100, 25);
  btn_serial_disconnect = new Button("Disconnect", 190, 45, 100, 25);
  btn_serial_list_refresh = new Button("Refresh", 190, 80, 100, 25);
  
  // get the list of serial ports on the computer
  serial_list = Serial.list()[serial_list_index];
  
  //println(Serial.list());
  //println(Serial.list().length);
  
  // get the number of serial ports in the list
  num_serial_ports = Serial.list().length;
  
   cp5 = new ControlP5(this);
  font = createFont("calibri light bold", 18); 
  font2= createFont("Serif", 12, false);// custom fonts for buttons and title
  
  cp5.addSlider("Set_RPM")     //Sets number of Revolutions per minute
    .setPosition(310, 10)  //x and y coordinates of upper left corner of button
    .setSize(100, 25)      //(width, height)
    .setFont(font)
    .setRange(1,3)
    .setNumberOfTickMarks(3)
  ;   

  cp5.addSlider("Set_Rev")     //"Sets number of Revolutions
    .setPosition(310, 50)  //x and y coordinates of upper left corner of button
    .setSize(100, 25)      //(width, height)
    .setFont(font)
    .setRange(1,9)
    .setNumberOfTickMarks(9)
  ;

  cp5.addButton("Run")     //Run button
    .setPosition(310, 90)  //x and y coordinates of upper left corner of button
    .setSize(100, 25)      //(width, height)
    .setFont(font)
  ;
  
  cp5.addButton("Off")     //
    .setPosition(310, 130)  //x and y coordinates of upper left corner of button
    .setSize(100, 25)      //(width, height)
    .setFont(font);
  
  
  
}

void mousePressed() {
  // up button clicked
  if (btn_serial_up.MouseIsOver()) {
    if (serial_list_index > 0) {
      // move one position up in the list of serial ports
      serial_list_index--;
      serial_list = Serial.list()[serial_list_index];
    }
  }
  // down button clicked
  if (btn_serial_dn.MouseIsOver()) {
    if (serial_list_index < (num_serial_ports - 1)) {
      // move one position down in the list of serial ports
      serial_list_index++;
      serial_list = Serial.list()[serial_list_index];
    }
  }
  // Connect button clicked
  if (btn_serial_connect.MouseIsOver()) {
    if (serial_port == null) {
      // connect to the selected serial port
      serial_port = new Serial(this, Serial.list()[serial_list_index], 9600);
      is_connected=true;
    }
  }
  // Disconnect button clicked
  if (btn_serial_disconnect.MouseIsOver()) {
    if (serial_port != null) {
      // disconnect from the serial port
      serial_port.stop();
      serial_port = null;
      is_connected=false;
    }
  }
  // Refresh button clicked
  if (btn_serial_list_refresh.MouseIsOver()) {
    // get the serial port list and length of the list
    serial_list = Serial.list()[serial_list_index];
    num_serial_ports = Serial.list().length;
  }
}

void draw() {
  // draw the buttons in the application window
  btn_serial_up.Draw();
  btn_serial_dn.Draw();
  btn_serial_connect.Draw();
  btn_serial_disconnect.Draw();
  btn_serial_list_refresh.Draw();
  // draw the text box containing the selected serial port
  DrawTextBox("Select Port", serial_list, 10, 10, 120, 60);
  if(is_connected==false){
    fill(255, 0, 0);
    rect(10, 70, 120, 60);
    textAlign(LEFT);
    textSize(14);
    fill(0);
    text("Not Connected", 20, 90, 110, 50);
  }
  else{
    fill(0, 255, 0);
    rect(10, 70, 120, 60);
    textAlign(LEFT);
    textSize(14);
    fill(0);
    text("Connected", 20, 90, 110, 50);
  }

  
  textSize(16);
  fill(0);
  text(s6, 5, 200, 600, 200);
}


// function for drawing a text box with title and contents
void DrawTextBox(String title, String str, int x, int y, int w, int h)
{
  fill(255);
  rect(x, y, w, h);
  fill(0);
  textAlign(LEFT);
  textSize(14);
  text(title, x + 10, y + 10, w - 20, 20);
  textSize(12);  
  text(str, x + 10, y + 40, w - 20, h - 10);
}

// button class used for all buttons
class Button {
  String label;
  float x;    // top left corner x position
  float y;    // top left corner y position
  float w;    // width of button
  float h;    // height of button
  
  // constructor
  Button(String labelB, float xpos, float ypos, float widthB, float heightB) {
    label = labelB;
    x = xpos;
    y = ypos;
    w = widthB;
    h = heightB;
  }
  
  // draw the button in the window
  void Draw() {
    fill(218);
    stroke(141);
    rect(x, y, w, h, 10);
    textAlign(CENTER, CENTER);
    fill(0);
    text(label, x + (w / 2), y + (h / 2));
  }
  
  // returns true if the mouse cursor is over the button
  boolean MouseIsOver() {
    if (mouseX > x && mouseX < (x + w) && mouseY > y && mouseY < (y + h)) {
      return true;
    }
    return false;
  }
}

void Run(){
  serial_port.write(Set_RPM+"a");
  delay(500);
  serial_port.write(Set_Rev+"b");
  delay(500);
  serial_port.write('r');
  delay(500);
  run=true;
  println("run");
}

void Off(){
  serial_port.write('f');
}
