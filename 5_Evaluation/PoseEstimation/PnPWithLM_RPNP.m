function [R,t] = PnPWithLM_RPNP(Ps3d,ps2d)
%function to perform pnp using levenberg marquardt, initialised with rpnp
%Ps3d: 3 x N points in world space
%ps2d: 2 x N points in normalised pixel coordinates
%[R,t] is the transform mapping world to camera coordinates
%(c) Toby Collins 2014

[R, t]= RPnP(Ps3d,ps2d);
r = RodriguezRotate2ndOrd_inv(R)';
x0 = [r;t];
e0 = norm(pnpErr(Ps3d,ps2d,x0));
 
x = lsqnonlin(@(x)  pnpErr(Ps3d,ps2d,x),x0);
e2 = norm(pnpErr(Ps3d,ps2d,x));

r = x(1:3);
t = x(4:6);
R = RodriguezRotate2ndOrd(r'); 

function r = pnpErr(Ps3d,ps2d,x)
r = x(1:3);
t = x(4:6);
R = RodriguezRotate2ndOrd(r');
Q = R*Ps3d;
Q(1,:) = Q(1,:) + t(1);
Q(2,:) = Q(2,:) + t(2);
Q(3,:) = Q(3,:) + t(3);

qx = Q(1,:)./Q(3,:);
qy = Q(2,:)./Q(3,:);
r = [qx;qy]-ps2d;
r = r(:);





