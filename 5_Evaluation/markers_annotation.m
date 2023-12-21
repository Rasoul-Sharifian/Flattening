clear all
close all
clc

imgName = 't2_k1_c';
imgPath = ['/media/yamito/yamo/trocar_estimation/yamid_trocar_estimation/experiments/pointing_experiments/tool_poses_external_camera/experiments_all/images_all/navid/Result/' imgName '.JPG'];
outputPath = '/media/yamito/yamo/trocar_estimation/yamid_trocar_estimation/experiments/pointing_experiments/markers2D/experiments_all/navid/';

numOfMarkers = 8;

fx = 3.7722636826241278e+03;
fy = 3.7646691173722265e+03;
cx = 2.4020727166813340e+03;
cy = 1.5894527012485605e+03;
k1 = -3.6010969551559385e-02;
k2 = 2.7193671289953196e-02;
k3 = 1.5183266121050271e-01;
p1 = -5.3609771285830312e-04;
p2 = 1.1887681773306122e-03;
InterMat = [fx,0,0;0,fy,0;cx,cy,1];
cameraParams = cameraParameters('IntrinsicMatrix', InterMat,'RadialDistortion',[k1,k2,k3],'TangentialDistortion',[p1,p2]);

im = imread(imgPath);
imu = undistortImage(im,cameraParams);
figIm = figure;
imshow(imu);
for i=1:numOfMarkers
    title(['Select marker #' num2str(i)]);
    marker = drawpoint('SelectedColor','red');
    markerCoords{i} = marker.Position;

end
pause;
close(figIm);
save([outputPath imgName '.mat'],'markerCoords');