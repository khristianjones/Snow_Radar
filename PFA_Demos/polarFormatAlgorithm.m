function data = polarFormatAlgorithm(data);
% This Matlab function forms a SAR image using the Polar Format Algorithm
% (PFA). It uses the same input parameter ‘data’ structure used for the backprojection
% (BP) code given in Gorham, L., and Moore, L., “SAR image formation toolbox
% for Matlab,” Proc. SPIE 7699, 769906 (2010).
%
% PFA consists of mapping the phase history data to Fourier
% (kx,ky) space, then using the 2-dimensional Fourier Transform to convert
% from (kx,ky) space to SAR image (x,y) space, as described in Jakowatz
% "Spotlight-Mode Synthetic Aperture Radar: A Signal Processing Approach" (1996),
% chapter 3, and to Ross Deming’s 2014 SPIE paper “Polar format
% algorithm for SAR imaging with Matlab”.
%
% The following steps are performed:
% (1) Map each data sample to its appropriate (kx,ky) coordinate of the
% spatial Fourier transform of the object function according to Eq.(20)
% in the SPIE paper. The data samples lie on a "Keystone" pattern.
% (2) Interpolate the data from the "Keystone" pattern onto a rectangular
% grid in (kx,ky) space. Rather than performing a 2D interpolation, which
% is slow, a computationally efficient 2-stage interpolation is performed.
% (3) Apply the fast inverse Fourier Transform 'fft2' to the interpolated (kx,ky)
% space samples in order to compute the SAR image in (x,y) space.
%
% Note: in order to perform the efficient 2-statge interpolation, the
% coordinates frame is rotated such that the sensor position at mid_CPI
% lies on the positive x-axis, therefore the output SAR image also has this
% rotation.
%
% The following fields in the input structure 'data' need to be populated:
% data.deltaF: Step size of frequency data (Hz)
% data.minF: Vector containing the start frequency of each pulse (Hz)
% data.K: The number of frequency samples per pulse
% data.Np: The number of pulses in the CPI
% data.AntX: The x-position of the sensor at each pulse (m)
% data.AntY: The y-position of the sensor at each pulse (m)
% data.AntZ: The z-position of the sensor at each pulse (m)
% data.R0: The range to scene center (m)
% data.phdata: Phase history data (frequency domain)
%
%frequency sample in rows, slow time (pulse) in columns
% The outputs are:
% data.im_final_PFA: The image value at each pixel
% data.xaxis: The x-axis for the image
% data.yaxis: The y-axis for the image
%
% Written by Ross Deming, Solid State Scientific Corp.
% ross.deming@gmail.com
% 26 July 2013
%-----------------------------------------------------------------
% Define speed of light (m/s)
c = 299792458;
% Make sure the xy coordinates are rotated in such a way that the
% radar flight path is centered on the x-axis for the 2-stage interpolation
% to work optimally.
data = removeCenterAngleOffset(data);
% Define the boundaries of a rectangular box that will contain
% the keystone region defining the K-space
% coverage. Note, the x and y coordinate axes were rotated such
% that coverage is centered symmetrically on x-axis.
% Thus the minimum kx, and min/max ky, are calculated from the
% corners of the keystone region, so you can look at the first pulse.
% The maximum kx occurs at the top of the keystone arch, so you
% need to look at the middle pulse.
ip = 1; % first pulse
freqAx = data.minF(ip) + [0:data.K-1]*data.deltaF;
kaxis = 2*pi*freqAx/c;
s0x = data.AntX(ip)./data.R0(ip); % unit vectors in direction of sensor
s0y = data.AntY(ip)./data.R0(ip);
kx = 2*kaxis*s0x; % mapping of frequency samples to k-space (Fourier Diffraction Theorem)
ky = 2*kaxis*s0y;
kx_min = min(kx); % minimum kx coordinate that bounds the keystone region
ky_max = max(abs(ky)); % maximum ky coordinate that bounds the keystone region
ky_min = -ky_max; % minimum ky coordinate that bounds the keystone region
ip = round(data.Np/2); % middle pulse
freqAx = data.minF(ip) + [0:data.K-1]*data.deltaF;
kaxis = 2*pi*freqAx/c;
s0x = data.AntX(ip)./data.R0(ip); % unit vectors in direction of sensor
kx = 2*kaxis*s0x;
kx_max = max(kx); % maximum kx coordinate that bounds the keystone region
% Define a rectangular grid of kx and ky coordinates for the box that
% contains the keystone coverage region. The data will be interpolated
% onto this grid during PFA data reformatting. Note: overall number of
% samples in the rectangular grid will be the same as the number of samples
% in the phase history data. Because of the orientation of the flight
% path, which has been rotated to be ceneterd on the x-axis, therefore the
% number of kx samples in the grid will equal the number of frequency
% samples per pulse, and the number of ky samples in the grid will equal
% the number of pulses in the CPI.
Nx = data.K; % number of kx samples equals number of frequency samples
Ny = data.Np; % number of ky samples equals number of pulses
Kx = linspace(kx_min,kx_max,Nx); % kx coordinates for the rectangular grid
Ky = linspace(ky_min,ky_max,Ny); % ky coordinates for the rectangular grid
%--------------------------------------------------------------------
% Interpolate the data onto a regular grid using a two-step procedure,
% as illustrated in Figures 3.15 and 3.16 of Jakowatz’ book. Each step is a
% series of 1-dimensional interpolations. This 2-step process is more
% computationally efficient than performing a full 2-dimensional
% interpolation of the data onto the rectangular grid.
%--------------------------------------------------------------------
h = waitbar(0,'Running PFA...');
% Range interpolation onto keystone grid, Jakowatz p.134, Figure 3.15
for ip = 1:data.Np, % loop over pulses
% frequency axis is allowed to vary slightly with each pulse
% therefore data.minF can vary slightly with pulse (Gotcha radar)
freqAx = data.minF(ip) + [0:data.K-1]*data.deltaF;
% k-space mapping according to Fourier diffraction Theorem. Refer to
% the black circle markers in Figure 3.15
kaxis = 2*pi*freqAx/c;
s0x = data.AntX(ip)./data.R0(ip); % unit vectors in direction of sensor
s0y = data.AntY(ip)./data.R0(ip);
kx = 2*kaxis*s0x; % black circle coords
ky = 2*kaxis*s0y;
% k-space coordinates for the intermediate interpolation grid. Refer to
% the gray square markers in Figure 3.15
Kx_keystone = Kx; % want to place samples on the kx of the rectangular grid
Ky_keystone = Kx*ky(1)/kx(1); % ky values (gray squares) along radial lines
dat = data.phdata(:,ip);
datI = interp1(kx,dat,Kx_keystone);
data.phdata(:,ip) = datI;
end
data.phdata(isnan(data.phdata)==1)=0; % interpolation can leave some NaN samples
waitbar(1/3,h)
% Cross-range interpolation, Jakowatz p.135, Figure 3.16
for ik = 1:data.K, % loop over frequency samples
Ky_keystone = Kx(ik)*(data.AntY)./(data.AntX); % ky of gray squares in Figure 3.16
dat = data.phdata(ik,:);
datI = interp1(Ky_keystone,dat,Ky); % interp onto Ky values of rectangular grid
data.phdata(ik,:) = datI;
end
data.phdata(isnan(data.phdata)==1)=0; % interpolation can leave some NaN samples
waitbar(3/3,h)
%--------------------------------------------------------------------
% Form the SAR image
%--------------------------------------------------------------------
% PFA reconstruction of SAR image: use FFT to convert from (kx,ky) space
% to (x,y) imaging space
data.im_final_PFA = fftshift(fft2(fftshift(data.phdata)));
% rotate to orient with x and y axes for plotting
data.im_final_PFA = data.im_final_PFA.';
% The x and y axes of the image are dictated by the layout of the kx
% and ky samples in the k-space rectangular grid, together with the standard
% operation and definition of Matlab's 'fft2' function. Note, there will be
% different resolution in x vs. y, depending on the shape
% of the K-space coverage. Also the x and y coordinate axes have been rotated
% to center the sensor path at mid-CPI with the positive x-axis.
dKx = mean(diff(Kx));
dKy = mean(diff(Ky));
dx = 2*pi/(Nx*dKx);
dy = 2*pi/(Ny*dKy);
data.xaxis = [0:Nx-1]*dx;
data.xaxis = data.xaxis-data.xaxis(Nx/2+1);
data.yaxis = [0:Ny-1]*dy;
data.yaxis = data.yaxis-data.yaxis(Ny/2+1);
waitbar(3/3,h)
close(h)