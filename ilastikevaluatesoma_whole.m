%ilastikevaluatesoma.m
% this loads connected component labels gernerated by
% calculate_detection_bb and calculates hit miss rates.
% this is called  simple because it just checks hit/miss with respect to
% center
%save(str)cat(fname,'detectionbb_mxlabel.mat'),'mxlabel','ccpixlistI', 'centroids', 'bbx', 'areas');
%fnam = 'D:\mouse_brain\shawnnew\20130506-interareal_mag4\20130506-interareal_mag4\cc_smallish.h5'
    root = 'D:\mouse_brain\20130506-interareal_mag4\ccout\paper_results\'
    %root = 'D:\mouse_brain\20130506-interareal_mag4\ccout\whole_ilp8\'
    %d = load(strcat(root,'cc_th_50.h5detectionbb_mxlabel_all_regionProps.mat'));
    %d = load (strcat(root,'cc_th_50.h5detectionbb_mxlabel_all_regionProps.matcc_processed.mat'));
    %fname = 'cc_th_50_detectionbb_mxlabel_all_regionProps.matcc_processed_th_1000.mat';

    % inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %root = '/mnt/disk/btek/mouse_brain/'
    %rawsfname =  'cc_th_50_all_regionProps_Ath_5.mat'%'cc_th_50_detection_bbx_Ath_1_regionprops.mat';'cc_th_50.h5all_region_props_vth1_25.mat';
    fname = 'cc_th_50.h5all_region_props_vth1_25cc_processed_th_1000.mat'
    d = load (strcat(root,fname));
    CC  =d.CC;
gt = load('gtintereal20130506.mat') %gives validannotations.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% options%%%%%%%%%%%%%%%%%%%%%%%%%
dumpDetections = 0;
removeEdgeDT = 1;
writeintotxtfiles = 0;
plotscatters = 0;
plthists = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
ndetections = length(CC.areas)
dt_bb = CC.bbx;
dt_ctr = CC.centroids;
dt_pixlists = CC.PixelIdxList;
imSize = CC.ImageSize;
dep = imSize(3);
wid = imSize(2);
hei = imSize(1);
startpos =[1 1 1];


disp('gt points are indexed 0 based');
% add one
gtlist = gt.validannotations(:,3:6)+1;
lengt= length(gtlist);


gtlist = updateSomaGT(gtlist);

[gtlistInROI, gtIndx] = getGTInROI(gtlist, startpos, [dep,hei,wid],[hei,wid,dep],removeEdgeDT);
numberOfGtPointsinRoi = length(gtlistInROI)
gtr = gtlistInROI(:,1);
gtx = gtlistInROI(:,2);
gty = gtlistInROI(:,3);
gtz = gtlistInROI(:,4);

gtlistreordered =[gtx,gty,gtz,gtr];

if(removeEdgeDT)
    
    removeEdgeTouching;
end

[rates,tdgt, tddt, fd, gthitIx,dthitIx] = evaluateWithCenters(gtlistreordered,CC,imSize );
%%

if plthists
    plotResultHistograms;
end
   
%%

if(dumpDetections)
    dumpDetections2File;
end
dumpFeatures = 0;
if(dumpFeatures)
    dumpFeatures2File;
end
%% missing GT's and other scatter plots.

if(plotscatters)
    plotScatters;
end

%%  write everything to text files.

if(writeintotxtfiles)
    dt_ctr = CC.centroids;
    dt_areas = CC.areas;
    writeEvaluationResults2TextFile;
end