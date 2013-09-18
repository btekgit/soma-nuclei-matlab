%ilastikevaluatesoma.m
% this loads connected component labels gernerated by
% calculate_detection_bb and calculates hit miss rates.
% this is called  simple because it just checks hit/miss with respect to
% center
%save(str)cat(fname,'detectionbb_mxlabel.mat'),'mxlabel','ccpixlistI', 'centroids', 'bbx', 'areas');
%fnam = 'D:\mouse_brain\shawnnew\20130506-interareal_mag4\20130506-interareal_mag4\cc_smallish.h5'
%root = 'D:\mouse_brain\shawnnew\ccout\training\'
root = 'D:\mouse_brain\20130506-interareal_mag4\ccout\whole_ilp8\'
%d = load(strcat(root,'cc_th_50.h5detectionbb_mxlabel_all_regionProps.mat'));
%d = load (strcat(root,'cc_th_50.h5detectionbb_mxlabel_all_regionProps.matcc_processed.mat'));
fname = 'cc_th_50_detectionbb_mxlabel_all_regionProps.matcc_processed_th_1000.mat';
d = load (strcat(root,fname));
CC  =d.CC;
%d = load(strcat(root, 'cc_th_90.h5detectionbb_mxlabel_all_regionProps.matcc_processed.mat'));
%d.CC = d.newCC;

dumpDetections = 0;

gt = load('gtintereal20130506.mat') %gives validannotations.
gt.processed = zeros(length(gt.validannotations),1);
gt.hits = zeros(length(gt.validannotations),3);


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
removeEdgeTouching = 0

disp('gt points are indexed 0 based');
% add one
gtlist = gt.validannotations(:,3:6)+1;
lengt= length(gtlist);


gtlist = updateSomaGT(gtlist);

[gtlistInROI, gtIndx] = getGTInROI(gtlist, startpos, [dep,hei,wid],[hei,wid,dep],removeEdgeTouching);
numberOfGtPointsinRoi = length(gtlistInROI)
gtr = gtlistInROI(:,1);
gtx = gtlistInROI(:,2);
gty = gtlistInROI(:,3);
gtz = gtlistInROI(:,4);

gtlistreordered =[gtx,gty,gtz,gtr];

if(removeEdgeTouching)
    
    dt_pseudo_radius = (0.75*d.CC.areas/pi).^(1/3);
    % r and x-y-z
    dtlistordered = [dt_pseudo_radius, dt_ctr];
    [dtlistInROI, dtIndx] = getGTInROI(dtlistordered, startpos, [dep,hei,wid],[hei,wid,dep],removeEdgeTouching);
    ndetections = length(dtlistInROI)
    dt_ctr = dtlistInROI(:,2:4);
    dt_pixlists = dt_pixlists(dtIndx);
    dt_bb = dt_bb(dtIndx,:);
    
    
    CC2.Connectivity = CC.Connectivity;
    CC2.ImageSize = CC.ImageSize;
    CC2.areas = CC.areas(dtIndx);
    CC2.centroids = CC.centroids(dtIndx,:);
    CC2.bbx = CC.bbx(dtIndx,:);
    CC2.NumObjects = ndetections;
    CC2.PixelIdxList = CC.PixelIdxList(dtIndx);
    CC = CC2;
end

[rates,tdgt, tddt, fd, gthitIx,dthitIx] = evaluateWithCenters(gtlistreordered,dt_ctr,dt_pixlists,imSize );
%%
plt = 1;
if plt
    figure;
    subplot(221);
    [gtrhisthit,binss]= hist(gtr(gthitIx==1));
    bar(binss,gtrhisthit,'b');
    hold;
    [gtrhistmiss,binss] = hist(gtr(gthitIx==0),binss);
    bar(binss,gtrhistmiss, 'red');
    title('True/Missed GT radius')
    subplot(222);
    [gtzhisthit,binss] = hist(gtz(gthitIx==1))
    bar(binss,gtzhisthit,'b');
    hold;
    [gtzhistmiss, binss] = hist(gtz(gthitIx==0),binss)
    bar(binss,gtzhistmiss,'r');
    title('True/Missed GT z pos')
    subplot(223);
    [gtxhisthit,binss] = hist(gtx(gthitIx==1))
    bar(binss,gtxhisthit,'b');
    hold;
    [gtxhistmiss,binss] = hist(gtx(gthitIx==0),binss)
    bar(binss,gtxhistmiss,'r');
    title('True/Missed GT x pos')
    subplot(224);
    [gtyhisthit,binss] = hist(gty(gthitIx==1))
    bar(binss,gtyhisthit,'b');
    hold;
    [gtyhistmiss,binss] = hist(gty(gthitIx==0),binss)
    bar(binss,gtyhistmiss,'r');
    title('True/Missed GT y pos')
    
    figure;
    subplot(221);
    [dtzhisthit,binss] = hist(dt_ctr(dthitIx==1,3))
    bar(binss,dtzhisthit,'b');
    hold;
    [dtzhistfalse,binss] = hist(dt_ctr(dthitIx==0,3),binss)
    bar(binss,dtzhistfalse,'r');
    title('True/False detections z pos')
    
    subplot(222);
    [dtyhisthit,binss] = hist(dt_ctr(dthitIx==1,2))
    bar(binss,dtyhisthit,'b');
    hold;
    [dtyhistfalse,binss] = hist(dt_ctr(dthitIx==0,2),binss)
    bar(binss,dtyhistfalse,'r');
    title('True/False detections y pos')
    
    subplot(223);
    [dtxhisthit,binss] = hist(dt_ctr(dthitIx==1,1))
    bar(binss,dtxhisthit,'b');
    hold;
    [dtxhistfalse,binss] = hist(dt_ctr(dthitIx==0,1),binss)
    bar(binss,dtxhistfalse,'r');
    title('True/False detections x pos')
    
    subplot(224);
    [dtahisthit,binss] = hist(d.CC.areas(dthitIx==1,1))
    bar(binss,dtahisthit,'b');
    hold;
    [dtahistfalse,binss] = hist(d.CC.areas(dthitIx==0,1), binss)
    bar(binss,dtahistfalse,'r');
    title('True/False detections Volume')
    
