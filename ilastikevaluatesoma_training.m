%ilastikevaluatesoma.m
% this loads connected component labels gernerated by
% calculate_detection_bb and calculates hit miss rates. 
% this is called  simple.
%save(str)cat(fname,'detectionbb_mxlabel.mat'),'mxlabel','ccpixlistI', 'centroids', 'bbx', 'areas');
%fnam = 'D:\mouse_brain\shawnnew\20130506-interareal_mag4\20130506-interareal_mag4\cc_smallish.h5'
root = 'D:\mouse_brain\shawnnew\ccout\training\'
%d = load (strcat(root,'cc_th_90.h5detectionbb_mxlabel_all_regionProps.matcc_processed.mat'));
d = load (strcat(root,'cc_th_50.h5detectionbb_mxlabel_all_regionProps.matcc_processed.mat'));
%d = load(strcat(root, 'cc_th_90.h5detectionbb_mxlabel_all_regionProps.matcc_processed.mat'));
%d.CC = d.newCC;


gt = load('gtintereal20130506.mat') %gives validannotations.
gt.processed = zeros(length(gt.validannotations),1);
gt.hits = zeros(length(gt.validannotations),3);

% volume dimensions. 
startpos = [1 1 1];
wid = 512;
hei = 384;
dep = 320;


% another threshold here to fine tune small regions. 
% area_th = 0;
% Ivalid = find(d.CC.areas>area_th);
% ndetections = length(Ivalid)
% dt_bb = d.CC.bbx(Ivalid,:); %%% xyZ order//
% dt_ctr = d.CC.centroids(Ivalid,:);
% dt_pixlists= d.CC.PixelIdxList(Ivalid);
%dt_fullhit = zeros(ndetections,1);
% take the valid annotations for this VOI
ndetections = length(d.CC.areas)
dt_bb = d.CC.bbx;
dt_ctr = d.CC.centroids;
dt_pixlists = d.CC.PixelIdxList;

gtlist = gt.validannotations;
lengt= length(gtlist);
[gtlistInROI, gtIndx, gtMask] = getGTInROI(gtlist, startpos, [dep,hei,wid],[hei,wid,dep]);
numberOfGtPointsinRoi = length(gtlistInROI)
gtr = gtlistInROI(:,1);
gtx = gtlistInROI(:,2);
gty = gtlistInROI(:,3);
gtz = gtlistInROI(:,4);
imSize = d.CC.ImageSize;

gtlistreordered =[gtx,gty,gtz,gtr];


[bbxMask, pixMask] = reconstructDetMask(d.CC);

% overlap
msk_intersection = pixMask .* uint16(gtMask);
msk_intersection_labelled = bwconncomp(msk_intersection);
s = regionprops(msk_intersection_labelled,'Area');
figure;
plot(cat(1, s.Area));
title('Detection Ground Truth overlap');
% detected 
msk_reconstruction = imreconstruct(gtMask.*uint16(msk_intersection>0), uint16(gtMask));

%missed 
msk_difference = gtMask- msk_reconstruction;
diffmskcc = bwconncomp(msk_difference, 6);
nummissed_regions = diffmskcc.NumObjects

% false detection
det_reconstruction = imreconstruct(pixMask.*uint16(msk_intersection>0), uint16(pixMask));
det_difference = pixMask - det_reconstruction;
diffdetcc = bwconncomp(det_difference,6);
numfalsed_regions = diffdetcc.NumObjects


[rates,tdgt, tddt, fd, gthitIx] = evaluateWithCenters(gtlistreordered,dt_ctr,dt_pixlists,imSize );
