% In this version we
% 1 - compute the 3d mesh based on a given step, so we have a downsampled version of mesh.
% 2 - we have a perfect corresponding mask between 3d and 2d

clc
clear 
close all

img_number = 115; 

% Read .mat file contains all 3d points corresponds to image pixels Intel
% camera
path = '../1_DataPreparation/PtCloud/';

filename = [path 'frame_' num2str(img_number) '.ply'];
ptCloud = pcread(filename);
%  figure , pcshow(ptCloud);
% ptCloudOut = pcdownsample(ptCloud,'random',percentage);
x = reshape(double(ptCloud.Location(:,1)) , [1280 , 720]);%[1280 , 720]
y = reshape(double(ptCloud.Location(:,2)) , [1280 , 720]);
z = reshape(double(ptCloud.Location(:,3)) , [1280 , 720]);
for i = 1:1280
    for j = 1:720
        if x(i,j) == 0 & y(i,j) == 0 & z(i,j) == 0
            x(i,j) = randn(1)/5;
            y(i,j) = randn(1)/5;
            z(i,j) = randn(1)/5;
        end
    end
end

% figure , pcshow([x ,y ,z]);
path_img = '../1_DataPreparation/Color/';

img_filename = [path_img 'color_frame_' num2str(img_number) '.png'];
I = imread(img_filename);
% figure , imshow(I,[])

% I_new = I ([80:680],[600:1150],:);
% figure , imshow(I_new,[])
% x_new = x([600:1150],[80:680]);
% y_new = y([600:1150],[80:680]);
% z_new = z([600:1150],[80:680]);
% figure , pcshow([x_new(:) , y_new(:) , z_new(:)]);

% %Get polygon coordinates
% h = impoly;
% %Create binary image mask
% mask = createMask(h);
% %Set all pixels inside polygon to 255, and all pixels outside polygon to 0
% mask = uint8(mask * 255);
% imwrite(mask,['img_masks/mask' num2str(img_number) '.png'])
mask = imread(['img_masks/mask' num2str(img_number) '.png']);
mask = mask';
% Display binary mask
figure
imshow(mask);
% projecting 3d points to pixel

% triangulate points with a given step size and a given mask
width = size((I),2);
height = size((I),1);

 k = 1;
 c = 1;
 % use mesh function
 step = 15;
for i = 1:step:width
    for j = 1:step:height
        new_v = [i,j];
        V(k,:) = new_v;
        V_3d(k,:) = [x(i,j), y(i,j), z(i,j)];
        V_img(k,:) = [new_v,0];      
        
        if mask (i,j) == 0
            verticesToRemove(c) = k;
            c = c+1;
        end
        k = k + 1;
    end
end
k = 1;
for i = 1:floor((width-1)/step) 
    for j = 1:floor((height-1)/step)
                 
%          f1 = [height * (i-1) + j , (height*i) + j , (height*i) + j + 1];
%          f2 = [height * (i-1) + j , (height*i) + j + 1, (height*i) + j - height + 1];
           VInRow = floor((height-1)/step)+1;
           f1 = [VInRow * (i-1) + j , (VInRow*i) + j , (VInRow*i) + j - VInRow + 1];
           f2 = [(VInRow*i) + j , (VInRow*i) + j + 1, (VInRow*i) + j - VInRow + 1];
         
%          F = [F ; f1;f2];
           F_img(k,:) = f1;
           F_img(k+1 , :) = f2;
           k = k + 2;        
    end
end

V_img = V_img';
F = F_img';

% figure , 
% options.texture = (I);
% options.PSize = 64;
% options.texture_coords = X;
% % clear option
% plot_mesh_modified(X , F, options);
% shading faceted; axis tight;
% clear option
% figure , 
% options.texture = (I);
% options.PSize = 64;
% options.texture_coords = X;
% Y = V_3d';
% plot_mesh(Y , F, []);
% shading faceted; axis tight;

%removing vertices outside mask from created meshes
% Remove vertices from mesh
newVertices_3d = V_3d';
newVertices_img = V_img;
newVertices_3d(: ,verticesToRemove) = [];
newVertices_img(: ,verticesToRemove) = [];

newFaces = F';
for i = 1:numel(verticesToRemove)
    newFaces(F' == verticesToRemove(i)) = NaN;
    newFaces = newFaces - (F' > verticesToRemove(i));
end
newFaces(any(isnan(newFaces), 2), :) = [];

% figure , 
% plot(newVertices_img(1,:), newVertices_img(2,:),'*')
% hold on
% plot(newVertices_img(1,k), newVertices_img(2, k))


% Step 3: Determine which points are inside each face
mask_modified = zeros(1280,720);
for i = 1:size(newFaces, 1)
    p1 = newVertices_img(1:2, newFaces(i,1));
    p2 = newVertices_img(1:2, newFaces(i,2));
    p3 = newVertices_img(1:2, newFaces(i,3));

    P = [p1,p2,p3];
    % Step 1: Define bounding box
    bbox = [min(P(1,:)), max(P(1,:)), min(P(2,:)), max(P(2,:))]

    % Step 2: Generate grid of points within bounding box
    [X,Y] = meshgrid(bbox(1):1:bbox(2), bbox(3):1:bbox(4));
    points = [X(:), Y(:)];

    [in_out] = inpolygon(points(:,1), points(:,2), P(1, :),P(2, :));


    in_out = reshape(in_out,[step + 1, step + 1]);
    X_ = X.*in_out;
    Y_ = Y.*in_out;
    t1 = X_(X_(:)>0);
    t2 = Y_(Y_(:)>0);
    sz = [1280 720];
    ind = sub2ind(sz,t1(:),t2(:));
    mask_modified (ind) = 1;

end

% Step 4: Create binary image
figure
imshow(mask_modified, []);
imwrite(mask_modified,['masks_modified/' num2str(img_number) '.png'])

pause(1)
clear option
figure , 
options.texture = (I);
options.PSize = 64;
options.texture_coords = newVertices_img;
Y = V_3d';
plot_mesh_modified(newVertices_3d , newFaces, options);
shading faceted; axis tight;
pause(1)
clear option
figure , 
options.texture = (I);
options.PSize = 64;
options.texture_coords = newVertices_img;
plot_mesh_modified(newVertices_img , newFaces, options);
shading faceted; axis tight;
pause(1)
write_obj (['Masked meshes/Mesh_fram_' num2str(img_number) '_3d_masked.obj'],newVertices_3d,newFaces)
write_obj (['Masked meshes/Mesh_fram_' num2str(img_number) '_img_masked.obj'],newVertices_img,newFaces)