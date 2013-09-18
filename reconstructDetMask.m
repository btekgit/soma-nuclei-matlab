function [bbmsk, pixmsk] = reconstructDetMask(CC)
imgsize = CC.ImageSize;
bbmsk = uint16(zeros(imgsize));
if nargout ==2 
    pixmsk =uint16(zeros(imgsize));
end

for i = 1:CC.NumObjects
    % x y z order 
    bb = int32(CC.bbx(i,:));
    bbmsk(bb(2):bb(2)+bb(5)-1, bb(1):bb(1)+bb(4)-1,bb(3):bb(3)+bb(6)-1) = i;
    if nargout ==2
        pixid = CC.PixelIdxList{i};
        pixmsk(pixid) = i; 
    end
end


