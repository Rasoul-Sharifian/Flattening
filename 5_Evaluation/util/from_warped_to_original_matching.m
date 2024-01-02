function frompixel_wp = from_warped_to_original_matching(key_points_other_view, main_path, other_view_frame_nb, lambda)

[vflat , fflat] = readOBJ([main_path '3_Flattening/Flattened Meshes ' ...
    num2str(other_view_frame_nb) '/' num2str(lambda) '.obj']);

vflat = vflat';
vflat_new(1,:) = vflat(1,:);%round(1/1000 * (vflat(1,:) - min(vflat(1,:))) * size(Ia , 1));
vflat_new(2,:) = vflat(2,:);%round(1/1000 * (vflat(2,:) - min(vflat(2,:))) * size(Ia , 2));

outputSize_x = 900; %max(vflat_new(1,:));
outputSize_y = 900; %max(vflat_new(2,:));

counter_wp = 1;

[vimg , fimg] = readOBJ([main_path '2_Data Preprocessing/Masked meshes/' ...
    'Mesh_fram_' num2str(other_view_frame_nb) '_img_masked.obj']);%

vimg = vimg';
fimg = fimg';
fflat = fflat';
for wp = 1:length(key_points_other_view)
    if isnumeric(key_points_other_view) == 0
    xq = double(key_points_other_view.Location(wp,1));%points_selected.Location(:,1);
    yq = double(key_points_other_view.Location(wp,2));
    else
    xq = double(key_points_other_view(wp,1));%points_selected.Location(:,1);
    yq = double(key_points_other_view(wp,2));
    end
    for T = 1:size(fflat,2)
        Vo1 = vimg(1:2,fimg(1,T)); % Cartesian coordinates of the first vertex in output image
        Vo2 = vimg(1:2,fimg(2,T)); % Cartesian coordinates of the secend vertex in output image
        Vo3 = vimg(1:2,fimg(3,T)); % Cartesian coordinates of the third vertex in output image
        Vo = [Vo1 Vo2 Vo3 Vo1];

        Vi1 = vflat_new(1:2,fflat(1,T)); % Cartesian coordinates of the first vertex in input image
        Vi2 = vflat_new(1:2,fflat(2,T)); % Cartesian coordinates of the secend vertex in input image
        Vi3 = vflat_new(1:2,fflat(3,T)); % Cartesian coordinates of the third vertex in input image
        Vi = [Vi1 Vi2 Vi3 Vi1];

        xi = Vi(1,:)';
        yi = Vi(2,:)';

        in_on = inpolygon(xq, yq,xi, yi);

        [xs1, ys1] = find(in_on==1);
        id = find(in_on==1);

        xs1 = xs1(:);
        ys1 = ys1(:);

        C = [xq(in_on), yq(in_on)];

        VertexOut = [Vo1 Vo2 Vo3];
        temp_Fo = [1 , 2 , 3];

        VertexIn = [Vi1 Vi2 Vi3];
        temp_Fi = [1 , 2 , 3];

        TRo = triangulation(temp_Fo,VertexOut');
        TR_Flat = triangulation(temp_Fi,VertexIn');

        if C~=0
            B = cartesianToBarycentric(TR_Flat,ones(1,size(C,1))',C);
            Px(counter_wp) = B(:,1) * VertexOut(1,1) + B(:,2) * VertexOut(1,2) + B(:,3) * VertexOut(1,3);
            Py(counter_wp) = B(:,1) * VertexOut(2,1) + B(:,2) * VertexOut(2,2) + B(:,3) * VertexOut(2,3);
            counter_wp = counter_wp + 1;
            wp;
            kk = 5;
        
    else
        kk = 0;
    end
        clear C

    end
    ll = 0;
end

% for i = 1:1:length(key_points_other_view)
%     % Generate random RGB values
%     % Pick up a pixel
%     frompixel_wp = key_points_other_view.Location(i,:);
%     frompixel_wp = round(frompixel_wp);
% end


frompixel_wp = [Px',Py'];
% frompixel_wp = round(frompixel_wp);


end

