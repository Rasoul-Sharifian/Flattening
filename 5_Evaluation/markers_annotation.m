clear 
close all
clc

imgName = 'color_frame_140';%'t2_k1_c';
imgPath = 'color_frame_140.png';%['t2_k1_c.JPG'];
outputPath = '';

numOfMarkers = 8;

fx = 4.17368e+03;%3.7722636826241278e+03;
fy = 4.17368e+03;%3.7646691173722265e+03;
cx = 4.23688e+03;%.4020727166813340e+03;
cy = 2.46202e+03;%1.5894527012485605e+03;
k1 = 0;%-3.6010969551559385e-02;
k2 = 0;%2.7193671289953196e-02;
k3 = 0;%1.5183266121050271e-01;
p1 = 0;%-5.3609771285830312e-04;
p2 = 0;%1.1887681773306122e-03;
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