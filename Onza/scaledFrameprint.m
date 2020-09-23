for i = 1:1000;
    hold on
    plot(abs(deg45(:,i)),'b');
    plot(abs(deg0(:,i)),'r');
    drawnow;
end