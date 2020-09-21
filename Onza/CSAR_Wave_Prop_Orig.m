c = physconst('LightSpeed');

fc = 7.29e9;

rangeResolution = 6.6e-2;  
crossRangeResolution = 6.6e-2;
 
bw = c/(2*rangeResolution);

prf = 1000; 
aperture = 4;  
tpd = 3*10^-7; 
fs = 120*10^6;

waveform = phased.LinearFMWaveform('SampleRate',fs, 'PulseWidth', tpd, 'PRF', prf,...
    'SweepBandwidth', bw);


    
fs = 2.332800384e10;

speed = 1; 
flightDuration = 4;

time_dur = 60;
num_samples = 1000;
t = 0:time_dur/(num_samples-1):time_dur;

R0 = 3;

% Custom Data Path 
load('data.mat');
load('Cylinder_in_Center_in_Motion_17-Nov-2019_14-53.mat');
x_loc = R0*cos(1/time_dur*2*pi*t);
y_loc = R0*sin(1/time_dur*2*pi*t);
z_loc = zeros(1,num_samples);



wpts = [t' x_loc' y_loc' z_loc'];

radarPlatform = phased.Platform('MotionModel','Custom',...
    'CustomTrajectory', wpts);


numpulses = 1000;

% todo repalce truncrangesamples
truncrangesamples = 1536; 
fastTime = (0:1/fs:(truncrangesamples-1)/fs);
% Set the reference range for the cross-range processing.
Rc = 0;

antenna = phased.CosineAntennaElement('FrequencyRange', [1e9 11e9]);
antennaGain = aperture2gain(aperture,c/fc); 

transmitter = phased.Transmitter('PeakPower', 50e3, 'Gain', antennaGain);
radiator = phased.Radiator('Sensor', antenna,'OperatingFrequency', fc, 'PropagationSpeed', c);

collector = phased.Collector('Sensor', antenna, 'PropagationSpeed', c,'OperatingFrequency', fc);
receiver = phased.ReceiverPreamp('SampleRate', fs, 'NoiseFigure', 30);

channel = phased.FreeSpace('PropagationSpeed', c, 'OperatingFrequency', fc,'SampleRate', fs,...
    'TwoWayPropagation', true);
%% 
targetpos= [0,0,0; 0,1,0; 0,2,0; 0.4,0.5,0; 0.4,0.45,0; .25,1.25,0]'; 

targetvel = [0,0,0; 0,0,0; 0,0,0; 0,0,0; 0,0,0; 0,0,0]';



target = phased.RadarTarget('OperatingFrequency', fc, 'MeanRCS', [1,1,1,1,1,1]);
pointTargets = phased.Platform('InitialPosition', targetpos,'Velocity',targetvel);
%
% The figure below describes the ground truth based on the target
% locations.
figure(1);
h = axes;
for i = 1:size(targetpos,2)
 plot(targetpos(2,i),targetpos(1,i),'*g');
hold on;
end
set(h,'Ydir','reverse');
title('Ground Truth');
ylabel('Range');
xlabel('Cross-Range');

hold on;
plot(x_loc, y_loc);
hold off;
%% 
% Define the broadside angle
refangle = zeros(1,size(targetpos,2));
rxsig = zeros(truncrangesamples,numpulses);


slowTime = time_dur/num_samples;


for ii = 1:numpulses
    % Update radar platform and target position
    [radarpos, radarvel] = radarPlatform(slowTime);
    nn_radarpos(:,ii) = radarpos;
    nn_radarvel(:,ii) = radarvel;
    [targetpos,targetvel] = pointTargets(slowTime);
    
    % Get the range and angle to the point targets
    [targetRange, targetAngle] = rangeangle(targetpos, radarpos);
    
 
    % Generate the LFM pulse
    sig = waveform();
    % Use only the pulse length that will cover the targets.
    sig = sig(1:truncrangesamples);
    
    % Transmit the pulse
    sig = transmitter(sig);
    
    % Define no tilting of beam in azimuth direction
    targetAngle(1,:) = refangle;
    
    % Radiate the pulse towards the targets
    sig = radiator(sig, targetAngle);
    
    % Propagate the pulse to the point targets in free space
    sig = channel(sig, radarpos, targetpos, radarvel, targetvel);
    
    % Reflect the pulse off the targets
    sig = target(sig);
    
    % Collect the reflected pulses at the antenna
    sig = collector(sig, targetAngle);
    
    % Receive the signal  
    rxsig(:,ii) = receiver(sig);
    
    
    
end
pause(1);
figure(2);
imagesc(abs(rxsig));title('SAR Raw Data')
xlabel('Cross-Range Samples')
ylabel('Range Samples')

pulseCompression = phased.RangeResponse('RangeMethod', 'Matched filter', 'PropagationSpeed', c, 'SampleRate', fs);
matchingCoeff = getMatchedFilter(waveform);
[cdata, rnggrid] = pulseCompression(rxsig, matchingCoeff);
pause(1);
figure(3);
imagesc(abs(cdata));
title('SAR Range Compressed Data')
xlabel('Cross-Range Samples')
ylabel('Range Samples')

%% 
bpa_processed = helperBackProjection(cdata,rnggrid,fastTime,fc,fs,prf,speed,crossRangeResolution,c);



