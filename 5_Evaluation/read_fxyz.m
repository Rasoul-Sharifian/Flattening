function A = read_fxyz(filename)

%% read positions
format long
fileID = fopen(filename,'r');

opts = detectImportOptions(filename);
opts.VariableNames = {'x','y','z'};
opts.VariableTypes = {'double','double','double'};
A = readtable(filename,opts);
 
%  A_id= A.ID(:);
 Ax = A.x(:);
 Ay = A.y(:);
 Az = A.z(:);


% ID = typecast(A_id,'string');
X = typecast(Ax,'double');
Y = typecast(Ay,'double');
Z = typecast(Az,'double');
A = [X,Y,Z];