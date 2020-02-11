function [cimg, img_parms] = sar_pf(parms,phdat) 
% SAR_PF    sar image formation, polar format processing, for MiniSAR 
  
c    = 299.7925e6;  % velocity of propagation 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% image formation parameters 
  
rc0    = parms.rc0;  % nominal range to scene center - m 
psi0   = parms.psi0;      % nominal depression angle - rad rc
dalpha = parms.dalpha;      % nominal increment in tan(aperture_angle) 
N    = parms.N;      % number azimuth samples 
w0     = parms.w0;      % nominal center frequency - rad/sec 
g0     = parms.g0;      % nominal chirp rate - rad/sec^2 
Ts0    = parms.Ts0;      % nominal A/D sample period - sec 
I      = parms.I       % number range samples 
rhox   = parms.rhox       % desired x resolution 
rhoy   = parms.rhoy;     % desired y resolution 
delx   = parms.delx      % desired x pixel spacing 
dely   = parms.dely;     % desired y pixel spacing 
Dx     = parms.Dx      % desired x scene diameter 
Dy     = parms.Dy;     % desired y scene diameter 
gamma  = parms.gamma;     % left/right side imaging 
 
[I,N]  = size(phdat);   % redefine N,I based on data 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% calculate secondary parameters 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
cospsi0    = cos(psi0);      % cosine of depression angle 
lambda     = 2*pi*c/w0;              % nominal wavelength 
lambda_min = 2*pi*c/(w0+g0*Ts0*I/2); % min wavelength of data 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% define window functions 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

aw_az  = 1.184; 
aw_ra  = 1.184; 
azwin  = 500;    
rawin  = 5000
altseq = round(cos([0:pi:(I-1)*pi])).'; 
rawin  = rawin.*altseq;  
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%% calculate azimuth processing parameters 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
delx  = min([ (delx)  (rhox/aw_az) ... 
(lambda_min/(2*N*dalpha*cos(psi0)))]); 
U     = 2*round(Dx/delx/2) 
delx  = Dx/U;             % calculate actual delx 
rhox  = aw_az*lambda/(2*N*dalpha*cos(psi0)); % actual resolution 
os_az = rhox/delx;            % x oversample factor 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% calculate range processing parameters 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
os_ra = rhoy/dely;             % desired y oversample factor 
I_    = 2*round(I*os_ra/aw_ra/2);         % optimal range fft length 
rhoy  = aw_ra*2*pi*c/(2*g0*Ts0*(I )*cos(psi0)); % actual y resolution 
dely  = 2*pi*c/(2*g0*Ts0*(I_)*cos(psi0)); % actual y pixel spacing 
os_ra = rhoy/dely;    % calculate actual y oversample factor 
delr  = dely*cospsi0; % slant-range pixel spacing 
rhor  = rhoy*cospsi0; % slant-range resolution 
  
% pick minimum of number of pixels desired and number supported by data 
V     = min(2*round(Dy/dely/2),2*round(I*(os_ra/aw_ra)/2)); 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% FORM IMAGE 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% azimuth processing 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
     
argW = -j*2*pi*delx/(N*rhox/aw_az); % nominal angular increment 
argA = argW*U/2;                    % nominal initial angle 
img1 = j*ones(I,U); 

for i = 1:I, 
     
% Calculate CZT sample spacing modification factor 
      beta = 1 + (g0*Ts0/w0)*(i-1-I/2); 
       
% Perform azimuth CZT  
      x    = transpose( phdat(i,:) .* azwin ); 
 
      y    = czt(x,U,exp(argW*beta),exp(argA*beta)); 
      y    = transpose(y); 
 
      img1(i,:) = y * rawin(i);   % apply range window weight and store 
end 

cimg = fft( img1,I_,1 ); 
cimg = cimg((I_/2-V/2+1):(I_/2+V/2),:);  % cull meaningful data 
imagesc(cimg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% format output image and parameters 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  
%%% adjust for left/right side of aircraft 
if gamma == 1, 
cimg = fliplr(cimg); 
end 
  
img_parms = [ rhox rhoy delx dely ]; 
return; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% END