end

%%

dumpDetections = 0 ;
if(dumpDetections)
    rsfile = strcat(root, fname(1:end-4),'_orig_evaluations.h5');
    if(~exist(rsfile))
        reconstructDetMaskToHdf5(rsfile, '/TD', imSize,ndetections, dt_pixlists,dt_bb, dthitIx==1);
        %fdfile = strcat(root, fname(end-3:end),'_false_dt.h5');
        reconstructDetMaskToHdf5(rsfile, '/FD', imSize, ndetections, dt_pixlists,dt_bb, dthitIx==0);
        %missedfile = strcat(root, fname(end-3:end),'_miss_gt.h5');
        reconstructGTMasktoHDF5Spheres(rsfile,'/MGT', imSize,gtlistInROI(gthitIx==0,:),1);
        reconstructGTMasktoHDF5Spheres(rsfile,'/HGT', imSize,gtlistInROI(gthitIx==1,:),1);
    end
    trfile = strcat(root, fname(1:end-4),'_orig_training_labels.h5');
    h5create(trfile,'/labels',length(dthitIx),'Datatype','uint32');
    h5write(trfile, '/labels',uint8(dthitIx));
end
dumpFeatures = 0;
if(dumpFeatures)
    greyFile = 'D:\mouse_brain\20130506-interareal_mag4\ilastikio\20130506-interareal_mag420130722_132814-x0-8_y0-6_z0-59.h5';
    greyData = '/G1/20130722_132814';
    featureFile = [root, fname(1:end-4),'_orig_matlab_fea.h5'];
    writeCCFeaturesToHDF5(greyFile,greyData, CC, featureFile);
end
%% missing GT's and other scatter plots.
figure;
bins = 1: 7552;
figure;
hist(gt.validannotations(:,6),bins);

zaxis = load('D:\mouse_brain\20130506-interareal_mag4\20130506-interareal_mag4\zaxis2.txt');

figure

subplot(131);
scatter3(gtlistreordered(:,1),gtlistreordered(:,2)',gtlistreordered(:,3),floor(gtlistreordered(:,4)/2),'b');
xlim([0 1024]); ylim([0 800]); zlim([0 7600]);
title('GTruth Annotation');
xlabel('x'); ylabel('y'); zlabel('z');
view(-45,8)

%hold on;
subplot(132);
scatter3(gtx(gthitIx==1),gty(gthitIx==1),gtz(gthitIx==1),floor(gtr(gthitIx==1)/2),'g');
xlim([0 1024]); ylim([0 800]); zlim([0 7600]);
title('GTruth Detected');
xlabel('x'); ylabel('y'); zlabel('z');
view(-45,8)
hold on;

subplot(133);
scatter3(gtx(gthitIx==0),gty(gthitIx==0),gtz(gthitIx==0),floor(gtr(gthitIx==0)/2),'r');
xlim([0 1024]); ylim([0 800]); zlim([0 7600]);
title('GTruth Missed');
xlabel('x'); ylabel('y'); zlabel('z');
view(-45,8)

figure

subplot(131);
scatter3(dt_ctr(:,1),dt_ctr(:,2),dt_ctr(:,3),floor(CC.areas/1000),'b');
xlim([0 1024]); ylim([0 850]); zlim([0 7600]);
xlabel('x'); ylabel('y'); zlabel('z');
title('Detections');
view(-45,8)


subplot(132);
scatter3(dt_ctr(dthitIx==1,1),dt_ctr(dthitIx==1,2),dt_ctr(dthitIx==1,3),floor(CC.areas(dthitIx==1)/1000),'g');
xlim([0 1024]); ylim([0 850]); zlim([0 7600]);
title('True Detections');
xlabel('x'); ylabel('y'); zlabel('z');
view(-45,8)

subplot(133);
scatter3(dt_ctr(dthitIx==0,1),dt_ctr(dthitIx==0,2),dt_ctr(dthitIx==0,3),floor(CC.areas(dthitIx==0)/1000),'r');
xlim([0 1024]); ylim([0 850]); zlim([0 7600]);
title('False Detections');
xlabel('x'); ylabel('y'); zlabel('z');
view(-45,8)

%%  write everything to text files. 
dt_ctr = CC.centroids;
dt_areas = CC.areas;
writeEvaluationResults2TextFile;