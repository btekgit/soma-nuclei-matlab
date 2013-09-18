function writeMatlabCubeToHDF5inXYZOrder(fname, dataname, data, startpos,count,writeOr)
%function writeMatlabCubeToHDF5inXYZOrder(fname, dataname, data, startpos,count)
% give data in matlab as it is y,x,z
% give startposition xyz
startpos = fliplr(startpos);
count = fliplr(count);
dat3 = permute(data, [3,1,2]);
%subcube = permute(permute(data, [3, 2, 1]),[2,1,3]);
%
if (writeOr) 
    read_data = h5read(fname, dataname,startpos, count);
    intersectiondata = intersect(read_data(:), dat3(:));
    if(sum(intersectiondata(:))>0)
        disp('overlapping write intersects');
        dat3= max(read_data,dat3);
        
    else
        dat3= read_data + dat3;
    end
    
end
h5write(fname, dataname,dat3,startpos, count);
