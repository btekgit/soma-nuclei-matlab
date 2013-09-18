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

wid = 512;
hei = 384;
dep = 320;



area_th = 8000;

Ivalid = find(d.CC.areas>area_th);
ndetections = length(Ivalid)
dt_bb = d.CC.bbx(Ivalid,:); %%% xyZ order//
dt_ctr = d.CC.centroids(Ivalid,:);
dt_pixlists= d.CC.PixelIdxList(Ivalid);
%dt_fullhit = zeros(ndetections,1);
gtlist = gt.validannotations;
lengt= length(gtlist);
[gtlistInROI, gtIndx, gtMask] = getGTInROI(gtlist, [1,1,1], [dep,hei,wid],[hei,wid,dep]);
numberOfGtPointsinRoi = length(gtlistInROI)
gtr = gtlistInROI(:,4);
gtcoordx = gtlistInROI(:,1);
gtcoordy = gtlistInROI(:,2);
gtcoordz = gtlistInROI(:,3);


gt_hit = zeros(length(gtr),1);
gt_hitrelaxed = zeros(length(gtr),1);
dt_hit = zeros(ndetections,1);

[bbxMask, pixMask] = reconstructDetMask(d.CC);

% overlap
msk_intersection = pixMask .* uint16(gtMask);

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



%%
% for ix = 1: ndetections
%     % get bounding box
%     bblow= floor(dt_bb(ix,1:3));
%     bbhigh= bblow+floor(dt_bb(ix,4:6));
%     
%     % is there any ground truth center included in this bb
%     containedGtIx = find(gtcoordz>=bblow(3) & gtcoordy>=bblow(2) & gtcoordx>=bblow(1)...
%         & gtcoordz<=bbhigh(3) & gtcoordy<=bbhigh(2) & gtcoordx<=bbhigh(1));
%     
%     % can be more than oe
%     ncontainedGtIx=length(containedGtIx);
%     if(ncontainedGtIx>0)
%         % counting hit for only one. 
%         gt_hit(containedGtIx(1)) = 1;
%         % counting relaxed for all hits, this shows detected region
%         % actually hits two gts.
%         gt_hitrelaxed(containedGtIx) = 1;
%         dt_hit(ix) = 1; 
%     end
%     
%    
% end

% td = sum(dt_hit)
% fd = ndetections -td
% tgt = sum(gt_hit)
% tgtrelaxed = sum(gt_hitrelaxed)
% missed_relaxed = lengt-tgt
% 
% % true detection vs number of false positives 
% rates = [tgt/lengt, fd]

