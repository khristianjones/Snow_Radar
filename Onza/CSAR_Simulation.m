%% csar demo 

c = physconst('LightSpeed');

fc = 7.29e9;   % center frequency
fs = 2.3328e10;   % Sampling Rate 
bwf = 1.4e9;      % bandwidth 
f_upper = 7.29e9+bwf/2;   % upper frequency 
f_lowwer = 7.29e9-bwf/2;  % lower frequency 


range_samples = 1536;     % number of fast time samples 
resolution    = c/range_samples/2; 

ncr = 200; % number of cross range samples (slow time track)  
theta_range = linspace(0,2*pi,ncr); 

Rg = 3;    % radius of circular track 

xR = Rg*cos(theta_range);   % x location of radar 
yR = Rg*sin(theta_range);   % y location of radar 

oX = 0;
oY = 0;

x_array  = linspace(0,9.9,1536);
y_array  = linspace(0,9.9,1536);
xx = 0;
yy = 0;

%% 

for j = 1:ncr 
        xx=x_array*cos(theta_range(j)+pi)+xR(j);
        yy=y_array*sin(theta_range(j)+pi)+yR(j);
        scatter(xx,yy,'b');
        axis([-2 2 -2 2])
        hold on

        
        
end

        

%% Signal Simulation 



ntarget=4;                        % number of targets
% Set ntarget=1 to see "clean" PSF of target at origin
% Try this with other targets

% xn: range;            yn= cross-range;    fn: reflectivity
  xn=zeros(1,ntarget);  yn=xn;              fn=xn;

% Targets within digital spotlight filter
%
  xn(1)=0;              yn(1)=0;            fn(1)=1;
  xn(2)=.7*X0;          yn(2)=-.6*Y0;       fn(2)=1.4;
  xn(3)=0;              yn(3)=-.85*Y0;      fn(3)=.8;
  xn(4)=-.5*X0;         yn(4)=.75*Y0;       fn(4)=1.;



 %% Backprojection 


 
fs = 2.3328e10;   % Sampling Rate  

ncr = 200; % number of cross range samples (slow time track)  
theta_range = linspace(0,2*pi,ncr); 

ftres = 300;   % fast Time res
stres = 300;   % slow Time res 



data = zeros(ftres,stres);



R0 = 3;

id = linspace(-R0,R0,ftres);
jd = linspace(-R0,R0,stres);
d = 0;

for i = 1:size(id,2)
    for j = 1:size(jd,2)
        d = 0;
        for k = 1:length(theta_range)
            xd = id(i) - R0*cos(theta_range(k));
            yd = jd(j) - R0*sin(theta_range(k));
            td = (2*sqrt(xd^2+yd^2))/c;
            cell = round(td*fs)+1;
            signal = r(cell,k);
            d = d + signal;
           % d = d + signal; 
        end
        
        data(i,j) = d; 
    end
end

%%
            
imagesc(abs(data));
xticks(linspace(1,ftres,7));
xticklabels([linspace(-R0,R0,7)]);
yticks(linspace(1,stres,7));
yticklabels([linspace(-R0,R0,7)]);
xlabel('Range (m)');
ylabel('Cross-Range (m)');
title(['Backprojection Reconstruction ',num2str(ftres),'x',num2str(stres),' Resolution'])