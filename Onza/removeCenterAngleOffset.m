function data = removeCenterAngleOffset(data);
% This function calculates the angle, relative to the x-axis, of
% the radar flight path at mid-CPI. It then rotates the xy coordinate
% reference so that the flight path lies centered on the x-axis.
% This process facilitates the operation of the Polar Format Algorithm.
% calculate rotation angle theta, relative to the x-axis, at mid-CPI
xxx=data.AntX(round(data.Np/2));
yyy=data.AntY(round(data.Np/2));
theta = atan2(yyy,xxx);
data.centerAngleRotationDegr = theta*180/pi;
% standard rotation matrix
A = [cos(theta) sin(theta); -sin(theta) cos(theta)];
% Make sure data.AntX and data.AntY are column vectors for
% matrix multiplication
[nr,nc] = size(data.AntX);
if nc>nr,
data.AntX = (data.AntX)';
data.AntY = (data.AntY)';
data.AntZ = (data.AntZ)';
data.R0 = (data.R0)';
end
% rotate the xy coordinates in order to center the flight path on the
% x-axis
XXX = [data.AntX' ; data.AntY'];
XXX = A*XXX;
data.AntX = (XXX(1,:))';
data.AntY = (XXX(2,:))';