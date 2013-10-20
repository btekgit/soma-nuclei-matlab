function nPix = calculateInRadiusPix(gty, gtx, gtz, gtr, dtpix, sizeIm)

[ppy,ppx,ppz] = ind2sub(sizeIm, dtpix);

dists = (gtz-ppz).*(gtz-ppz)+(gty-ppy).*(gty-ppy)+(gtx-ppx).*(gtx-ppx);
nPix  = length(find(sqrt(dists)<=gtr));
if(0)

voly = ppy;
    volx = ppx;
    volz = ppz;
    
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
    
    msk(newI) = 56; 
end
    