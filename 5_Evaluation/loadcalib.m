function [size,k,kr,kt] = loadcalib(calib)
%  fx,fy,cx,cy,skew,k1,k2,k3,width,height

% cal = [path '/calib.xml'];

mlcalib = parseXML(calib);

width = mlcalib.Children(4).Children.Data;
height = mlcalib.Children(6).Children.Data;
fx = mlcalib.Children(8).Children.Data;
fy = mlcalib.Children(10).Children.Data;
cx = mlcalib.Children(12).Children.Data;
cy = mlcalib.Children(14).Children.Data;
skew = mlcalib.Children(16).Children.Data;
k1r = mlcalib.Children(18).Children.Data;
k2r = mlcalib.Children(20).Children.Data;
k3r = mlcalib.Children(22).Children.Data;
k1t = mlcalib.Children(26).Children.Data;
k2t = mlcalib.Children(28).Children.Data;


width = str2num(width);
height = str2num(height);
size=[width,height];
k = [str2num(fx),str2num(skew),str2num(cx);0.0,str2num(fy),str2num(cy);0.0,0.0,1.0];
k1r = str2double(k1r);
k2r = str2double(k2r);
k3r = str2double(k3r);

kr = [k1r,k2r,k3r];


k1t = str2double(k1t);
k2t = str2double(k2t);

kt = [k1t,k2t];

sensorsize = [{'width'},{'height'}]
K = [{'F_u'}, {'Skew'}, {'cx'};{'0.0'},{'Fv'},{'cy'};{'0,0'},{'0.0'},{'1.0'}]

end

