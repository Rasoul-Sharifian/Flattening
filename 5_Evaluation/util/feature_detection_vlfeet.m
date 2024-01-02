function [key_points_masked, descriptors_masked] = feature_detection_vlfeet(path_img , path_mask, mask_exist)

    I_rgb = imread(path_img);
    I = single(rgb2gray(I_rgb));

    if mask_exist==1
        mask = imread(path_mask);
        radius = 6;
        se = strel('disk', radius);
        mask = imerode(mask, se);
    else
        grayImage = rgb2gray(I_rgb);
        threshold = 230; % Adjust as needed
        binaryMask = grayImage < threshold;
        filledMask = imfill(binaryMask, 'holes');
        se = strel('disk', 3); % Adjust the radius as needed
        mask = imopen(filledMask, se);

        radius = 6;
        se = strel('disk', radius);
        mask = imerode(mask, se);
    end

    % radius = 40;
    % se = strel('disk', radius);
    % mask = imerode(mask, se);

    [key_points, descriptors] = vl_sift(I) ;

    if islogical(mask) == 0
        [x,y] = find (mask == 255);
    else
        [x,y] = find (mask == 1);
    end

    locations = [y,x];

    % Filter keypoints to only include those at the specified locations
    points_rounded = round(key_points)';
    points_rounded = points_rounded(:, 1:2);
    key_points_masked = key_points(:,ismember(points_rounded, locations, 'rows'));
    descriptors_masked = descriptors(:,ismember(points_rounded, locations, 'rows')); 
end
