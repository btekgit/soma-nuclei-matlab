function nPix = calculateInRadiusPix(gty, gtx, gtz, gtr, dtpix, sizeIm)

[ppy,ppx,ppz] = ind2sub(sizeIm, dtpix);

dists = (gtz-ppz).*(gtz-ppz)+(gty-ppy).*(gty-ppy)+(gtx-ppx).*(gtx-ppx);
nPix  = length(find(sqrt(dists)<=gtr));