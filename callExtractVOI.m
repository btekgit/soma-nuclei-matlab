% this script calls extractSomaGTVOI's to cut out marked soma regions
%from  images

greyFile = ('D:\mouse_brain\20130506-interareal_mag4\ilastikio\20130506-interareal_mag420130722_132814-x0-8_y0-6_z0-59.h5');
greyDSet = ('/G1/20130722_132814');
outputFolder= 'D:\mouse_brain\20130506-interareal_mag4\gtvoi11012014\'
imSize = [768,1024,7552];

gt = load('gtintereal20130506_12_10_13.mat') %gives validannotations. shawn's new annotation including all nuclei

gtlist = gt.validannotations(:,3:6);
% add one
disp('gt point indices are 0 based');
gtlist(4:6) = gtlist(4:6)+1;
lengt= length(gtlist);

dep = imSize(3);
wid = imSize(2);
hei = imSize(1);
startpos =[1 1 1];
removeEdgeDT = 1; 
writeEveryOther = 1; 



[gtlistInROI, gtIndx] = getGTInROI(gtlist, startpos, [dep,hei,wid],[hei,wid,dep],removeEdgeDT);
numberOfGtPointsinRoi = length(gtlistInROI)

numberOutRange = extractSomaGTVOIs(imSize,gtlist,greyFile, greyDSet,[1,2,3,4],writeEveryOther,outputFolder)