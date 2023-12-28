clear all
clc 
% addpath /home/yamito/Documents/trocar_estimation/yamid_trocar_estimation/code_validation_dataset/pnp_registration_app/main
% addpath /home/yamito/Documents/trocar_estimation/yamid_trocar_estimation/code_validation_dataset/EPnP
% addpath /home/yamito/Documents/trocar_estimation/yamid_trocar_estimation/experiments/deformed_models/phantom3
% addpath /home/yamito/Documents/trocar_estimation/yamid_trocar_estimation/experiments/videos/experiments_all
% addpath /home/yamito/Documents/trocar_estimation/yamid_trocar_estimation/experiments/pointing_experiments/tool_poses_external_camera/experiments_all/images_all/navid/Result
% addpath /home/yamito/Documents/trocar_estimation/yamid_trocar_estimation/experiments/pointing_experiments/markers2D/experiments_all/navid

imgPath =  'intel_02_Color.png';%['t2_k1_c.JPG'];
% imgPath = '/home/yamito/Documents/trocar_estimation/yamid_trocar_estimation/experiments/pointing_experiments/tool_poses_external_camera/experiments_all/images_all/navid/Result';
annotationsPath = '/media/rasoul/830873c3-8201-4a0c-8abe-39d71bdf67d7/Flattening/07_08_2023_Git/5_Evaluation/';
% annotationsPath = '/home/yamito/Documents/trocar_estimation/yamid_trocar_estimation/experiments/pointing_experiments/markers2D/experiments_all/navid';
% posesPath = '/home/yamito/Documents/trocar_estimation/yamid_trocar_estimation/experiments/pointing_experiments/phantom_poses_external_camera/experiments_all/navid';

% [s,k,kr,kt] = loadcalib('calibration_external_camera.xml');
% camIntrinsics = cameraIntrinsics(k(1), [k(7) k(8)],s,'RadialDistortion', kr,'TangentialDistortion',kt);
% cameraParams = cameraParameters('IntrinsicMatrix',camIntrinsics.IntrinsicMatrix,'RadialDistortion',camIntrinsics.RadialDistortion, ...
%     'TangentialDistortion',camIntrinsics.TangentialDistortion);

fx = 4.17368e+02;%3.7722636826241278e+03;
fy = 4.17368e+02;%3.7646691173722265e+03;
cx = 4.23688e+02;%.4020727166813340e+03;
cy = 2.46202e+02;%1.5894527012485605e+03;
k1 = 0;%-3.6010969551559385e-02;
k2 = 0;%2.7193671289953196e-02;
k3 = 0;%1.5183266121050271e-01;
p1 = 0;%-5.3609771285830312e-04;
p2 = 0;%1.1887681773306122e-03;
InterMat = [fx,0,0;0,fy,0;cx,cy,1];
cameraParams = cameraParameters('IntrinsicMatrix', InterMat,'RadialDistortion',[k1,k2,k3],'TangentialDistortion',[p1,p2]);


% % read-ligaments
% lig = 'ligamentPositions.txt';
% ligpos = read_fsxyz(lig);

% read-markers
mark= 'markerPositions.txt';
markpos = read_fsxyz(mark);

% write down the marker names you want to search for in order
M1 = find(contains(markpos,'Cube.124'));
M2 = find(contains(markpos,'Cube.413'));
M3 = find(contains(markpos,'Cube.286'));
M4 = find(contains(markpos,'Cube.003'));
M5 = find(contains(markpos,'Cube.389'));
M6 = find(contains(markpos,'Cube.000'));
M7 = find(contains(markpos,'Cube.516'));
M8 = find(contains(markpos,'Cube.078'));

M11 = markpos(M1,:); 
M22 = markpos(M2,:); 
M33 = markpos(M3,:); 
M44 = markpos(M4,:);
M55 = markpos(M5,:);
M66 = markpos(M6,:); 
M77 = markpos(M7,:); 
M88 = markpos(M8,:); 

