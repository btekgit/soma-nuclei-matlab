function numberOutRange = extractSomaGTVOIs(sizeIm,gtlist,grayFile, grayDataSet, mskFile, mskDataset,outputFolder)
% extract GT Vois from Gray Level Data and writes them independently to
% Hdf5File. the file name has the x_y_z_and radius info in the same order. 
% sprintf('soma_x%d_y%d_z%d_r%d', x(i),y(i),z(i), r(i)),'.h5');
% WindowK = 3;  controls the width-height-depth of the window to be
% extracted window size will be '2*WindowK+radius+1'
% BT 26.08.2013
% later, it can dump some random regions from the same slice. 
if nargin < 3
    grayFile = 'D:\mouse_brain\shawnnew\20130506-interareal_mag4\20130506-interareal_mag4\20130506-interareal_mag420130722_132814-x0-8_y0-6_z0-59.h5';
    grayDataSet = '/G1/20130722_132814';
    outputFolder = 'D:\mouse_brain\shawnnew\20130506-interareal_mag4\gtvoi\';
end

r = gtlist(:,3);
x = gtlist(:,4);
y = gtlist(:,5);
z = gtlist(:,6);
lengt = length(z);
WindowK = 32; 
ny = y-r-WindowK; 
py= y+WindowK+r;
nx = x-WindowK-r; 
px= x+WindowK+r;
nz = z-WindowK-r; 
pz= z+WindowK+r;

numberOutRange = 0; 
chnkSize = [32 32 32];
everyOther = 20;
k = 1; 
%% extract and
somas = cell(lengt,1);
somaDescription = cell(lengt,1);
for i = 1:everyOther: lengt
    i
    c_posy = WindowK+r(i);c_posx = WindowK+r(i);c_posz = WindowK+r(i);
    rangey = ny(i):1:py(i);
    % check y borders
    ycheck = rangey>0;
    if(~all(ycheck))
        shifty = find(ycheck,1);
        c_posy = c_posy-shifty;
        rangey = rangey(ycheck);
    end
    rangey = rangey(rangey<sizeIm(1));
    % check x borders
    rangex = nx(i):1:px(i);
    xcheck = rangex>0;
    if(~all(xcheck))
        shiftx = find(xcheck,1);
        c_posx = c_posx-shiftx;
        rangex = rangex(xcheck);
    end
    rangex = rangex(rangex<sizeIm(2));
    
    % check z borders
    rangez = nz(i):1:pz(i);
    zcheck = rangez>0;
    if(~all(zcheck))
        shiftz = find(zcheck,1);
        c_posz = c_posx-shiftz;
        rangez = rangez(zcheck);
    end
    rangez = rangez(rangez<sizeIm(3));
    
    if ( isempty(rangey)|isempty(rangex)|isempty(rangez))
        disp('skipping gt point out of range coordinates yxz:');
        disp([ny(i), nx(i), nz(i)])
        numberOutRange = numberOutRange+1
        if(nz(i)<0)
            strop = 1; 
        end
        continue;
    end
    
    startix = [rangex(1), rangey(1), rangez(1)];
    counts = [ length(rangex), length(rangey),length(rangez)];
    if ( any(chnkSize>counts))
        continue;
    end
    startix= fliplr(startix);
    counts = fliplr(counts);
    %msk = uint16(ones(length(rangez), length(rangey),length(rangex)));
    %size(msk)
    %gpx = ndgrid(rangey, rangex, rangez);
    
    graycube = h5read(grayFile, grayDataSet,startix, counts);
    graycube = permute(graycube, [2,3,1]);

    sizecube_z = size(graycube,3);sizecube_y = size(graycube,1);sizecube_x = size(graycube,2);
    
    voih5filename = strcat(outputFolder, sprintf('gray_x%d_y%d_z%d_r%d', x(i),y(i),z(i), r(i)),'.h5');
    flippable_size = [sizecube_z,sizecube_y,sizecube_x];
    h5create(voih5filename,'/soma',flippable_size,'Datatype','uint8', ...
                 'FillValue',uint8(0),'ChunkSize',chnkSize,'Deflate',1);
    h5writeatt(voih5filename,'/soma','SomaCenter_XYZ',[c_posx, c_posy, c_posz]);
    h5writeatt(voih5filename,'/soma','Ground Truth Index',[gtlist(i), i]);
    
    repermutecube = permute(graycube, [3,1,2]);
    h5write(voih5filename, '/soma',repermutecube,[1 1 1],flippable_size);
    
    somas{k} = graycube;
    somaDescription{k} = [gtlist(i), [c_posx, c_posy, c_posz]];
         %   msk(rangey,rangex,rangez) = i; 
end

save(strcat(outputFolder,'soma_',num2str(WindowK), '.mat'), 'somas', 'somaDescription');


