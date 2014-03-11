%dumps detections to the file for inspection with hdfview, review.py


    rsfile = strcat(root,'\', fname(1:end-4),'_evaluations_',date,'.h5');
    if(~exist(rsfile))
        
        reconstructDetMaskToHdf5(rsfile, '/TD', imSize,ndetections, dt_pixlists,dt_bb, dthitIx==1);
        %fdfile = strcat(root, fname(end-3:end),'_false_dt.h5');
        reconstructDetMaskToHdf5(rsfile, '/FD', imSize, ndetections, dt_pixlists,dt_bb, dthitIx==0);
        %missedfile = strcat(root, fname(end-3:end),'_miss_gt.h5');
        reconstructGTMasktoHDF5Spheres(rsfile,'/MGT', imSize,gtlistInROI(gthitIx==0,:),1);
        reconstructGTMasktoHDF5Spheres(rsfile,'/ALLGT', imSize,gtlistInROI,1);

        reconstructGTMasktoHDF5Spheres(rsfile,'/HGT', imSize,gtlistInROI(gthitIx==1,:),1);
    end
    %trfile = strcat(root, fname(1:end-4),'_nonedge_training_labels_20_10_2013.h5');
    %h5create(trfile,'/labels',length(dthitIx),'Datatype','uint32');
    %h5write(trfile, '/labels',uint8(dthitIx));

