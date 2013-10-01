%dumps features 2 file 

greyFile = 'D:\mouse_brain\20130506-interareal_mag4\ilastikio\20130506-interareal_mag420130722_132814-x0-8_y0-6_z0-59.h5';
greyData = '/G1/20130722_132814';
featureFile = [root, fname(1:end-4),'_nonedge_matlab_fea.h5'];
writeCCFeaturesToHDF5(greyFile,greyData, CC, featureFile);