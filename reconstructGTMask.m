function msk = reconstructGTMask(sizcube,y,x,z,r)

%[gridy,gridx,gridz] = ndgrid(1:sizcube(1),1:sizcube(2),1:sizcube(3));
lengt = length(y);
if( lengt>65536)
    disp('maximum label size is 65536, possible problems: reconstructGTMask');
end
msk = uint16(zeros(sizcube)); %% Note assuming maximum 65535 labels
ny = y-r; 
py= y+r;
nx = x-r; 
px= x+r;
nz = z-r; 
pz= z+r;

for i = 1: lengt
    rangey = ny(i):1:py(i);
    rangey = rangey(rangey>0);
    rangey = rangey(rangey<sizcube(1));
    
    rangex = nx(i):1:px(i);
    rangex = rangex(rangex>0);
    rangex = rangex(rangex<sizcube(2));
    
    rangez = nz(i):1:pz(i);
    rangez = rangez(rangez>0);
    rangez = rangez(rangez<sizcube(3));
    
    %gpx = ndgrid(rangey, rangex, rangez);
    msk(rangey,rangex,rangez) = i; 
end
