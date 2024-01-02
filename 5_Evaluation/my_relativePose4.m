clc
clear
close all

% first image pose
a1 = load('posesPath/color_frame_55.mat');

% second image pose
a2 = load('posesPath/color_frame_140.mat');

I1 = imread('color_frame_55.png');
figure , imshow(I1)
I2 = imread('color_frame_140.png');
figure , imshow(I2)
path_depth1 = '../1_DataPreparation/20231228_103516/Depth/depth_frame_55.png';
d_I1 = imread(path_depth1);
d_I1 = double(d_I1);

% pixel to be transformed to the other view
X = 512;
Y = 273;

% depth of related pixels
depth = d_I1(Y,X) * .1;

% Camera parameters
fx = 4.17368e+02;
fy = 4.17368e+02;
cx = 4.23688e+02;
cy = 2.46202e+02;
K = [fx 0 cx; 0 fy cy; 0 0 1];

%% De_Projection
Pc = depth * inv(K) * [X,Y,1]';
Mext = [a1.R a1.T;0 0 0 1];
Pw_h = inv(Mext) * [Pc;1];

%% Projection to other view
K=[fx 0 cx; 0 fy cy; 0 0 1];
P = K * [a2.R a2.T] * Pw_h;
Pn = P/P(3)