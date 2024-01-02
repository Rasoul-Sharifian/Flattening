function A = read_fsxyz(filename)

%% read positions
format long
fileID = fopen(filename,'r');

opts = detectImportOptions(filename);
opts.VariableNames = {'ID','x','y','z'};
opts.VariableTypes = {'string','double','double','double'};
A = readtable(filename,opts);
 
 A_id= A.ID(:);
 Ax = A.x(:);
 Ay = A.y(:);
 Az = A.z(:);


% ID = typecast(A_id,'string');
X = typecast(Ax,'double');
Y = typecast(Ay,'double');
Z = typecast(Az,'double');
A = [A_id,X,Y,Z];
