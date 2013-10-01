%ilastikevaluatesoma_whole_post_classifier
% this merges connected components with random forest classification labels
% rerun's the evaluations

addpath('C:\Users\btek\Google Drive\matlabcode\hdf5')

%root = 'D:\mouse_brain\20130506-interareal_mag4\ccout\whole_ilp8\'
root = 'D:\mouse_brain\20130506-interareal_mag4\ccout\paper_results\'
fname = 'cc_th_50.h5all_region_props_vth1_25cc_processed_th_1000.mat';
d = load (strcat(root,fname));
CC  =d.CC;
%d = load(strcat(root, 'cc_th_90.h5detectionbb_mxlabel_all_regionProps.matcc_processed.mat'));
%d.CC = d.newCC;


gt = load('gtintereal20130506.mat') %gives validannotations.
gt.processed = zeros(length(gt.validannotations),1);
gt.hits = zeros(length(gt.validannotations),3);


% options%%%%%%%%%%%%%%%%%%%%%%%%%
dumpDetections = 0;
dumpFeatures = 0; 
removeEdgeDT = 1;
writeintotxtfiles = 0;
plotscatters = 1;
plthists = 1;
randomforestLabels= 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rf_file = 'cc_th_50.h5all_region_props_vth1_25cc_processed_th_1000_nonedge_matlab_fea.h5_rf_results.h5'
rf_data = h5load(strcat(root, rf_file));
rf_results = rf_data.rf_results';

%%
ndetections = length(CC.areas)
imSize = CC.ImageSize;
dep = imSize(3);
wid = imSize(2);
hei = imSize(1);
startpos =[1 1 1];


disp('gt points are indexed 0 based');
% add one
gtlist = gt.validannotations(:,3:6)+1;
lengt= length(gtlist);

% adds additional nuclei marked by BTek
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

if (randomforestLabels)
  
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
    

[rates,tdgt, tddt, fd, gthitIx,dthitIx] = evaluateWithCenters(gtlistreordered,CC,imSize );
%%

if plthists
    plotResultHistograms;
end
%%
if(dumpDetections)
    dumpDetections2File;
end
%%
if(dumpFeatures)
    dumpFeatures2File;
end
%% missing GT's and other scatter plots.

if(plotscatter)
    plotScatters;
end

%%  write everything to text files.

if(writeintotxtfiles)
    dt_ctr = CC.centroids;
    dt_areas = CC.areas;
    writeEvaluationResults2TextFile;
end