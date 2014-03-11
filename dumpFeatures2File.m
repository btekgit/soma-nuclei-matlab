%dumps features 2 file 

% this is to indicate which original data will be used to extract features
if (1)
greyFile = 'D:\mouse_brain\20130506-interareal_mag4\ilastikio\20130506-interareal_mag420130722_132814-x0-8_y0-6_z0-59.h5';
greyData = '/G1/20130722_132814';

% feature filename
featureFile = [root,'\', fname(1:end-4),'_features_',date,'.h5'];
writeCCFeaturesToHDF5(greyFile,greyData, CC, featureFile);
end

trfile = [root, '\',fname(1:end-4),'_labels_',date,'.h5'];
h5create(trfile,'/labels',length(dthitIx),'Datatype','uint32');
h5write(trfile, '/labels',uint8(dthitIx));

if(nucleusTypes)
    h5create(trfile,'/labelsmulti',length(typesofdets),'Datatype','uint32');
    h5write(trfile, '/labelsmulti',uint8(typesofdets)); 
end
