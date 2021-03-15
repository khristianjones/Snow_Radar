filename = 'TimeLapse_0_deg.gif'
h = figure;

for i = 1:10:1000;
    
    
    plot(abs(scaledFrame(:,i)),'b');
    drawnow;
    getframe(h);
    frame = getframe(h); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256); 
     if (i == 1)
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
      else 
          imwrite(imind,cm,filename,'gif','WriteMode','append'); 
end 
end