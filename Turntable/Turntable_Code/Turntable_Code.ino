//#include <LiquidCrystal.h>
#include <AccelStepper.h>

//LiquidCrystal lcd(13, 12, 11, 10, 9, 8);
AccelStepper stepper(1, A4, A5);


boolean r = false;

/////////
/////////
float rpm = 2;
float revolutions = -1;
/////////
/////////



// Convert rpm to steps/sec
float vel = rpm * 200.0 / 60.0 * 100.0;
// Convert revolutions to # of steps
float posit = revolutions * 200.0 * 100.0;

void setup() {
  stepper.setMinPulseWidth(40);
  stepper.setCurrentPosition(0);
  stepper.setMaxSpeed(vel);
  stepper.moveTo(posit);
  stepper.setAcceleration(400);
  Serial.begin(9600);
  Serial.println("Ready");
}



void loop(){
  
   if(r==true){
   stepper.run();
   if(stepper.distanceToGo()==0){
    stepper.setCurrentPosition(0);
    r=false;
    Serial.print("Finished");
   }
   }

  
  static int v=0;
  if(Serial.available()){
    char val=Serial.read(); 
    switch(val){
      case '0'...'9':
         v=val-'0';
         Serial.println("Set");
         break;
      case 'a':
        vel=v*200.0/60.0*100.0;
        stepper.setMaxSpeed(vel);
        v=0;
        Serial.println(vel);
        break;
      case 'b':
        posit=v*200.0*100.0;
        stepper.moveTo(posit);
        v=0;
        Serial.println(posit);
        break;
      case 'r':
        r=true;
        break;
      case 'f':
        r=false;
        stepper.stop();
        Serial.println("Stopped");
        stepper.setCurrentPosition(0);
        break;
    }

    }
   
  }
