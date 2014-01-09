%ilastikevaluatesoma.m
% this loads connected component labels gernerated by
% calculate_detection_bb and calculates hit miss rates.
% this is called  simple because it just checks hit/miss with respect to
% center
function evaluteNucleiDetection(root,fname,gtfile, options)
if(nargin < 3)
    root = 'D:\mouse_brain\20130506-interareal_mag4\ccout\experiment2\'
    %root = 'D:\mouse_brain\20130506-interareal_mag4\ccout\whole_ilp8\'
    %fname = 'cc_th_50_detectionbb_mxlabel_all_regionProps.matcc_processed_th_1000.mat';
    
    % inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %root = '/mnt/disk/btek/mouse_brain/'
    
    fname = 'cc_th_50.h5all_region_props_vth1_25cc_processed_th_1000.mat'
    gtfile = 'gtintereal20130506.mat';
end

d = load (strcat(root,fname));
CC  =d.CC;
gt = load(gtfile) %gives validannotations.
%gt = load('gtintereal20130506_12_10_13.mat') %gives validannotations. shawn's new annotation including all nuclei

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargin < 4 | isempty(options))
% options%%%%%%%%%%%%%%%%%%%%%%%%%
dumpDetections = 0;
removeEdgeDT = 1;
writeintotxtfiles = 0;
plotscatters = 0;
plthists = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
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