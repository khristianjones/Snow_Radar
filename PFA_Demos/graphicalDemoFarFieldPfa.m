function graphicalDemoFarFieldPfa(xs,ys,zs,xt,yt,zt);
% Given vectors of coordinates xs(:), ys(:) and zs(:) which
% represent sensor trajectory during SAR data collection, and
% coordinate (xt,yt,zt) of a point target, this function provides a graphical
% representation of far-field approximation that can be used to predict the
% warping and defocussing of a SAR image computed using PFA.
hold on
clrs = 'brg';
% For graphical demo, just need three points along sensor trajectory
midSamp = round(length(xs)/2);
xs = [xs(1) xs(midSamp) xs(end)];
ys = [ys(1) ys(midSamp) ys(end)]
zs = [zs(1) zs(midSamp) zs(end)];
% plot markers at sensor positions, aimpoint (origin),
% and true target position
plot(0,0,'rp')
plot(xt,yt,'ks','markersize',10,'linewidth',2)
% plot(xs,ys,'o')
for ii = 1:3, % loop over sensor coordinates
h = plot(xs(ii),ys(ii),'o');
set(h,'color',clrs(ii),'linewidth',2);
end
axis equal, grid on
% define field-of-view for the plot
plotCenter = mean(xs)/2;
plotWidth = 1000 + plotCenter;
axis([plotCenter-plotWidth plotCenter+plotWidth -plotWidth plotWidth])
% For each sensor coordinate, plot a circle which is centered at the
% sensor, with radius equal to the measured range R of the target
% as seen from that sensor position. These circles will intersect at the
% true target position.
R = sqrt((xs-xt).^2 + (ys-yt).^2 + (zs-zt).^2); % range to target
yy = [-plotWidth:50:plotWidth]; % define y coordinates of circle plots
zz = zeros(size(yy)); % define z coordinates of circle plots
for ii = 1:3, % loop over sensor coordinates
% given yy and zz, solve for x coordinates of circle plots
xx = xs(ii) - sqrt( R(ii).^2 - (ys(ii)-yy).^2 - (zs(ii)-zz).^2 );
h = plot(xx,yy); % plot circle for this sensor position
set(h,'color',clrs(ii));
end
% For each sensor coordinate, plot a line of points which satisfy the
% far-field approximation given by Eq.(6) in the SPIE paper. In terms of
% the variables in this function, Eq.(6) is given by:
% R = R0 - (sx*xx + sy*yy + sz*zz)
% where (xx,yy,zz) are the coordinates on the line corresponding to each
% sensor position, and (sx,sy,sz) are the components of the unit vector
% pointing from the aimpoint to the sensor. These lines will intersect
% at the position of the target focus in the PFA image.
R0 = sqrt(xs.^2 + ys.^2 + zs.^2); % range to aimpoint
Rdiff = R - R0; % differential range
s0x = xs./R0; % components of unit vector aimpoint-to-sensor
s0y = ys./R0;
s0z = zs./R0;
yy = [-plotWidth:50:plotWidth]; % define y coordinates of line plots
zz = zeros(size(yy)); % define z coordinates of circle plots
for ii = 1:3, % loop over sensor coordinates
% given yy and zz, solve for x coordinates of line plots
xx = -(Rdiff(ii) + s0y(ii)*yy + s0z(ii)*zz)./(s0x(ii));
h=plot(xx,yy); % plot line for this sensor position
set(h,'color',clrs(ii),'linewidth',2);
end