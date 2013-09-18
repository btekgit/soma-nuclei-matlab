function reconstructDetMaskToHdf5(fname,dataname, sizeIm,numObjects, pixelLists,bbx, mskIndex)

flippable_size = [sizeIm(3) sizeIm(1), sizeIm(2)];
h5create(fname,dataname,flippable_size,'Datatype','uint16', ...
                 'FillValue',uint16(0),'ChunkSize',[128 128 128],'Deflate',1);
if(nargin<5)
    % this is logical 
    mskIndex = 1:numObjects;
end
filecreated = 0;
OrOverlapping = 1; 
for i = 1:numObjects
    % x y z order 
    if(~mskIndex(i))
        continue;
    end
    i
    bb = ceil(bbx(i,:));
    % bb is originaly xyz 
    % size of the mask in z -y-x order
   % msk = uint16(zeros(bb(6), bb(5),bb(4)));
 
    % below is y,x, z
    %base = zeros(bbx(5), bbx(4),bbx(6));
    
    pix = (pixelLists{i});
    [py,px,pz] = ind2sub(sizeIm, pix);
    voly = py;
    volx = px;
    volz = pz;
    
    lowy = min(voly);
    leny = max(voly)-lowy+1;
    
    lowx = min(volx);
    lenx = max(volx)-lowx+1;
    
    lowz = min(volz);
    lenz = max(volz)-lowz+1;
    
    newpy = voly-lowy+1; 
    newpx = volx-lowx+1; 
    newpz = volz-lowz+1; 
%     newpz = newpz(newpz>0);
%     newpz = newpz(newpz<size(msk,3));
    
    msk = uint16(zeros(leny, lenx, lenz));   
    newI = sub2ind(size(msk),newpy, newpx, newpz);
    
    msk(newI) = i; 
    
    % these are xyz 
    startix = double([bb(1), bb(2), bb(3)]);
    counts = double([lenx,leny, lenz]);
    % now write it to the position. 
   
    %m2 = permute(msk, [3,1,2]);
    writeMatlabCubeToHDF5inXYZOrder(fname, dataname, msk, startix,counts,OrOverlapping);
    %h5write(fname, dataname,m2,startix, counts);

end


h5info(fname, dataname);


