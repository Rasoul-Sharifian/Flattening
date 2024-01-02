function common_points_tau = common_points(tau_range, frompixel, points_selected_ref, coming_from_warp)

counter = 1;    %%% Detection Covariency
common_points_tau = zeros(tau_range * 10 +1,1);
%frompixel = [Px_from',Py_from'];%points_selected.Location;

for tau = 0:.1:tau_range

    % if coming_from_warp == 0
    %     temp_array1 = points_selected_ref.Location;
    % else
    %     temp_array1 = points_selected_ref;
    % end
    % temp_array2 = frompixel;    % Loop through each element in array1

    if isnumeric(points_selected_ref) == 0
        temp_array1 = points_selected_ref.Location;
    else
        temp_array1 = points_selected_ref;
    end
    if isnumeric(frompixel) == 1
        temp_array2 = frompixel;
    else
        temp_array2 = frompixel.Location;
    end
    
    if size (temp_array2, 1) > size(temp_array1,1)
        array2 = temp_array2;
        array1 = temp_array1;
    else
        array1 = temp_array2;
        array2 = temp_array1;
    end

    for i = 1:size(array1,1)
        % Loop through each element in array2
        for j = 1:size(array2,1)
            % Calculate the distance between the elements
            distance = sqrt ( (array1(i,1) - array2(j,1)).^2 + ((array1(i,2) - array2(j,2)).^2 ));
            % Update minimum distance if smaller distance is found
            if distance < tau
                common_points_tau(counter) = common_points_tau(counter) + 1;
                break
            end
        end
    end
    counter = counter + 1;
end

end