function writeXYZR2txt(fname,varargin)

fid = fopen(fname, 'wt');
if (nargin ==2)
    d = varargin{1};
    y = d(:,2);
    z = d(:,3);
    r = d(:,4);
    x = d(:,1);
elseif(nargin<5)
    error('provide x,y,z,r');
end
len = length(x);
for i = 1:len
fprintf(fid, '%d,%d,%d,%d\n', x(i),y(i), z(i), r(i));
end
fclose(fid);    

end
