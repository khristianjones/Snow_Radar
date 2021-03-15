%% csar gui function 

function f = CSAR_GUI(filename,offset,ftres,stres,R0,fracR0,...
    normalization) 
  
load('Snow_Melted_Refrozen_0deg17-Sep-2020_13-29.mat')

c = physconst('LightSpeed');
  

max_amplitude =0;

fs = 7.29e9;

res = 1;

ncr = find(time_samples>60,1)

 % number of cross range samples (slow time track)  

theta_range = time_samples(1:ncr)*pi/30;

theta_range = circshift(theta_range,offset);

dd = scaledFrame;


data = zeros(ftres,stres);

% radius from radar front to center of turntable 
 % fraction of radar return interested in, measured from center of radius
height = .9;

rd = R0;
zd = .9;

clear M;
clear N;
 
d = 4
max_cell = 0;
min_cell = 1000;
for rd_index = 1:size(rd,2)
for zd_index = 1:size(zd,2)
    
id = linspace(-rd(rd_index)*fracR0,rd(rd_index)*fracR0,ftres);
jd = linspace(-rd(rd_index)*fracR0,rd(rd_index)*fracR0,stres);
for i = 1:size(id,2)
    for j = 1:size(jd,2)
        d = 0;
        for k = 1:res:length(theta_range)
            xd = id(i) - rd(rd_index)*cos(theta_range(k));
            yd = jd(j) - rd(rd_index)*sin(theta_range(k));
            %td = (2*sqrt(xd^2+yd^2+(height-zd(zd_index))^2))/c;
            td = (2*sqrt(xd^2+yd^2+(height-zd(zd_index))^2));
            cell = round(td*(1536/9.9))+1;
            % cell = round(td*fs)+1;
            if (cell > max_cell)
                max_cell = cell;
            end
            if (cell < min_cell)
                min_cell = cell;
            end
            
                
            signal = abs(dd(cell,k));
            d = d + signal;
        end
        
        data(i,j) = d; 
    end
end



h = figure;
%image = imagesc(abs(data));
%if max(max(data)) > max_amplitude
%    max_amplitude = max(max(data));
%end
if (strcmp(normalization,'-3dB'))
    scaledData = 20*log10(data./max(max(data)));
    image = imagesc(scaledData);
    caxis([-3 0]);
elseif(strcmp(normalization,'1/R^2'))
        scaledData =20*log10(data./max(max(data)));
        image = imagesc(scaledData);
        caxis([-3 0]);
elseif (strcmp(normalization,'None'))
    scaledData = abs(data);
    image = imagesc(scaledData);
end
xticks(linspace(1,ftres,7));
xticklabels([linspace(id(1),id(end),7)]);
yticks(linspace(1,stres,7));
yticklabels([linspace(jd(1),jd(end),7)]);
xlabel('X Range (m)');
ylabel('Y Cross-Range (m)');
title({[filename]...
    ['Backprojection Reconstruction,',num2str(ftres),'x',num2str(stres), ' Resolution']...
    [' Height @ Z = ' num2str(zd(zd_index)), ' meters'] ...
    ['Radius @ R = ', num2str(rd(rd_index)),  ' meters'] ...
    [ 'Number of Pixels above -3db = ', num2str(length(find(scaledData>=-3))), ' Pixels']})
drawnow
% gif creation 
getframe(h);
frame = getframe(h); 
im = frame2im(frame); 
[imind,cm] = rgb2ind(im,256); 
if (zd_index == 1 && rd_index == 1)
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
      else 
          imwrite(imind,cm,filename,'gif','WriteMode','append'); 
end 
M(:,:,zd_index) = abs(data);
N(:,:,zd_index) = scaledData;
end
end
end
