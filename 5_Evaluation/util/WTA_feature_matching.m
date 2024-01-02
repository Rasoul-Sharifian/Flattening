function matched_indices = WTA_feature_matching(descriptor1, descriptor2, threshold)
    % Inputs:
    % descriptor1: Feature descriptors of image 1 (Nx128 matrix)
    % descriptor2: Feature descriptors of image 2 (Mx128 matrix)
    % threshold: Ratio test threshold for matching
    
    matched_indices = [];
    
    % Loop over each descriptor in descriptor1
    for i = 1:size(descriptor1, 1)
        distances = sqrt(sum((descriptor2 - descriptor1(i, :)).^2, 2));
        
        % Sort distances in ascending order
        [sorted_distances, sorted_indices] = sort(distances);
        
        % Apply ratio test
        if sorted_distances(1) < threshold * sorted_distances(2)
            matched_indices = [matched_indices; i, sorted_indices(1)];
        end
    end
    kk = 0;
end
