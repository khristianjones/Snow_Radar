This turntable runs off a stepper motor. You will need to download Arduino to run it.

If you already have Arduino added, skip to step 3.

1. To download Arduino, go to https://www.arduino.cc/en/Main/Software 
and download the version corresponding to your operating system
(i.e. Windows, Mac OS X, etc). Follow the instructions to Download and Install Arduino onto your
computer. Open Arduino. 

2. Next, you will need to make sure the AccelStepper library is added.

	a) In Arduino, click "Tools" >> "Include Library", and look through the list to see if
	AccelStepper is added. If it is listed, skip to step 3.

	b) To download AccelStepper, go to https://www.arduinolibraries.info/libraries/accel-stepper
	and download the latest version of the library.

	c) In Arduino, click "Sketch" >> "Include Library" >> "Add .ZIP Library..."

	d) Browse through your files to the location you saved the AccelStepper Library.

	e) Click on the AccelStepper .zip file you downloaded in step a.

3. Click on the folder within the folder "Turntable" titled "Turntable Code". Open the INO file
 "Turntable Code" in Arduino.

4. The script is very easy to edit. You will be able to select the rotational speed of the turntable
in RPM and the number of rotations you want. These are the only two numbers you will need to change.

	You will see the following lines of code in a large blank space in the script.
 
		/////////
		/////////
		float rpm = 1;
		float revolutions = -.25;
		/////////
		/////////

	The preceding code will run the turntable at a speed of 1 rotation per minute, 
	and will run the table CCW 1/4 of a rotation. To make the turntable run CW, enter a positive
	number in the "revolutions" line. Choose these numbers based on your application. 

		NOTE: 	Do NOT run the turntable over 10 RPM.
			Use only decimals integers. 
			rpm must always be a positive number.
			leave the semi-colons at the end of each line.

5. Connect the grey motor cord to the Stepper motor located below the turntable. Make sure you plug 
in the motor so that the colors are matching (green-green, red-red, etc).

6. Plug in the AC Power cord into the wall. 

7. Connect the USB port into your computer's USB output.

5. Before running:
	a) click "Tools" in the toolbar and make sure "Board: 'Arduino/Genuino Uno'" is chosen.
	b) Also in "Tools" make sure the correct port is chosen.

6. In the upper left hand corner, click "Verify".

7. In the upper left hand corner, click "Upload".

8. Wait about 5 seconds and the turntable will begin rotating.

9. If you need different speeds or number of rotations, change the values in the script.  

NOTE: If you need to quickly stop the turntable, unplug the AC Power cord from the wall. This will
cut the power supply and will immediately stop the motor from turning. 
