%ilastikevaluatesoma.m
% this loads connected component labels gernerated by
% calculate_detection_bb and calculates hit miss rates.
% this is called  simple because it just checks hit/miss with respect to
% center
function rates= evaluateNucleiDetection(fname,gtfile,options, rf_file)
if(nargin < 2)
    root = 'D:\mouse_brain\20130506-interareal_mag4\ccout\experiment2\'
    %root = 'D:\mouse_brain\20130506-interareal_mag4\ccout\whole_ilp8\'
    %fname = 'cc_th_50_detectionbb_mxlabel_all_regionProps.matcc_processed_th_1000.mat';
    
    % inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %root = '/mnt/disk/btek/mouse_brain/'
    
    fname = 'cc_th_50.h5all_region_props_vth1_25cc_processed_th_1000.mat'
    fname = strcat(root,fname);
    %gtfile = 'gtintereal20130506.mat';
    gtfile = [];
end
if(isempty(gtfile))
    %gtfile = 'gtintereal20130506_12_10_13.mat';%shawn's new annotation. includes all nuclei
    gtfile = 'gtintereal20130506_11_02_14.mat' % shawn's new annotation, includes all nuclei
    % and nucleus categories
end

d = load (fname);
CC  =d.CC;
gt = load(gtfile) %gives validannotations.

[root,fname,ext] = fileparts(fname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% options%%%%%%%%%%%%%%%%%%%%%%%%%
dumpDetections = 0;
dumpFeatures = 1;
removeEdgeDT = 1;
writeintotxtfiles = 0;
plotscatters = 0;
plthists = 1;
classifierLabels= 0;
%% take options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargin > 2 & ~isempty(options))
    
    if(isfield(options,'dumpDetections')), dumpDetections = options.dumpDetections; end
    if(isfield(options,'removeEdgeDT')), removeEdgeDT = options.removeEdgeDT; end
    if(isfield(options,'writeintotxtfiles')), writeintotxtfiles = options.writeintotxtfiles; end
    if(isfield(options,'plotscatters')), plotscatters = options.plotscatters; end
    if(isfield(options,'plthists')), plthists = options.plthists; end
    if(isfield(options,'classifierLabels')), classifierLabels = options.classifierLabels; end
    if(isfield(options,'dumpFeatures')), dumpFeatures = options.dumpFeatures; end
end
%%
if (classifierLabels)
% this option is for random forest produced labels to
% overwrite detections
% if there are classifier labels load them 
% rf_file = 'cc_th_50.h5all_region_props_vth1_25cc_processed_th_1000_nonedge_matlab_fea.h5_rf_results.h5'
    rf_data = h5load(strcat(root,'\', rf_file));
    rf_results = rf_data.rf_results';
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




gtlist = gt.validannotations(:,3:6);
% add one
disp('gt point indices are 0 based');
gtlist(:,2:4) = gtlist(:,2:4)+1;
lengt= length(gtlist);


%gtlist = updateSomaGT(gtlist);   % do this for only gtintereal20130506.mat

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
%% retains the detections confirmed by the classifier
if (classifierLabels)
  
    Irf_results= find(rf_results==1);
    ndetections= length(Irf_results);
    CC2.Connectivity = CC.Connectivity;
    CC2.ImageSize = CC.ImageSize;
    CC2.areas = CC.areas(Irf_results);
    CC2.centroids = CC.centroids(Irf_results,:);
    CC2.bbx = CC.bbx(Irf_results,:);    
    CC2.NumObjects = length(Irf_results);
    CC2.PixelIdxList = CC.PixelIdxList(Irf_results);
    CC = CC2;
end

%%
[rates,tdgt, tddt, fd, gthitIx,dthitIx, dthitRelaxed] = evaluateWithCenters(gtlistreordered,CC,imSize );
%%


 
if plthists
    plotResultHistograms;
end

%%

if(dumpDetections)
    dumpDetections2File;
end

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