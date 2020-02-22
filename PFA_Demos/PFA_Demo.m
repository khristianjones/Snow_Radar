


% This script generates simulated radar data for a circular SAR data
% collection, given a single point target. It then computes and plots the
% SAR image generated using the polar format algorithm (PFA). Finally, it
% overlays on the PFA image colored circles whos locii converge
% on the true target location, and colored lines representing the
% far-field approximation whos locii converge on the (warped)
% target signature position in the PFA image.
c = 299792458; % speed of light (m/s)
% Define sensor parameters here
sensor.BW = 8e8;
% Bandwidth (Hz)
sensor.Fc = 10e9;
% Center freq (Hz)
sensor.int_angle = 360;
% Integration Angle (degrees)

sensor.cent_angle = 0;
% Center Angle (degrees)
sensor.elev = 0;
% Elevation Angle (degrees)

sensor.R0 = 10;

% Range to sensor (m) from aimpoint at scene center
data.K = 2048;
% Number of frequency samples
data.Np = 4096;
% Number of pulses
% calculate max diameter Dmax of scene to avoid quadratic phase error
lambda = c/sensor.Fc; % wavelength
dTheta = (pi/180)*sensor.int_angle; % integration angle (radians)
Dmax =(lambda/dTheta)*sqrt(2*sensor.R0/lambda);
% position of point target
xt = .25; % greater than max allowable diameter
yt = .25;
% xt = -0.1+(Dmax/2)/sqrt(2); % easily within max allowable diameter
% yt = (Dmax/2)/sqrt(2);
zt = 0;
targPos = [xt yt zt; xt*2, yt*2, zt];
amp = [1 1]; % unit reflectance amplitude
N_targets = size(targPos,1); % number of point targets
% Calculate the frequency vector (Hz)
data.freq = linspace(sensor.Fc-sensor.BW/2,sensor.Fc+sensor.BW/2,data.K)';
% Calculate the azimuth angle of the sensor at each pulse
sensor.azim = linspace(sensor.cent_angle-sensor.int_angle/2, ...
sensor.cent_angle+sensor.int_angle/2,data.Np);
% Calculate the x,y,z position of the sensor at each pulse
[data.AntX,data.AntY,data.AntZ] = sph2cart(sensor.azim*pi/180,...
ones(1,data.Np)*sensor.elev*pi/180,ones(1,data.Np)*sensor.R0);
% Loop through each pulse to calculate the phase history data from the
% point target
figure(1)
plot(data.AntX, data.AntY);
hold on 
plot(targPos(1,1), targPos(1,2), '*g');
hold on
plot(targPos(2,1), targPos(2,2), '*r');
hold off

pause(0.1)
h = waitbar(0,'Calculate data from point targets...');
data.phdata = zeros(data.K,data.Np);
for ii = 1:length(sensor.azim)
waitbar(ii/length(sensor.azim),h)
% Initialize the vector which contains the phase history for this pulse
freqdata = zeros(data.K,1);
% Loop through each target
for kk = 1:N_targets
% Calculate the differential range to the target (m)
dR = sqrt((data.AntX(ii)-targPos(kk,1))^2+...
(data.AntY(ii)-targPos(kk,2))^2+...
(data.AntZ(ii)-targPos(kk,3))^2) - sensor.R0;
% Update the phase history for this pulse

freqdata = freqdata + amp(kk) * exp(-j*4*pi*dR/c*data.freq);
end
% Put the phase history into the data structure
data.phdata(:,ii) = freqdata;
end
close(h), pause(0.1)
% taper the data in frequency and pulse before reconstruction into an image
[Nr,Nc] = size(data.phdata);
winn = tukeywin(Nr,0.1)*tukeywin(Nc,0.1)';
data.phdata = winn.*data.phdata;
clear winn
% Calculate R0 for each pulse (m)
data.R0 = sensor.R0 * ones(size(data.AntX));
% Calculate the frequency step size (Hz)
data.deltaF = diff(data.freq(1:2));
% Calculate the minimum frequency (Hz)
data.minF = data.freq(1) * ones(size(data.AntX));
% SAR image formation using Polar Format Algorithm (PFA)
data = polarFormatAlgorithm(data);
% Display the SAR iamge
figure(2)
imagesc(data.xaxis,data.yaxis,20*log10(abs(data.im_final_PFA)./...
max(max(abs(data.im_final_PFA)))))
caxis([-30 0])
axis xy
title('PFA Image');
xlabel('x (m)');
ylabel('y (m)');
colorbar
set(gcf,'color','w')
% Overlay colored lines and circles that provide a graphical
% representation of far-field approximation that can be used to predict the
% warping and defocussing of a SAR image computed using PFA
%graphicalDemoFarFieldPfa(data.AntX,data.AntY,data.AntZ,xt,yt,zt);