% Load 2D correspondences and compute transformation matrix:
matFiles = dir([annotationsPath '/*.mat']);      
nfiles = length(matFiles);    % Number of files found
for ii=1:nfiles
%     imgName = 'tumor1_from_trocar1_to_camera';
    % filename = matFiles(ii).name;
    % filenameSplit = split(filename,'.');
    % filenameNoExt = filenameSplit{1};
    % 
   % load(['t2_k1_c.mat'])
    load(['intel_02_Color.mat'])

    x3d_x = [[M11(:,2:4)]',[M22(:,2:4)]',[M33(:,2:4)]',[M44(:,2:4)]',[M55(:,2:4)]',[M66(:,2:4)]',[M77(:,2:4)]',[M88(:,2:4)]'];
    x3d = str2double(x3d_x);
    x2d = [[markerCoords{1}(1) markerCoords{1}(2)]',[markerCoords{2}(1) markerCoords{2}(2)]',[markerCoords{3}(1) markerCoords{3}(2)]',[markerCoords{4}(1) markerCoords{4}(2)]',[markerCoords{5}(1) markerCoords{5}(2)]',[markerCoords{6}(1) markerCoords{6}(2)]',[markerCoords{7}(1) markerCoords{7}(2)]',[markerCoords{8}(1) markerCoords{8}(2)]'];

    x3d_hx = [[M11(:,2:4) 1]',[M22(:,2:4) 1]',[M33(:,2:4) 1]',[M44(:,2:4) 1]',[M55(:,2:4) 1]',[M66(:,2:4) 1]',[M77(:,2:4) 1]',[M88(:,2:4) 1]'];
    x3d_h = str2double(x3d_hx);
    x2d_h = [[markerCoords{1}(1) markerCoords{1}(2) 1]',[markerCoords{2}(1) markerCoords{2}(2) 1]',[markerCoords{3}(1) markerCoords{3}(2) 1]',[markerCoords{4}(1) markerCoords{4}(2) 1]',[markerCoords{5}(1) markerCoords{5}(2) 1]',[markerCoords{6}(1) markerCoords{6}(2) 1]',[markerCoords{7}(1) markerCoords{7}(2) 1]',[markerCoords{8}(1) markerCoords{8}(2) 1]'];

    % intrin = camIntrinsics.IntrinsicMatrix;
    m=1;
    A1=[fx/m 0 fy/m 0; 0 cx/m cy/m 0; 0 0 1 0];%[k(1)/m 0 k(7)/m 0; 0 k(1)/m k(8)/m 0; 0 0 1 0];
    A1 = A1(:,1:3);

%     [R2,T2]=efficient_pnp(x3d_h',x2d_h',A1);

    K=[fx/m 0 fy/m; 0 cx/m cy/m; 0 0 1];%[k(1)/m 0 k(7)/m; 0 k(1)/m k(8)/m; 0 0 1];
    x2d_n = homoMult(inv(K),x2d')';
    [R,T] = PnPWithLM_RPNP(x3d,x2d_n);

    P_n = A1*[R T]*x3d_h;

    P_nN(1:2,:)= P_n(1:2,:) ./ P_n(3,:);

    x2d_h(1:2,:);

    error = P_nN(1:2,:)-x2d_h(1:2,:);

    % figure
    % imshow('testim1.png')
    % hold on
    % scatter(P_nN(1,:),P_nN(2,:))  %% normalized_points
    % scatter(Px,Py);   %% projected points
    % 
    % hold on

    mp_h = [str2double(markpos(:,2:4)'); ones(1,535)];

    P_nA = A1*[R T]*mp_h;

    %%transform2 
    tmp_h = [R T] * mp_h;
    tmp_h = tmp_h(1:3,:);

    P_nAA = [];
    P_nAA(1:2,:)= P_nA(1:2,:) ./ P_nA(3,:);

    markn = markpos;
    markn(:,1) = erase(markn(:,1),'ube.');

    norms = read_fxyz('normals.txt');

    % tnorms = R*[[1;0;0] [0;-1;-1] [0;1;-1]]*norms';
    tnorms = R*norms';
    for iMarker=1:size(tnorms,2)
       isVisible(iMarker) = (-tmp_h(:,iMarker)'*tnorms(:,iMarker))>0; 
    end
    
    % Save transformation into the corresponding mat file:
    filenameNoExt = 'intel_02_Color';%'t2_k1_c';
    posesPath = 'posesPath';
    save([posesPath '/' filenameNoExt '.mat'],'R','T');

    % im = imread([filenameNoExt '.JPG']);
    im = imread([filenameNoExt '.png']);

    undistortedIm = undistortImage(im,cameraParams);
    figure
    imshow(undistortedIm)
    title(filenameNoExt,'Interpreter','none');
    hold on

    % Point masking. Keep only the visible points.
    P_nAA = P_nAA(:,isVisible);
    markn = markn(isVisible,:);
    x_val = P_nAA(1,:);
    y_val = P_nAA(2,:);
    m_val = markn(:,1);
    scatter(x_val,y_val,'x')
    text(x_val,y_val,m_val)

    % Plot registered mesh:
    msh = read3dMesh(['deformedMesh.obj']);
    M = [R,T];
    M(4,4) = 1;
    Q = homoMult(M,msh.vertexPos);
    q = K*Q';
    qx = q(1,:)./q(3,:);
    qy = q(2,:)./q(3,:);
    %scatter(qx,qy)

    pause;

end
