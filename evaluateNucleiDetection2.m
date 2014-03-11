
function [rates,hitratesfortypes]= evaluateNucleiDetection2(fname,gtfile,options, rf_file)
% this is the second version of the function which evaluates detection
% this version loads ground truth labels from the file and displays
% nucleus class for hit/miss
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
dumpFeatures = 0;
removeEdgeDT = 1;
writeintotxtfiles = 0;
plotscatters = 0;
plthists = 1;
classifierLabels= 0;
nucleusTypes = 1; 
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
    if(isfield(options,'nucleusTypes')), nucleusTypes = options.nucleusTypes; end
end
%%
if (classifierLabels)
% this option is for random forest produced labels to
% overwrite detections
% if there are classifier labels load them 
% rf_file = 'cc_th_50.h5all_region_props_vth1_25cc_processed_th_1000_nonedge_matlab_fea.h5_rf_results.h5'
    rf_data = h5load(rf_file);
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
if(gt.options.zerobasedindexing)
    disp('gt point indices are 0 based');
    gtlist(:,2:4) = gtlist(:,2:4)+1;
end
lengt= length(gtlist);


%gtlist = updateSomaGT(gtlist);   % do this for only gtintereal20130506.mat

[gtlistInROI, gtIndx] = getGTInROI(gtlist, startpos, [dep,hei,wid],[hei,wid,dep],removeEdgeDT);
numberOfGtPointsinRoi = length(gtlistInROI)
gtr = gtlistInROI(:,1);
gtx = gtlistInROI(:,2);
gty = gtlistInROI(:,3);
gtz = gtlistInROI(:,4);

gtlistreordered =[gtx,gty,gtz,gtr];

% if gt neuron's have labels remove edge touching 
gtlabels = [];
if (nucleusTypes)
    gtlabels = gt.validannotations(gtIndx,7);
    
    % we know 5 different labels from shawn's annotation.
    % 1 neural, 2 glial, 3 vascular, 4 gc, 5 p 
    gtlabelhist = hist(gtlabels,1:5);
    if(length(unique(gtlabels))~=5)
        disp('number of different labels is not 5, check gt file!');
        pause;
    end
end

%% remove edge touching detections
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
[rates,tdgt, tddt, fd, gthitIx,dthitIx, dthitRelaxed, hitIndx] = evaluateWithCenters(gtlistreordered,CC,imSize );

%% if there are class labels count hit/misses for different labels

%%
if (nucleusTypes)
    hitsfortypes = zeros(size(gtlabelhist));
    hitratesfortypes = zeros(size(gtlabelhist));
    for t = 1: length(hitsfortypes)
        hitsfortypes(t) = sum(gtlabels(gthitIx==1)==t);
        hitratesfortypes(t) = hitsfortypes(t)/gtlabelhist(t);
    end
    
    typesofdets = zeros(size(dthitIx));
    for t = 1: length(typesofdets)
        if(dthitIx(t)~=0)
            multilabel = gtlabels(hitIndx(t));
            if(gtlabelhist(multilabel)>5)
                typesofdets(t) = multilabel;
            else
               typesofdets(t) = 1;
               disp('not enough samples of class');
               disp(multilabel)
            end
        else
            typesofdets(t) = 0;
        end
    end
    
    
    
end
hitratesfortypes



 
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
    dt_pseudo_radius = (3*dt_areas/4/pi).^(1/3)
    writeEvaluationResults2TextFile;
end