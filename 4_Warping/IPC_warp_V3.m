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
        Ia  = imread(Image_path);
        Ia = im2double(Ia);

        [vflat , fflat] = readOBJ(['../3_Flattening/Flattened Meshes gs' num2str(gridsize), ...
            '/Frame ' num2str(frame_number) '/lambda ' num2str(lambda) '.obj']);

        vflat_new = vflat';
        fflat = fflat';

        outputSize_x = 1280; %max(vflat_new(1,:));
        outputSize_y = 720; %max(vflat_new(2,:));

        xp = 1:outputSize_x;
        yp = 1:outputSize_y;
        [xq , yq] = meshgrid(xp , yp);

        [vimg , fimg] = readOBJ(['../2_DataPreprocessing/Masked meshes gs' num2str(gridsize),'/' ...
            'Mesh_fram_' num2str(frame_number) '_img_masked.obj']);%

        vimg = vimg';
        fimg = fimg';

        xCA = zeros(720,1280);
        yCA = zeros(720,1280);
        Image_out = zeros(size(Ia));
        mask_out = ones(size(Ia,1:2));

        for T = 1:size(fflat,2)
            Vi1 = vflat_new(1:2,fflat(1,T)); % Cartesian coordinates of the first vertex in input image
            Vi2 = vflat_new(1:2,fflat(2,T)); % Cartesian coordinates of the secend vertex in input image
            Vi3 = vflat_new(1:2,fflat(3,T)); % Cartesian coordinates of the third vertex in input image

            [w1,w2,w3,r] = inTri(xq, yq, Vi1(1), Vi1(2), Vi2(1), Vi2(2), Vi3(1), Vi3(2));

	        w1(~r)=0; w1 = w1.*mask_out;
	        w2(~r)=0; w2 = w2.*mask_out;
	        w3(~r)=0; w3 = w3.*mask_out;
            mask_out(r) = 0;

            Vo1 = vimg(1:2,fimg(1,T)); % Cartesian coordinates of the first vertex in output image
            Vo2 = vimg(1:2,fimg(2,T)); % Cartesian coordinates of the secend vertex in output image
            Vo3 = vimg(1:2,fimg(3,T)); % Cartesian coordinates of the third vertex in output image
            VertexOut = [Vo1 Vo2 Vo3];

	        xCA = xCA + w1.*VertexOut(1,1) + w2.*VertexOut(1,2) + w3.*VertexOut(1,3);
	        yCA = yCA + w1.*VertexOut(2,1) + w2.*VertexOut(2,2) + w3.*VertexOut(2,3);

        end

        [X , Y] = meshgrid(1:size(Ia , 2) , 1:size(Ia ,1));
        Image_out(:,:,1) = interp2(X,Y,double(Ia(:,:,1)),xCA,yCA);
        Image_out(:,:,2) = interp2(X,Y,double(Ia(:,:,2)),xCA,yCA);
        Image_out(:,:,3) = interp2(X,Y,double(Ia(:,:,3)),xCA,yCA);
        figure , imshow(Image_out, [])

        folderName = ['img_flat_gs' num2str(gridsize),'/Frame_' num2str(frame_number)];
        if ~exist(folderName, 'dir')
            mkdir(folderName);
            fprintf('Folder "%s" created.\n', folderName);
        else
            fprintf('Folder "%s" already exists.\n', folderName);
        end
        path_output_imgs = ['img_flat_gs' num2str(gridsize),'/Frame_' num2str(frame_number) '/lambda' num2str(lambda) '.png'];
        imwrite(Image_out , path_output_imgs )

    time = toc
    lambda
    frame_number
    end
end


function [w1,w2,w3,r] = inTri(vx, vy, v0x, v0y, v1x, v1y, v2x, v2y)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inTri checks whether input points (vx, vy) are in a triangle whose
% vertices are (v0x, v0y), (v1x, v1y) and (v2x, v2y) and returns the linear
% combination weight, i.e., vx = w1*v0x + w2*v1x + w3*v2x and
% vy = w1*v0y + w2*v1y + w3*v2y. If a point is in the triangle, the
% corresponding r will be 1 and otherwise 0.
%
% This function accepts multiple point inputs, e.g., for two points (1,2),
% (20,30), vx = (1, 20) and vy = (2, 30). In this case, w1, w2, w3 and r will
% be vectors. The function only accepts the vertices of one triangle.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    v0x = repmat(v0x, size(vx,1), size(vx,2));
    v0y = repmat(v0y, size(vx,1), size(vx,2));
    v1x = repmat(v1x, size(vx,1), size(vx,2));
    v1y = repmat(v1y, size(vx,1), size(vx,2));
    v2x = repmat(v2x, size(vx,1), size(vx,2));
    v2y = repmat(v2y, size(vx,1), size(vx,2));
    w1 = ((vx-v2x).*(v1y-v2y) - (vy-v2y).*(v1x-v2x))./...
    ((v0x-v2x).*(v1y-v2y) - (v0y-v2y).*(v1x-v2x))+eps;
    w2 = ((vx-v2x).*(v0y-v2y) - (vy-v2y).*(v0x-v2x))./...
    ((v1x-v2x).*(v0y-v2y) - (v1y-v2y).*(v0x-v2x))+eps;
    w3 = 1 - w1 - w2;
    r = (w1>=-100*eps) & (w2>=-100*eps) & (w3>=-100*eps) & ...
    (w1<=1+100*eps) & (w2<=1+100*eps) & (w3<=1+100*eps);
end
