    % The whole optimisation problem
% Our barycentric conformal term + grid
% SVD approach

clc
clear
% close all
gridsize = 15;

for frmam_ind = [0 17 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 115]
path = ['../2_DataPreprocessing/Masked meshes gs' num2str(gridsize) '/Mesh_fram_', num2str(frmam_ind), '_3d_masked.obj'];

[v, f] = readOBJ(path) ;

% figure , plot_mesh(v,f)
% title('3d mesh')
% shading faceted; axis tight;
% pause(1)
path_img = ['../2_DataPreprocessing/Masked meshes gs' num2str(gridsize) '/Mesh_fram_', num2str(frmam_ind), '_img_masked.obj'];
[v_img, f_img] = readOBJ(path_img) ;
p0 = zeros(size(v_img ,1) * 2 ,1);
p0(1:2:end) = v_img(:,1);
p0(2:2:end) = v_img(:,2);

% figure , plot_mesh(v_img,f_img)
% title('3d mesh')
% shading faceted; axis tight;
% pause(1)

M = Construct_M(v , f);
I = eye(size(v,1) * 2);
counter = 1;


for lambda = 0:.001:1
    tic
    mu_grid = .0050 ;
    mu_angle = .20 ;
    epsilon = .00001;
    M2 = [mu_angle * (1/(size(f,1)*3)) * lambda * M; mu_grid * (1/size(v,1)) * ((1 - lambda)) * I];
    p00 = [zeros(size(f,1) * 2 ,1);mu_grid * (1/size(v,1)) * max((1 - lambda),epsilon) * p0];

    x = inv(M2'*M2)*M2'*p00;
    % x_pinv = pinv(M2);
    toc
%     cost(counter) = sum((M2 * x - p00)' * (M2 *x - p00));
%     
%     cost_angle(counter) =  (1/(size(f,1)*3)) * (sum((M*x)'*(M*x)));
%     cost_grid(counter) =  (1/size(v,1)) *  (sum((x - p0)'*(x - p0)));

    x_show = [x(1:2:end) , x(2:2:end)];

    folderName = ['Flattened Meshes ' 'gs' num2str(gridsize) '/Frame ', num2str(frmam_ind)];

if ~exist(folderName, 'dir')
    mkdir(folderName);
    fprintf('Folder "%s" created.\n', folderName);
else
    fprintf('Folder "%s" already exists.\n', folderName);
end
    writeOBJ([folderName ,'/lambda ' num2str(counter) '.obj'] , x_show,f)
    counter = counter +1
    scale(counter) = norm(x);
%     figure , plot_mesh(x_show,f)
%     title('flat mesh svd x')
%     shading faceted; axis tight;
%     pause(1)
end
end
% fig = figure('Position', [100, 100, 1280, 720]);
% ax = axes('Parent', fig);
% axis(ax, 'equal');
% axis(ax, 'off');
% 
% colormap(jet); % Use a color map to add color to the mesh
% light('Position', [1, 1, 1]); % Add a light source to create shading'
% for i = [ 10000:-1:9940 9939:-40:1] %  9999:-1:9941
%     
%     [v, f] = readOBJ(['out/' num2str(i) '.obj']) ;
%     trimesh(f, v(:,1),v(:,2),v(:,3))
%     view(45, 70); % Change the camera angle to show different perspectives
%     ylim([0 800])
%     xlim([350 1400])
%     i_title = i/10000;
% %     'Position', [0.5, -0.1, 0]);
%     title(sprintf('Lambda: %.2f', i_title));
% 
%     drawnow;
%         % Capture frame and write to video
% %     frame = getframe(fig);
% %     writeVideo(vidObj, getframe(fig)); % Add the current frame to the movie
%     pause(.001)
% end



figure , plot(0:.001:1, cost_angle)
hold on
figure , plot(0:.001:1, cost_grid)
hold on
figure, plot(0:.001:1, cost)

xlabel('lambda')
legend('Cost_{angle}', 'Cost_{grid}', 'Cost_{total}')
title(sprintf('mu angle: %.2f mu grid %.2f ', mu_angle, mu_grid)) 
grid on
grid minor

% % Solve it with svd decomposition
% % Calculate the pseudoinverse of matrix M2
% [U, S, V] = svd(M2);
% S_prim = 1./S;
% S_inv = zeros(size(S_prim')) ;
% S_inv(1:size(S,2),1:size(S,2)) = diag(diag(S_prim'));
% x2 = V * S_inv * U' * p00;
% x2_show = [x2(1:2:end) , x2(2:2:end)];
% figure , plot_mesh(x2_show,f)
% title('flat mesh svd x2')
% shading faceted; axis tight;
% pause(1)