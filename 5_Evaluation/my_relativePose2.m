clc
clear

fx = 4.17368e+02;
fy = 4.17368e+02;
cx = 4.23688e+02;
cy = 2.46202e+02;
% Example camera intrinsic matrix (replace with your actual values)
K = [fx, 0, cx;
     0, fy, cy;
     0, 0, 1];

% Example extrinsic matrices (replace with your actual values)
a1 = load('posesPath/intel_01_Color.mat');
a2 = load('posesPath/intel_02_Color.mat');


% Example pixel coordinates in image 1
pixel_coordinates_image1 = [374; 310; 1];

% Transform pixel coordinates to image 2
X1 = K * pixel_coordinates_image1;

% Normalize homogeneous coordinates
normalized_coordinates_image2 = homogeneous_coordinates_image2 / homogeneous_coordinates_image2(3);

% Convert to integer pixel coordinates
pixel_coordinates_image2 = round(normalized_coordinates_image2(1:2))

% Now pixel_coordinates_image2 contains the transformed pixel coordinates in image 2
