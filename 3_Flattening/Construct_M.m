function M = Construct_M(V , f)

M = zeros(2*size(f,1) , 2*size(V,1)); % Size M is: 2*n-tri ** 2*n-vert
for T = 1:size(f,1) % for each triangle
    V0_3d = V(f(T,1),:);
    V1_3d = V(f(T,2),:);
    V2_3d = V(f(T,3),:);

    Xs_3d = [V0_3d(1) V1_3d(1) V2_3d(1) V0_3d(1)];
    Ys_3d = [V0_3d(2) V1_3d(2) V2_3d(2) V0_3d(2)];
    Zs_3d = [V0_3d(3) V1_3d(3) V2_3d(3) V0_3d(3)];

%     figure , plot3(Xs_3d,Ys_3d,Zs_3d)
%     grid on

    % # construct an orthonormal 3d basis
    X = V1_3d - V0_3d;
    X = X/norm(X);
    Z = cross(X, (V2_3d - V1_3d));
    Z = Z/norm(Z);
    Y = cross(Z , X);

    % # project the triangle to the 2d basis (X,Y)
    z0 = [0,0];
    z1 = [norm(V1_3d - V0_3d) , 0];
    z2 = [dot((V2_3d - V0_3d), X) , dot((V2_3d - V0_3d), Y)];

    Xs_2d = [z0(1) z1(1) z2(1) z0(1)];
    Ys_2d = [z0(2) z1(2) z2(2) z0(2)];

%     figure , plot(Xs_2d , Ys_2d)
%     grid on
%     axis equal

    Q0 = z0;
    Q2 = (z1 - z0)/2;
    Q1 = [0 -1;1 0] * Q2';

%     hold on
%     plot(Q0(1) , Q0(2) ,'+')
%     text(Q0(1), Q0(2),'\leftarrow Q0')
% 
%     plot(Q1(1) , Q1(2) ,'+')
%     text(Q1(1), Q1(2),'\leftarrow Q1')
% 
%     plot(Q2(1) , Q2(2) ,'+')
%     text(Q2(1), Q2(2),'\leftarrow Q2')
%     axis equal

    P = [z0;z1;z2];
    T_temp = [1 2 3];
    TR = triangulation(T_temp,P);
    % figure , triplot(TR)

    B0 = [1 0 0];%cartesianToBarycentric(TR,1,Q0)
    B1 = cartesianToBarycentric(TR,1,Q1');
    B2 = [.5 .5 0];%cartesianToBarycentric(TR,1,Q2)

    %Building matrix M

    gradB2 = B2 - B0;
    gradB1 = B1 - B0;

    M(2*T - 1 , f(T,1)*2-1) = -gradB2(1);
    M(2*T - 1 , f(T,1)*2) = gradB1(1);
    M(2*T - 1 , f(T,2)*2-1) = -gradB2(2);
    M(2*T - 1 , f(T,2)*2) = gradB1(2);
    M(2*T - 1 , f(T,3)*2-1) = -gradB2(3);
    M(2*T - 1 , f(T,3)*2) = gradB1(3);

    M(2*T , f(T,1)*2-1) = -gradB1(1);
    M(2*T , f(T,1)*2) = -gradB2(1);
    M(2*T , f(T,2)*2-1) = -gradB1(2);
    M(2*T , f(T,2)*2) = -gradB2(2);
    M(2*T , f(T,3)*2-1) = -gradB1(3);
    M(2*T , f(T,3)*2) = -gradB2(3);
   
    kk = 0
end
end