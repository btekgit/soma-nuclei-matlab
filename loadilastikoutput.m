%
%dump ilastik input to knossos. 
hdinput = h5read('D:\mouse_brain\4x-downsampled\ilastik\20130506-interareal20130710_190314-xyz.h5','/G1/20130710_190314');
hdinput2 =   permute(hdinput, [2,3,1]);
dirr = 'D:\mouse_brain\4x-downsampled\ilastik\20130506-interareal-in';

KNOSSOS_cubeGenerator_generateCubesFromMatVar(uint8(hdinput2),dirr,[160 160 200],'ilastik_soma_06_input');

%%

hd = h5load('D:\mouse_brain\4x-downsampled\ilastik\soma_linux_06.ilp','/PixelClassification/Predictions/predictions0000');
whos
size(hd)
hdbin = hd(:,:,:,1)<hd(:,:,:,2);
hdbin =   permute(hdbin, [2,1,3]);
figure
addpath 'C:\Users\btek\Google Drive\matlabcode\CT\CT'

%c1 = CT(hdbin);

 
%whos



sliceview(uint8(hdbin))
% fill holes
t = imfill(uint8(hdbin.*256),6,'holes');
sliceview(uint8(t));
% remove supirous reigons
t2 = bwareaopen(t, 5000,6);
sliceview(uint8(t2));

% label image
t3 = bwlabeln(t2);
maxlabel = max(t3(:));
baseimg3d = zeros(size(t2));

% create a disk element
r = 5;
[x,y,z] = meshgrid(-5:5,-5:5,-5:5);
se2 = (x/r).^2 + (y/r).^2 + (z/r).^2 <= 1;
se3 = strel('disk', 5);
for i = 1: maxlabel
    msk = t3 == i; 
    %% do closings on each label
    mskclosed = imclose(msk, se3);
    baseimg3d(mskclosed>0) = i; 
end
sliceview(baseimg3d);

baseimg25d = zeros(size(t2));
se3 = strel('disk', 5);
for i = 1: maxlabel
    msk = t3 == i; 
    for sli = 1:size(msk,3)
        %% do closings on each label
        msksli = msk(:,:,sli);
        %msksliclosed = imclose(msksli, se3);
        msksliclosed = bwareaopen(msksli, 1000);
        msksliclosed = imfill(msksliclosed,'holes');
        msksliclosed = imclose(imopen(msksliclosed,se3),se3);
        msksliclosed = imfill(msksliclosed,'holes');
        msk(:,:,sli) = msksliclosed;
    end
    baseimg25d(msk>0) = i; 
end
sliceview(baseimg25d);


dirr = 'D:\mouse_brain\4x-downsampled\ilastik\20130506-interareal-out';



KNOSSOS_cubeGenerator_generateCubesFromMatVar(uint8(baseimg25d),dirr,[160 160 200],'ilastik_soma_06_output2');
%%


