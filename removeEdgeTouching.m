% removes edge touching detections
dt_pseudo_radius = (0.75*d.CC.areas/pi).^(1/3);
% r and x-y-z
dtlistordered = [dt_pseudo_radius, CC.centroids];
[dtlistInROI, dtIndx] = getGTInROI(dtlistordered, startpos, [dep,hei,wid],[hei,wid,dep],removeEdgeDT);
ndetections = length(dtlistInROI)
% dt_ctr = dtlistInROI(:,2:4);
% dt_pixlists = dt_pixlists(dtIndx);
% dt_bb = dt_bb(dtIndx,:);


CC2.Connectivity = CC.Connectivity;
CC2.ImageSize = CC.ImageSize;
CC2.areas = CC.areas(dtIndx);
CC2.centroids = CC.centroids(dtIndx,:);
CC2.bbx = CC.bbx(dtIndx,:);
CC2.NumObjects = ndetections;
CC2.PixelIdxList = CC.PixelIdxList(dtIndx);
CC = CC2;