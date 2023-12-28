clc
clear
close all

a1 = load('posesPath/intel_01_Color.mat');
a2 = load('posesPath/intel_02_Color.mat');

R_relative = a2.R * a1.R'
T_relative = a2.T - (R_relative * a1.T)

I1 = imread('intel_01_Color.png');
figure , imshow(I1)
I2 = imread('intel_02_Color.png');
figure , imshow(I2)

% % Color camera, and resolution 1280 * 720
fx = 4.17368e+02;
fy = 4.17368e+02;
cx = 4.23688e+02;
cy = 2.46202e+02;
% coeffs = [0 0 0 0 0];
% 
% x = (374 - PPX)/Fx;
% y = (310 - PPY)/Fy;
m = 1;
A1=[fx/m 0 fy/m 0; 0 cx/m cy/m 0; 0 0 1 0];%[k(1)/m 0 k(7)/m 0; 0 k(1)/m k(8)/m 0; 0 0 1 0];
% A1 = A1(:,1:3);

mp_h = [374 310 1];
% pc =  inv(A1) * mp_h'
T = [a1.R a1.T; 0 0 0 1]
PP = A1 * T

PPw = [PP; 0 0 0 1]
pw = invA1 * T * mp_h
point_input = [1 * x;1 * y; 1]; 

transformation = [R_relative, T_relative; 0 0 0 1];
point_out = transformation * [point_input;1]

p = point_out/point_out(3)

Px = p(1) * Fx + PPX
Py = p(2) * Fy + PPY
