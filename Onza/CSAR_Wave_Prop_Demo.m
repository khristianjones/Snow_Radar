%MSU-SUBZERO LAB CSAR Experiment for simulating wave prop in Matlab enviroment
% @Khristian Jones 

% This code is for demonstrating a) Full wave propagation of our Onza
% wavepattern and b) Testing that the Polar Format Algorithim (PFA) will
% work for simulated data before moving to real life captured data 

% c -- Speed of light (m/s) 
c = 299792458; 

% Pulse Repitition Frequency (prf) -- pulses per second 
prf = 14294120; 

% sampling rate (samples per second) 
Fs = 2.3328e10; 

% range resoution (meters) 

resolution = 0.0064; 

% center frequency (Hz) 

fc = 7.29e9; 

% Sampling Rate (fs) 

Fs = 2.3328e+10;

% desired Range Resolution (meters) 
rangeResolution = 0.0064;  
crossRangeResolution = 0.0064;

bw =  c/(2*rangeResolution);


waveform = phased.('SampleRate',fs, 'PulseWidth', tpd, 'PRF', prf,...
    'SweepBandwidth', bw);
