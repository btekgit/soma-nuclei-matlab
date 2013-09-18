function outVolume=cleanSomaDetectionbySlice(inpVolume)


%t3 = bwlabeln(inpVolume);
%maxlabel = max(t3(:));

outVolume = zeros(size(inpVolume));
%se3 = strel('disk', 4);
se3 = strel('disk', 5);
Area_th  = 20; 
for sli = 1:size(t3,3)
    currentSlice = t3(:,:,sli);
    currentSlice1 = currentSlice; 
    %currentSlice1 = imfill(currentSlice,'holes');
    currentSlice1 = imopen(currentSlice1,se3);
    currentSlice1 = bwareaopen(currentSlice1, Area_th).*currentSlice;
    %currentSlice1 = imclose(currentSlice1,se3);
    %currentSlice1 = bwareaopen(currentSlice, 500).*currentSlice;
    msksliclosed = imfill(currentSlice1,'holes');
%     for i = 1: maxlabel
%         msk = currentSlice1 == i;
%         
%         %sli
%         %% do closings on each label
%         %msksli = msk(:,:,sli);
%         %msksliclosed = imclose(msksli, se3);
%         %msksliclosed = bwareaopen(msksli, 1000);
%         %msksliclosed = imfill(msksliclosed,'holes');
%         msksliclosed = imclose(msk,se3);
%         msksliclosed = imfill(msksliclosed,'holes');
%         
%         currentSlice1(msksliclosed) = i;
%     end
    outVolume(:,:,sli) = msksliclosed;
end
