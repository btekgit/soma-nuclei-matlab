%dumps detections to the file for inspection with hdfview, review.py

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
    trfile = strcat(root, fname(1:end-4),'_nonedge_training_labels.h5');
    h5create(trfile,'/labels',length(dthitIx),'Datatype','uint32');
    h5write(trfile, '/labels',uint8(dthitIx));
end
dumpFeatures = 0;
if(dumpFeatures)
    greyFile = 'D:\mouse_brain\20130506-interareal_mag4\ilastikio\20130506-interareal_mag420130722_132814-x0-8_y0-6_z0-59.h5';
    greyData = '/G1/20130722_132814';
    featureFile = [root, fname(1:end-4),'_nonedge_matlab_fea.h5'];
    writeCCFeaturesToHDF5(greyFile,greyData, CC, featureFile);
end