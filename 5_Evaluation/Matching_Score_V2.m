clc
clear
close all
addpath('util');

reference_frame_nb = 0;

counter = 1;

for other_view_frame_nb = 115;[0 17 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 115];

lambda = 800;

MatchThreshold = 2;

main_path = '/media/rasoul/830873c3-8201-4a0c-8abe-39d71bdf67d7/Flatenning/07_08_2023/';

%% Without IPC
% Other view img feature detection
path_img_other_view = [main_path '1_Data Preparation/Color/color_frame_' num2str(other_view_frame_nb) '.png'];
path_mask_other_view = [main_path '2_Data Preprocessing/img_masks/mask' num2str(other_view_frame_nb) '.png'];

mask_exist = 1;
[key_points_other_view, descriptors_other_view] = feature_detection_vlfeet(path_img_other_view, ...
    path_mask_other_view, mask_exist);

figure , imshow(path_img_other_view)

perm = randperm(size(key_points_other_view,2)) ;
sel = perm(1:end) ;
h1 = vl_plotframe(key_points_other_view(:,sel)) ;
h2 = vl_plotframe(key_points_other_view(:,sel)) ;
set(h1,'color','k','linewidth',3) ;
set(h2,'color','y','linewidth',2) ;
hold off
pause(.5)
% h3 = vl_plotsiftdescriptor(descriptors(:,sel),key_points(:,sel)) ;
% set(h3,'color','g') ;

% reference img feature detection
path_mask_ref = [main_path '2_Data Preprocessing/img_masks/mask' num2str(reference_frame_nb) '.png'];
path_ref_img = [main_path '1_Data Preparation/Color/color_frame_' num2str(reference_frame_nb) '.png'];
mask_exist = 1;
[key_points_ref, descriptors_ref] = feature_detection_vlfeet(path_ref_img , path_mask_ref, mask_exist);

figure , imshow(path_ref_img)

perm = randperm(size(key_points_ref,2)) ;
sel = perm(1:end) ;
h11 = vl_plotframe(key_points_ref(:,sel)) ;
h22 = vl_plotframe(key_points_ref(:,sel)) ;
set(h11,'color','k','linewidth',3) ;
set(h22,'color','y','linewidth',2) ;


[matches, scores] = vl_ubcmatch(descriptors_other_view, descriptors_ref, MatchThreshold) ;
num_points_WIPC(counter) = size(descriptors_other_view,2);
num_matches_WIPC(counter) = size(matches,2);
% xa = key_points_other_view(1,matches(1,:)) ;
% ya = key_points_other_view(2,matches(1,:)) ;
% 
% xb = key_points_ref(1,matches(2,:)) + 1280 ;
% yb = key_points_ref(2,matches(2,:)) ;

Ia = imread(path_img_other_view);
Ib = imread(path_ref_img);
figure
imagesc(cat(2, Ia, Ib)) ;
axis image off ;
hold on
% Plot matched points on both images
numMatches = size(matches, 2);
colors = lines(numMatches); % Generate distinct colors for each match

for i = 1:numMatches
    x1 = key_points_other_view(1,matches(1,i)) ;
    y1 = key_points_other_view(2,matches(1,i)) ;
    x2 = key_points_ref(1,matches(2,i)) + 1280 ;
    y2 = key_points_ref(2,matches(2,i)) ;
    
    plot( [x1, x2], [y1, y2], 'Color', colors(i, :), 'LineWidth', 1);
    plot( x1, y1, 'go', 'MarkerSize', 5, 'LineWidth', 2);
    plot( x2, y2, 'go', 'MarkerSize', 5, 'LineWidth', 2);
end

title( 'Matched Points without IPC');
hold off;


% Other view feature detection
path_img_warped_other_view = [main_path '4_Warping/img_flat_' num2str(other_view_frame_nb) '/Frame_lambda' num2str(lambda) '.png'];

mask_exist = 0;
[key_points_img_warped_other_view, descriptors_img_warped_other_view] = feature_detection_vlfeet(path_img_warped_other_view, ...
    [], mask_exist);
pause(.5)
figure , imshow(path_img_warped_other_view)

perm = randperm(size(key_points_img_warped_other_view,2)) ;
sel = perm(1:end) ;
h11 = vl_plotframe(key_points_img_warped_other_view(:,sel)) ;
h22 = vl_plotframe(key_points_img_warped_other_view(:,sel)) ;
set(h11,'color','k','linewidth',3) ;
set(h22,'color','y','linewidth',2) ;


[matches_IPC, scores_IPC] = vl_ubcmatch(descriptors_img_warped_other_view, descriptors_ref, MatchThreshold);

num_points_IPC(counter) = size(descriptors_img_warped_other_view,2);
num_matches_IPC(counter) = size(matches_IPC,2);

% find the position in the original image
xa_warped = key_points_img_warped_other_view(1,matches_IPC(1,:)) ;
ya_warped = key_points_img_warped_other_view(2,matches_IPC(1,:)) ;

key_points_other_view_IPC = [xa_warped',ya_warped'];
frompixel_wp = from_warped_to_original_matching_vlfeet(key_points_other_view_IPC, main_path, ...
    other_view_frame_nb, lambda);

% xa_other_view = frompixel_wp(:,1);
% ya_other_view = frompixel_wp(:,2);
% 
% xb = key_points_ref(1,matches(2,:)) + 1280 ;
% yb = key_points_ref(2,matches(2,:)) ;

% Ia = imread(path_img_other_view);
% Ib = imread(path_ref_img);
figure
imagesc(cat(2, Ia, Ib)) ;
axis image off ;
hold on
% Plot matched points on both images
numMatches = size(matches_IPC, 2);
colors = lines(numMatches); % Generate distinct colors for each match

for i = 1:numMatches
    x1 = frompixel_wp(i, 1);
    y1 = frompixel_wp(i, 2);
    x2 = key_points_ref(1,matches_IPC(2,i)) + 1280 ;
    y2 = key_points_ref(2,matches_IPC(2,i)) ;
    
    plot( [x1, x2], [y1, y2], 'Color', colors(i, :), 'LineWidth', 1);
    plot( x1, y1, 'go', 'MarkerSize', 5, 'LineWidth', 2);
    plot( x2, y2, 'go', 'MarkerSize', 5, 'LineWidth', 2);
end

title( 'Matched Points with IPC');
hold off;
close all

counter = counter +1;
end









