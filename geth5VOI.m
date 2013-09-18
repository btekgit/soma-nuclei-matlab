% this simple script cuts a part of the big h5 file for training. 
% does not work because of order permutations which I need to think of. 

fin = 'D:\mouse_brain\shawnnew\20130506-interareal_mag4\20130506-interareal_mag4\20130506-interareal_mag420130730_001802-x0-8_y0-6_z0-10_results.h5'
dsetin = '/G1/20130730_001802'
order = 'cxyz';
fout= 'D:\mouse_brain\shawnnew\20130506-interareal_mag4\20130506-interareal_mag4\20130506-interareal_mag420130730_001802-x0-8_y0-6_z0-10_results_train_part.h5'
dsetout = '/G1/trainpart'
inf1 = h5info(fin,dsetin);
nC = inf1.Dataspace.Size(1);
nZ = inf1.Dataspace.Size(2);
nX = inf1.Dataspace.Size(4);
nY = inf1.Dataspace.Size(3);
chunkSize = inf1.ChunkSize;

rect_startix = [1 1 1 1];
rect_count = [2 512 128 384];
% if larger than 100Mbs divide it read it in parts
divs =1; 
MAX_MEM= 100000000;
if(prod(rect_count) > MAX_MEM)
    divs = ceil(      
end

dt=h5read(fin, dsetin, rect_startix, rect_count);

if strcmp(order,'cxyz')

else
    
h5write(outputfname, dsetname2, dt2);
end


nC = inf1.Dataspace.Size(1);
fid = H5F.open(fin,'H5F_ACC_RDONLY','H5P_DEFAULT'); 
%gid = H5G.open(fid, '/G1');
did = H5D.open(fid, dsetname);

H5F.close(fid);

dt = h5read(fname, dsetname, rect_startix, rect_count);
%dt2=  permute(permute(dt, [4, 3, 2, 1]),[2,1,3,4]);
h5create(outputfname,dsetname2,rect_count,'ChunkSize',[100 100 100 2], 'Deflate', 1);
h5write(outputfname, dsetname2, dt2);


