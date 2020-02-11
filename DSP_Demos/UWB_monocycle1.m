%UWB_monocycle.m
%This m-file displays the time waveform for the Gaussian pulse function and the 
%first and second derivatives of the Gaussian pulse function for a 0.5
%nanosecond pulse width. Other values of pulse widths may be used by
%changing fs,t,t1. The program uses the actual first and second derivative
%equations for the Gaussian pulse waveforms. The first derivative is
%considered to be the monocycle or monopulse as discussed in most papers.
%The second derivative is the waveform generated from a dipole antenna used in a UWB
%system in the far field and should be the shape of the templet(unmodulated) used for
%correlation at the UWB receiver.[2] 
%The transfer function for a dipole is approx.
%(1/R)*(sqrt(nzero/Rrad))*(sqrt(3/8*pi))*s^2*L*C where s=jW.[1]
%The frequency domain spectrums can be shown by doing FFT routines on the
%waveforms. This m file does not require any toolboxes to run. There should
%be enough infomation here to design and fully simulate a complete modulated UWB
%system including antennas at any frequency band such as (<960MHz and
%3.1~10.6GHz).A good demo of a see thru the wall UWB system operating below
%960MHz is shown at www.UWB.org.
%[1]S. Wang,"Modeling Omnidirectional Small Antennas for UWB Applications"
%[2]S. Yoshizumi,"All Digital Transmitter Scheme and Transciever Design for
%Pulse Based UWB Radio"
%[3]Larry Fullerton, Patent #'s 4743906,6549567
%[4]Picosecond Pulse Labs App. Notes 9,14a
fs=20E9;%sample rate-10 times the highest frequency
ts=1/fs;%sample period
t=[(-4E-9-ts):ts:(4E-9-ts)];%vector with sample instants
t1=.5E-9;%pulse width(0.5 nanoseconds)
x=(t/t1).*(t/t1);%x=(t^2/t1^2)(square of (t/t1)
A=1;%positive value gives negative going monopulse;neg value gives
   %positive going monopulse
y=(1/(sqrt(6.28)*t1))*exp(.5*(-x));%Gaussian pulse function   
figure(1)   
plot(1E9*t,1E-9*y)%multiply t and y to get proper scaling and normalizing 
xlabel('nanoseconds');ylabel('Amplitude');title('Gaussian pulse function')
grid on   
y=A*(t/t1).*exp(-x);%first derivative of Gaussian pulse function
figure(2)
plot(1E9*t,y)%multiply t by 1 nanosec to get nanosec instead of sec
xlabel('nanoseconds');ylabel('Amplitude');title('First derivative of Gaussianpulse function')
grid on
y=A*(1/(sqrt(6.28)*t1))*(1-x).*exp(.5*(-x));%second derivative of Gaussian pulse function
figure(3)
plot(1E9*t,1E-9*y)%multiply t by 1 nanosec to get nanosec instead of sec
xlabel('nanoseconds');ylabel('Amplitude');title('Second derivative of Gaussian pulse function')
grid on