clc
clear
close all

gridsize = 30;
interp_method = 'cubic'; % 'linear' 'nearest'	'cubic' 'spline'
for frame_number = [0 17 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 115];
    path_rgbimgs = '../1_DataPreparation/Color/';

    for lambda = 1;%960:-10:800
        tic
        
        Image_path = [path_rgbimgs 'color_frame_' num2str(frame_number) '.png'];
        image  = imread(Image_path);
        image = im2double(image);

imshow(image);
title('Original Image');

% Define the vertices of the first and second meshes
% Replace these with your actual vertices

        [vflat , fflat] = readOBJ(['../3_Flattening/Flattened Meshes gs' num2str(gridsize), ...
            '/Frame ' num2str(frame_number) '/lambda ' num2str(lambda) '.obj']);

        [vimg , fimg] = readOBJ(['../2_DataPreprocessing/Masked meshes gs' num2str(gridsize),'/' ...
        'Mesh_fram_' num2str(frame_number) '_img_masked.obj']);%
        
vertices_first_mesh = vimg;%[x1_first_mesh, y1_first_mesh; x2_first_mesh, y2_first_mesh; x3_first_mesh, y3_first_mesh];
vertices_second_mesh = vflat;%[x1_second_mesh, y1_second_mesh; x2_second_mesh, y2_second_mesh; x3_second_mesh, y3_second_mesh];

% Create triangulation objects for the first and second meshes
% triangulation_first_mesh = delaunayTriangulation(vertices_first_mesh);
% triangulation_second_mesh = delaunayTriangulation(vertices_second_mesh);

% Get the triangles in the first and second meshes
triangles_first_mesh = fimg;%triangulation_first_mesh.ConnectivityList;
triangles_second_mesh = fflat;%triangulation_second_mesh.ConnectivityList;

% Create an empty image to store the warped result
output_image_size = size(image);
warped_image = zeros(output_image_size, 'like', image);

% Loop through each triangle in the first mesh
for i = 1:size(triangles_first_mesh, 1)
    % Get the vertices of the current triangle in the first mesh
    vertices_first = vertices_first_mesh(triangles_first_mesh(i, :), :);
    vertices_first = vertices_first(:,1:2);
    % Get the vertices of the corresponding triangle in the second mesh
    vertices_second = vertices_second_mesh(triangles_second_mesh(i, :), :);
    vertices_second = vertices_second(:,1:2);
    % Create a projective2d object representing the affine transformation
    tform = fitgeotrans(vertices_first, vertices_second, 'affine');

    % Warp the triangle from the original image to the new position
    warped_triangle = imwarp(image, tform, 'OutputView', imref2d(output_image_size));

    % Update the warped image with the current triangle
    warped_image = max(warped_image, warped_triangle);
end

% Display the warped image
figure;
imshow(warped_image);
title('Warped Image');
k = 0;
    end
end