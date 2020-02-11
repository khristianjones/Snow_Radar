%MATLAB Code from Sensor Array Analyzer App

%Generated by MATLAB 9.5 and Phased Array System Toolbox 4.0

%Generated on 12-Nov-2019 13:11:57

% Create a uniform circular array
h = phased.UCA;
h.NumElements = 100;
h.Radius = 1;
h.ArrayNormal = 'z';
%Calculate Taper
wind = ones(1,100);
h.Taper = wind;
%Create Isotropic Antenna Element
el = phased.IsotropicAntennaElement;
h.Element = el;
%Assign frequencies and propagation speed
F = 300000000;
PS = 300000000;
%Create figure, panel, and axes
fig = figure;
panel = uipanel('Parent',fig);
hAxes = axes('Parent',panel,'Color','none');
viewArray(h,'AxesHandle',hAxes,'ShowNormals',false,'ShowIndex','None');
view(hAxes,[0 90]);
