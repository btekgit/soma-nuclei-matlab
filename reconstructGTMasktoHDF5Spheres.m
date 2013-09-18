function listOutRange = reconstructGTMasktoHDF5Spheres(fname,dataname, sizeIm,gtlist, binary)
flippable_size = [sizeIm(3) sizeIm(1), sizeIm(2)];
if ( binary==1)
h5create(fname,dataname,flippable_size,'Datatype','uint8', ...
                 'FillValue',uint8(0),'ChunkSize',[128 128 128],'Deflate',1);
else
h5create(fname,dataname,flippable_size,'Datatype','uint16', ...
                 'FillValue',uint16(0),'ChunkSize',[128 128 128],'Deflate',1);
end

% fid = H5F.create(fname, 'H5F_ACC_EXCL');
% type_id = H5T.copy(' H5T_NATIVE_UINT');
% dims = sizeIm;
% h5_dims = fliplr(dims);
% h5_maxdims = h5_dims;
% space_id = H5S.create_simple(3,h5_dims,h5_maxdims);
% dcpl = 'H5P_DEFAULT';
% dset_id = H5D.create(fid,'DS',type_id,space_id,dcpl);
% 
% mem_space_id = H5S.create_simple(3,h5_block,[]);
% file_space_id = H5D.get_space(dset_id);
% H5S.select_hyperslab(file_space_id,'H5S_SELECT_SET',h5_start,[],[],h5_block);
% data = rand(block);
% H5D.write(dset_id,'H5ML_DEFAULT',mem_space_id,file_space_id,plist,data);
% 
% 
% H5S.close(space_id);
% H5T.close(type_id);
% H5D.close(dset_id);
% H5F.close(fid);
% 
% gid = 
% H5F.close(fid);
%[gridy,gridx,gridz] = ndgrid(1:sizcube(1),1:sizcube(2),1:sizcube(3));

if( length(gtlist)>65536)
    disp('maximum label size is 65536, possible problems: reconstructGTMask');
end
%msk = uint16(zeros(sizcube)); %% Note assuming maximum 65535 labels
if(size(gtlist,2)==6)
    r = gtlist(:,3);
    x = gtlist(:,4);
    y = gtlist(:,5);
    z = gtlist(:,6);
else
    r = gtlist(:,1);
    x = gtlist(:,2);
    y = gtlist(:,3);
    z = gtlist(:,4);
end
lengt = length(y);
ny = y-r; 
py= y+r;
nx = x-r; 
px= x+r;
nz = z-r; 
pz= z+r;

numberOutRange = 0; 
listOutRange = zeros(150,4);
OrOverlapping = 1; 

for i = 1: lengt
    i
    rangey = ny(i):1:py(i);
    rangey = rangey(rangey>0);
    rangey = rangey(rangey<sizeIm(1));
    
    rangex = nx(i):1:px(i);
    rangex = rangex(rangex>0);
    rangex = rangex(rangex<sizeIm(2));
    
    rangez = nz(i):1:pz(i);
    rangez = rangez(rangez>0);
    rangez = rangez(rangez<sizeIm(3));
    if ( isempty(rangey)|isempty(rangex)|isempty(rangez))
        disp('skipping gt point out of range coordinates yxz:');
        disp([ny(i), nx(i), nz(i)])
        
        numberOutRange = numberOutRange+1
        listOutRange(numberOutRange,:) = [r(i), x(i), y(i), z(i)] ;
        if(nz(i)<0)
            strop = 1; 
        end
        continue;
    end
    
    %msk = uint8(zeros(length(rangez), length(rangey),length(rangex)));
    if binary 
        msk = uint8(zeros(length(rangey), length(rangex),length(rangez)));
    else
        msk = uint16(zeros(length(rangey), length(rangex),length(rangez)));
    end
    
    startix = double([rangex(1),rangey(1), rangez(1)]);
    counts = double([ length(rangex), length(rangey),length(rangez)]);
    
    %% adding this for sphere
    [sy,sx,sz] = size(msk);
    cy = (sy/2); cx = (sx/2); cz = (sz/2); 
    [gy,gx,gz]  = ndgrid(1:length(rangey), 1:length(rangex), 1:length(rangez));
    %[gz,gy,gx]  = ndgrid(1:length(rangez), 1:length(rangey), 1:length(rangex));
    dist1 = sqrt((gy-cy).^2+(gx-cx).^2+(gz-cz).^2);
    spher = dist1<r(i);
    if binary
        msk(spher) = uint8(1); 
    else
        msk(spher) = uint16(i); 
    end
    
    %%
    writeMatlabCubeToHDF5inXYZOrder(fname, dataname, msk, startix, counts,OrOverlapping);
    %h5write(fname, dataname,msk,startix, counts);
         %   msk(rangey,rangex,rangez) = i; 
end

h5info(fname, dataname);
