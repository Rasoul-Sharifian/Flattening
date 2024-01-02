function points_selected = feature_detection(path_img , path_mask, mask_exist, orb_sift)

    I_rgb = imread(path_img);
    I = rgb2gray(I_rgb);

    if mask_exist==1
        mask = imread(path_mask);
        radius = 8;
        se = strel('disk', radius);
        mask = imerode(mask, se);
    else
        grayImage = rgb2gray(I_rgb);
        threshold = 230; % Adjust as needed
        binaryMask = grayImage < threshold;
        filledMask = imfill(binaryMask, 'holes');
        se = strel('disk', 3); % Adjust the radius as needed
        mask = imopen(filledMask, se);

        radius = 8;
        se = strel('disk', radius);
        mask = imerode(mask, se);
    end

    % radius = 40;
    % se = strel('disk', radius);
    % mask = imerode(mask, se);

    ContrastThreshold = .038;
    if strcmp(orb_sift , 'sift') == 1
        points = detectSIFTFeatures(I,'ContrastThreshold', ContrastThreshold);
    else
        % strcmp(orb_sift , 'orb') == 1;
            points = detectORBFeatures(I);
    end


    if islogical(mask) == 0
        [x,y] = find (mask == 255);
    else
        [x,y] = find (mask == 1);
    end

    locations = [y,x];
    
    % Filter keypoints to only include those at the specified locations
    points_selected = points(ismember(round(points.Location), locations, 'rows'));
    % figure ,
    % imshow(I_rgb);
    % hold on;
    % plot(points_selected )
end
