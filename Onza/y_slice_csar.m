filename = "Snow_Melted_Refrozen_20_deg_R_180.gif" 

c = physconst('LightSpeed');

max_amplitude =0;

fs = 7.29e9;

res = 1;

ncr = find(time_samples>60,1)

 % number of cross range samples (slow time track)  

offset = 0;
theta_range = time_samples(1:ncr)*pi/30;

theta_range = circshift(theta_range,offset);

dd = scaledFrame;



ftres = 150   % fast Time res
stres = 150   % slow Time res 

data = zeros(ftres,stres);

R0 = 1.80 % radius from radar front to center of turntable 
fracR0 = .25 % fraction of radar return interested in, measured from center of radius
height = 0;

rd = R0;

dim_slices = -.5:.1:.5; % static dimension index slices


d = 0
max_cell = 0;
min_cell = 1000;
for rd_index = 1:size(rd,2)
for hd_index = 1:size(dim_slices,2)
    
id = linspace(-rd(rd_index)*fracR0,rd(rd_index)*fracR0,ftres);
jd = linspace(-rd(rd_index)*fracR0,rd(rd_index)*fracR0,stres);
kd = linspace(0,height,stres);
for i = 1:size(id,2)
    for j = 1:size(jd,2)
        d = 0;
        for k = 1:res:length(theta_range)
            xd = id(i) - rd(rd_index)*cos(theta_range(k));
            yd = jd(j) - dim_slices(hd_index);
            zd = height - kd(j);
            td = (2*sqrt(xd^2+yd^2+zd^2));
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
image = imagesc(abs(data));
if max(max(data)) > max_amplitude
    max_amplitude = max(max(data));
end
scaledData = 20*log10(data./max(max(data)));
%image = imagesc(scaledData);
%caxis([-3 0]);
xticks(linspace(1,ftres,7));
xticklabels([linspace(id(1),id(end),7)]);
yticks(linspace(1,stres,7));
yticklabels([linspace(kd(1),kd(end),7)]);
xlabel('Range (m)');
ylabel('Height (m)');
title({['Snow Melted then Refrozen @ 45 deg']...
    ['Backprojection Reconstruction,',num2str(ftres),'x',num2str(stres), ' Resolution']...
    [' Height @ Z = ' num2str(dim_slices(hd_index)), ' meters'] ...
    ['Radius @ R = ', num2str(rd(rd_index)),  ' meters'] ...
    [ 'Number of Pixels above -3db = ', num2str(length(find(scaledData>=-3))), ' Pixels']})
drawnow
% gif creation 
getframe(h);
frame = getframe(h); 
im = frame2im(frame); 
[imind,cm] = rgb2ind(im,256); 
if (hd_index == 1 && rd_index == 1)
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
      else 
          imwrite(imind,cm,filename,'gif','WriteMode','append'); 
end 
end
end