function transformed_points = transform_point(points, path_depth, I_rgb, I_ref, r_path, t_path, ...
    other_view_to_ref, coming_from_warp)
    d_I = imread(path_depth);
    d_I = double(d_I);

    % f1 = figure(4);
    % axesHandle1 = gca(f1);
    % imshow(I_rgb);
    % 
    % f2 = figure(5);
    % imshow(I_ref)
    % axesHandle2 = gca(f2);

    for i = 1:1:length(points)
        % Generate random RGB values
        color = rand(1, 3);

        % Pick up a pixel
        
        % if coming_from_warp == 0
        %     frompixel = points.Location(i,:);
        %     frompixel = round(frompixel);
        % else
        %     frompixel = points(i,:);
        %     frompixel = round(frompixel);
        % end

        if isnumeric(points) == 0
            frompixel = points.Location(i,:);
            frompixel = round(frompixel);
        else
            frompixel = points(i,:);
            frompixel = round(frompixel);
        end

        % hold (axesHandle1 , 'on');
        % plot(axesHandle1,frompixel(1),frompixel(2),'o','Color', color, 'MarkerSize', 4 , 'MarkerFaceColor', color)
        % hold (axesHandle1, 'off')

        %% De_Projection
        depth = d_I(frompixel(2),frompixel(1)) * 0.001; % Change the depth to meter

        % Color camera, and resolution 1280 * 720
        Fx = 910.718994140625;
        Fy = 908.876159667969;
        PPX = 634.168640136719;
        PPY = 355.472259521484;
        coeffs = [0 0 0 0 0];

        x = (frompixel(1) - PPX)/Fx;
        y = (frompixel(2) - PPY)/Fy;

        point(1) = depth * x;
        point(2) = depth * y;
        point(3) = depth;

        to_point = point;

        % Transform it to other camera coordinate
        r = load(r_path, '-ascii');
        t = load(t_path, '-ascii');

        transformation = [r,t;0 0 0 1];
        to_ref_transformation = inv(transformation);

        if other_view_to_ref == 1
        new_point = to_ref_transformation * [to_point';1];
        else
        new_point = transformation * [to_point';1];
        end

        [Px_new, Py_new] = Intel_projection_D415(new_point);
        Px_from(i) = Px_new;
        Py_from(i) = Py_new;

        % hold (axesHandle2 , 'on');
        % plot(axesHandle2,round(Px_new),round(Py_new),'o', 'Color', color, 'MarkerSize', 4, 'MarkerFaceColor', color)
        % hold (axesHandle2 , 'off');

        kk = 0;
    end
    transformed_points = [Px_from ; Py_from]';
end