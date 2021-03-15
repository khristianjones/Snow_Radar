% Noncoherant CSAR Imaging 

twopi  = 2*pi; 
N      = 100;    % Number of subapertures
R0     = 1.8;   % Radius in meters
fs     = 7.29e9;% Center frequency
ncr    = find(time_samples>60,1); % Number of cross range samples 2*pi
fracR0 = .25;

% Splits coherant track into non-coherant subaperatures 
temp_theta_range = time_samples(1:ncr)*pi/30;
count  = round(length(temp_theta_range)/N);
remander = mod(length(temp_theta_range),N);
theta_range = reshape(temp_theta_range(1:end-remander),[count,N]);

dd = scaledFrame; 

ftres = 300; % Fast-time resolution
stres = 300; % Slow-time resolution 

data = zeros(ftres, stres);
data2 = zeros(ftres, stres);

id = linspace(-rd(rd_index)*fracR0,rd(rd_index)*fracR0,ftres);
jd = linspace(-rd(rd_index)*fracR0,rd(rd_index)*fracR0,stres);

height = .9;

rd = R0;
zd = 0:.1:.9;

for zd_index = 1:size(zd,2)

for i = 1:1:size(id,2)
    for j = 1:1:size(jd,2)
        d = 0;
         %for k = 1:1:size(theta_range,2)
        for k = 1:10
             for m = 1:1:size(theta_range,1)
                 xd = id(i) - R0*fracR0*cos(theta_range(m,k));
                 yd = jd(j) - R0*fracR0*sin(theta_range(m,k));
                 td = (2*sqrt(xd^2+yd^2+(height-zd(zd_index))^2));
                 cell = round(td*(1536/9.9))+1;
                 signal = abs(dd(cell,k));
                 d = d + signal;
             end
         end
         data(i,j) = d;
    end
end
data2 = data2 + data;
scaledData = 20*log10(data./max(max(data)));
image = imagesc(scaledData);
caxis([-3 0]);
xticks(linspace(1,ftres,7));
xticklabels([linspace(id(1),id(end),7)]);
yticks(linspace(1,stres,7));
yticklabels([linspace(jd(1),jd(end),7)]);
xlabel('X Range (m)');
ylabel('Y Cross-Range (m)');
title({['Snow Melted then Refrozen @ 45 deg']...
    ['Backprojection Reconstruction,',num2str(ftres),'x',num2str(stres), ' Resolution']...
    [' Height @ Z = ' num2str(zd(zd_index)), ' meters'] ...
    ['Radius @ R = ', num2str(rd(rd_index)),  ' meters'] ...
    [ 'Number of Pixels above -3db = ', num2str(length(find(scaledData>=-3))), ' Pixels']})
end