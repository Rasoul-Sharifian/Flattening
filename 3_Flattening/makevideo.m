clc
clear
% close all

% Set up the figure and axis
fig = figure('Position', [100, 100, 1280, 720]);
ax = axes('Parent', fig);
axis(ax, 'equal');
axis(ax, 'off');

colormap(jet); % Use a color map to add color to the mesh
light('Position', [1, 1, 1]); % Add a light source to create shading'

% Set up the movie
vidObj = VideoWriter('mesh_animation70.avi'); % Replace 'mesh_animation.avi' with your desired output filename
vidObj.FrameRate = 8; % Set the frame rate of the movie (frames per second)
open(vidObj);

% Loop over each mesh in the sequence and add it to the movie
for i = [   1000:-1:950 950:-20:1] % 10000:-1:9935
    
    [v, f] = readOBJ(['Flattened Meshes 70/' num2str(i) '.obj']) ;
    trimesh(f, v(:,1),v(:,2),v(:,3))
    view(45, 70); % Change the camera angle to show different perspectives
    ylim([150 750])
    xlim([150 750])
    i_title = i/10000;
%   'Position', [0.5, -0.1, 0]);
    title(sprintf('Lambda: %.4f', i_title));
% 
    drawnow;
%        Capture frame and write to video
    frame = getframe(fig);
    writeVideo(vidObj, getframe(fig)); % Add the current frame to the movie
    pause(.0001)
% dblA(i) = mean(My_doublearea(v,f))/2;
i
end
close(vidObj);
% close
% Clean up
figure , plot(0.0001:.0001:1 , dblA)
grid on
grid minor
xlabel ('\lambda')
ylabel('Average triangles area')
