clc
clear
close all

R = [0.1029682642119627,-0.9936774593372184,0.0447509035697186
0.9823491697101430,0.0945249111491979,-0.1614160770866054
0.1561654421918247,0.0605817462390038,0.9858712931654237];

t = [0.3833327027246126
-0.0419725732253034
0.7544469719633752];

I2 = imread('color_frame_0.png');
figure , imshow(I2)
path_depth = 'depth_frame_0.png';
d_I = imread(path_depth);
d_I = double(d_I);
figure , imshow(d_I , [])

%% De_Projection
X = 1101;
Y = 534;
depth = d_I(Y,X) * .001;.289;%d_I(344,196) * 0.001;

% % Color camera, and resolution 1280 * 720
fx = 910.718994140625  ;
fy = 908.876159667969 ;
cx = 634.168640136719   ;
cy = 355.472259521484  ;    
% coeffs = [0 0 0 0 0];;
% 
x = (X - cx)/fx;
y = (Y - cy)/fy;
% m = 1;
% A1=[fx/m 0 fy/m 0; 0 cx/m cy/m 0; 0 0 1 0];%[k(1)/m 0 k(7)/m 0; 0 k(1)/m k(8)/m 0; 0 0 1 0];
% A1 = A1(:,1:3);
Pc(1) = depth * x;
Pc(2) = depth * y;
Pc(3) = depth;
Pc = Pc';Pc = Pc;% to mm
Mext = [R t;0 0 0 1];
Pw_h = inv(Mext) * [Pc;1]

K=[fx 0 cx; 0 fx cy; 0 0 1];
Pc_new = [R t] * Pw_h
P = K * Pc_new
Pn = P/P(3)
