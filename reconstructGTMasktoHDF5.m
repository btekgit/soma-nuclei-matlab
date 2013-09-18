function numberOutRange = reconstructGTMasktoHDF5(fname,dataname, sizeIm,gtlist)
flippable_size = [sizeIm(3) sizeIm(1), sizeIm(2)];
h5create(fname,dataname,flippable_size,'Datatype','uint16', ...
                 'FillValue',uint16(0),'ChunkSize',[100 100 100],'Deflate',1);
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
r = gtlist(:,3);
x = gtlist(:,4);
y = gtlist(:,5);
z = gtlist(:,6);
lengt = length(y);
ny = y-r; 
py= y+r;
nx = x-r; 
px= x+r;
nz = z-r; 
pz= z+r;

numberOutRange = 0; 

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
        if(nz(i)<0)
            strop = 1; 
        end
        continue;
    end
    
    startix = fliplr([rangex(1),rangey(1), rangez(1)]);
    counts = fliplr([ length(rangex), length(rangey),length(rangez)])
    msk = uint16(ones(length(rangez), length(rangey),length(rangex)));
    size(msk)
    %gpx = ndgrid(rangey, rangex, rangez);
    
    h5write(fname, dataname,msk,startix, counts);
         %   msk(rangey,rangex,rangez) = i; 
end

h5info(fname, dataname);
