function [vs,log_R] = RodriguezRotate2ndOrd_inv(R)
vs = Rodrigues(R)';
return;
%   
% %Function to transform a set of rotation matricies R into rotation vectors
% %(axis-angle vectors.)
% %the magnitude of each vector is the rotation angle
% %R is a 3x3xn matrix, where n is the number of rotation matrices to
% %transform.
% %vs is a vector of dimension nx3, where the ith row corresponds with the
% %ith rotation matrix
% 
% %Toby Collins 2006
% %vs = vl_irodr(R)';
% %return;
% 
% numRs = size(R,3);
% if numRs==1
% t = R(1,1)+R(2,2)+R(3,3);
% %t = trace(R);
% theta = acos((t-1)/2);
% %if abs(theta-pi)<eps
%     %vs = Rodrigues(R);
%     %RR = RodriguezRotate2ndOrd(vs');
% %    error('not working');
% %end
% 
% if abs(theta-0)<eps
%     vs=[0,0,0];
%     log_R=zeros(3,3);
%     return;
% end
% 
% if abs(abs(R(3,3))-1)<1e-10
%    %a 2D rotation
%    vs=[0,0,R(3,3)]*acos(R(1,1));
%    R_ = RodriguezRotate2ndOrd(vs);
%    try
%    assert(norm(R_(:)-R(:))<1e-4);
%    catch
%        disp('error with rodriguez');
%        vs=[];
%    end
%    
%    return;
%    
% end
% 
% log_R = theta/(2*sin(theta))*(R-R');
% rz = -log_R(1,2);
% ry = log_R(1,3);
% rx = -log_R(2,3);
% vs=[rx,ry,rz];
% 
% else
%     error('must fix');
%     t = R(1,1,:)+R(2,2,:)+R(3,3,:);
%     theta = acos((t-1)/2);
%     RT = zeros(size(R));
%     RT(1:3,1,:)=R(1,1:3,:);
%     RT(1:3,2,:)=R(2,1:3,:);
%     RT(1:3,3,:)=R(3,1:3,:);
%     c=theta./(2*sin(theta));
%     c=repmat(c,[3,3,1]);
%     log_R=c.*(R-RT);
%     rz = -log_R(1,2,:);
%     ry = log_R(1,3,:);
%     rx = -log_R(2,3,:);    
%     vs=[rx(:),ry(:),rz(:)];
%     
%     fg = isnan(rz)|isnan(ry)|isnan(rx);
%     vs(fg,:) = 0;
% end


function R2 = Rodrigues(R1)

[r,c] = size(R1);

%% Rodrigues Rotation Vector to Rotation Matrix
if ((r == 3) && (c == 1)) || ((r == 1) && (c == 3))
    wx = [  0   -R1(3)  R1(2);
           R1(3)   0   -R1(1);
          -R1(2)  R1(1)   0   ];
      
    R1_norm = sqrt(R1(1)^2 + R1(2)^2 + R1(3)^2);
    
    if (R1_norm < eps)
        R2 = eye(3);
    else
        R2 = eye(3) + sin(R1_norm)/R1_norm*wx + (1-cos(R1_norm))/R1_norm^2*wx^2;
    end

%% Rotation Matrix to Rodrigues Rotation Vector
elseif (r == 3) && (c == 3)
    w_norm = acos((trace(R1)-1)/2);
    if (w_norm < eps)
        R2 = [0 0 0]';
    else
        R2 = 1/(2*sin(w_norm))*[R1(3,2)-R1(2,3);R1(1,3)-R1(3,1);R1(2,1)-R1(1,2)]*w_norm;
    end
end
