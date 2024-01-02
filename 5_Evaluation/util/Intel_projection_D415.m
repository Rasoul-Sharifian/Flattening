
% close all
function [Px, Py] = Intel_projection(from_point)
%% Projection

% Transform 3D coordinates relative to one sensor to 3D coordinates relative to another viewpoint
% Alignment: transforming the point from depth camera (Inferared 1) coordinate to Color camera coordinate

% rotation = [0.999993 -0.00101996 0.00367558;
%     0.00102743 0.999997 -0.00203003;
%     -0.0036735 0.00203379 0.999991];
% translation = [0.0150572843849659 0.000139289739308879 -0.000271180673735216];
% 
% to_point(1) = rotation(1) * from_point(1) + rotation(4) * from_point(2) + rotation(7) * from_point(3) + translation(1);
% to_point(2) = rotation(2) * from_point(1) + rotation(5) * from_point(2) + rotation(8) * from_point(3) + translation(2);
% to_point(3) = rotation(3) * from_point(1) + rotation(6) * from_point(2) + rotation(9) * from_point(3) + translation(3);
to_point = from_point;
% Projecting a 3d point to sensor
% Given a point in 3D space, compute the corresponding pixel coordinates
% in an image with no distortion or forward distortion coefficients produced by the same camera

% Color camera, and resolution 640 * 480
% Fx = 607.14599609375;
% Fy = 605.91748046875;
% PPX = 316.112426757813;
% PPY = 236.981506347656;
% coeffs = [0 0 0 0 0];

% Color camera, and resolution 1280 * 720
Fx = 910.718994140625;
Fy = 908.876159667969;
PPX = 634.168640136719;
PPY = 355.472259521484;
coeffs = [0 0 0 0 0];

x = to_point(1) / to_point(3);
y = to_point(2) / to_point(3);

r2  = x*x + y*y;
f = 1 + coeffs(1)*r2 + coeffs(2)*r2*r2 + coeffs(5)*r2*r2*r2;
x = x * f;
y = y * f;
dx = x + 2*coeffs(3)*x*y + coeffs(4)*(r2 + 2*x*x);
dy = y + 2*coeffs(4)*x*y + coeffs(3)*(r2 + 2*y*y);
x = dx;
y = dy;

Px = x * Fx + PPX;
Py = y * Fy + PPY;
end
