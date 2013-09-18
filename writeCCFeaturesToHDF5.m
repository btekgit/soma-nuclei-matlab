function writeCCFeaturesToHDF5(greyFile, greyDSet, CC, outfname)
%function writeCCFeaturesToHDF5(greyFile, greyDSet, CC, outfname)
% 11.09.2013 BT 
if(nargin==0)
    greyFile = ('D:\mouse_brain\20130506-interareal_mag4\ilastikio\20130506-interareal_mag420130722_132814-x0-8_y0-6_z0-59.h5');
    greyDSet = ('/G1/20130722_132814');
    fname = 'cc_th_50_detectionbb_mxlabel_all_regionProps.matcc_processed_th_1000.mat';
    load (strcat('D:\mouse_brain\20130506-interareal_mag4\ccout\whole_ilp8\',fname));
    %outfname = 'D:\mouse_brain\20130506-interareal_mag4\ccout\whole_ilp8\dtmask_th_50_a1000_matlab_fea.h5'
    outfname = 'D:\mouse_brain\20130506-interareal_mag4\ccout\whole_ilp8\matlab_fea.h5'
end
imSize = CC.ImageSize;
numObjects = CC.NumObjects;
vec_areas= cat(1,CC.areas);
vec_centroids = cat(1,CC.centroids);
vec_bbx = cat(1,CC.bbx);

sebox3d = strel(strel(ones(3,3,3)));
histbins = linspace(0,255,32);
granbins = linspace(50, 10000,5);
feature_names = {'Volume', 'CentroidNorm','Centroid', 'Perimeter', 'PseudoRadius', 'Complexity',...
    'BoundingBox2Volume', 'BoundingBoxAspectRatio', 'IntensityMax','IntensityMean',...
    'IntensityMin','IntensityStd', 'CloseMassRatio','IntensityHist', 'Granulometry'}
feature_lengths = [1, 3,3, 1, 1, 1,1, 1, 1,1,1,1, 1, length(histbins), length(granbins)];

feature_num = length(feature_names)
features = cell(feature_num,1);
for f = 1: feature_num
    features{f} = zeros(numObjects,feature_lengths(f));
end

for o = 1: numObjects
    
    completed = floor(o/numObjects*100);
     if (mod(o,50)==0)
        fprintf('\b\b\b');
        fprintf('%3d', completed);
    end
    
    %print_same_line(sprintf('completed:%d/100 \n',(completed)));
    
    bbx = floor(CC.bbx(o,:)+0.5);
    base = zeros(bbx(5), bbx(4),bbx(6));
    
    pix = CC.PixelIdxList{o};
    [py,px,pz] = ind2sub(imSize, pix);
    % read grayFile
    lenx  =bbx(4); leny = bbx(5); lenz = bbx(6);
    
    startix = double([bbx(3), bbx(2), bbx(1)]);
    counts = double([bbx(6),bbx(5), bbx(4)]);
    graycube = h5read(greyFile, greyDSet, startix, counts);
    %subcube= h5read(fname,dsetname,startix,counts);
    %  unfortunately we have to do this because of ilastik xyz
    %  order
    graycube = permute(permute(graycube, [3, 2, 1]),[2,1,3]);
    
    
    newpy = py-bbx(2)+1;
    newpx = px-bbx(1)+1;
    newpz = pz-bbx(3)+1;
    newI = sub2ind(size(base), newpy, newpx, newpz);
    base(newI) = 1;
    
    newbase = imfill(base,'holes');
    fea_vol = sum(newbase(:));
    %     if (vol < Volume_th)
    %         erased(o) = 1;
    %         continue;
    %     end
    
    pseudorad = (3*fea_vol/4/pi)^(1/3);
    
    
    fea_perim = calculate3DSurfaceLengthbyErosion(base);
    fea_pseudo_rad = pseudorad;
    fea_perim_area = fea_perim.*fea_pseudo_rad/fea_vol;
    fea_box_to_vol = numel(base)/fea_vol;
    fea_box_aspect_ratio = max([lenx,leny, lenz])/min([lenx,leny, lenz]);
    
    
    mskedPixelValues = double(graycube(newI));
    fea_pixmax = max(mskedPixelValues);
    fea_pixmean = mean(mskedPixelValues);
    fea_pixmin = min(mskedPixelValues);
    fea_pixstd = std(mskedPixelValues);
    fea_pixhist=  hist(mskedPixelValues, histbins);
    
    
    % we can use this later to merge oversegmentations
    fea_close_mass = calculateCloseMassGravity(vec_centroids(o,:), pseudorad,fea_vol,o,vec_areas, vec_centroids);
    
    
    % volume granulometry
    fea_gran = calculate3DVolumeGranulometry(graycube,base, granbins);
    
    %feature_names = {'Volume', 'Centroid', 'Perimeter', 'PseudoRadius', 'Complexity',...
    %'BoundingBox2Volume', 'BoundingBoxAspectRatio', 'IntensityMax','IntensityMean',
    %'IntensityMin','IntensityStd', 'CloseMassGravity','IntensityHist', 'Granulometry'}
    features{1}(o) = fea_vol;
    % centroids are normalized with respect to image size.
    features{2}(o,:) = [vec_centroids(o,1)/imSize(2), vec_centroids(o,2)/imSize(1),vec_centroids(o,3)/imSize(3)];
    features{3}(o,:) = [vec_centroids(o,1), vec_centroids(o,2),vec_centroids(o,3)];
    features{4}(o) = fea_perim;
    features{5}(o) =  fea_pseudo_rad;
    features{6}(o) =  fea_perim_area;
    features{7}(o) = fea_box_to_vol; 
    features{8}(o) = fea_box_aspect_ratio; 
    features{9}(o) = fea_pixmax; 
    features{10}(o) = fea_pixmean; 
    features{11}(o) = fea_pixmin; 
    features{12}(o) = fea_pixstd; 
    features{13}(o,:) = fea_close_mass;
    
    features{14}(o,:) = fea_pixhist;
    features{15}(o,:) = fea_gran;
   
    
end
 fprintf('\n');

writeFeatures2HDF5(outfname, numObjects, features, feature_names, feature_lengths)
end


function writeFeatures2HDF5(outfname, numObjects, features, featureNames, featureLength)

for f = 1: length(features)
    feature_data = features{f};
    if (featureLength(f)==1)
        data_size = numObjects;
    else
        data_size = fliplr([numObjects,featureLength(f)]);
        feature_data = feature_data';
    end
        
    h5create(outfname,['/',featureNames{f}],data_size,'Datatype','double');
    
%     if(rank(feature_data)>1)
%     feature_data = transpose(feature_data);
%     end
    h5write(outfname, ['/',featureNames{f}], feature_data);
end
end


function  close_mass_ratio = calculateCloseMassGravity(thisCentroid, thisRad,thisArea,thisIndex, vecAreas, vecCentroids)
% this hyper sophisticated functions calculates big mass objects gravity
% to this object.
% this object must be close to other in order to be pulled by them
% this can be used to solve oversegmentation problems
% centroids in matlab are allways xyz order

PROXIMITY_THRESHOLD = 4*thisRad;

dist_centers = (thisCentroid(3)-vecCentroids(:,3)).*(thisCentroid(3)-vecCentroids(:,3))+...
    (thisCentroid(2)-vecCentroids(:,2)).*(thisCentroid(2)-vecCentroids(:,2))+ ...
    (thisCentroid(1)-vecCentroids(:,1)).*(thisCentroid(1)-vecCentroids(:,1));

closeenough = sqrt(dist_centers)<= PROXIMITY_THRESHOLD;%(1.5*gtr(igt));
closeind = setdiff(find(closeenough==1),thisIndex);
% found itself
if((isempty(closeind)))
    close_mass_ratio  = -1; 
    return;
end

close_mass_ratio = max(vecAreas(closeind))/thisArea;

end

function [surfaceLength, surfacePixels] = calculate3DSurfaceLengthbyErosion(msk)
% this is calculated in a quick way
DEBUGG  = 0 ;

% I will calculate the surface very simply with msk -erode(msk)
cross2d = [0 1 0 ; 1 1 1; 0 1 0];
basecenters = [0 0 0; 0 1 0 ; 0 0 0];
cross3d = cat(3, basecenters, cross2d,basecenters);
sebox3d = strel(strel(cross3d));
%sebox3d = strel(strel(ones(3,3,3)));
mskopen = imopen(msk, sebox3d);
mskopen = imfill(mskopen,'Holes');
mskerode3d = imerode(mskopen, sebox3d);
% now the difference
diff_3d = mskopen-mskerode3d;
if(DEBUGG)
    sliceview(msk+diff_3d);
    pause;
end
CC = bwconncomp(diff_3d);
lenCC = CC.NumObjects;
if(DEBUGG)
    lenCC
end
if(lenCC==1)
    surfaceLength = length(CC.PixelIdxList{1});
    surfacePixels = msk;
    surfacePixels =0;
    surfacePixels(CC.PixelIdxList{1}) = max(msk(:));
    return;
end
% if there are more than one connected component
% I assume the largest connected component is the perimeter
regioninfo = regionprops(CC, 'Area');
areas = cat(1,regioninfo.Area);
[mxval, mxarg] = max(areas);
surfaceLength = mxval;
if (nargout==2)
    surfacePixels = msk;
    surfacePixels =0;
    surfacePixels(CC.PixelIdxList{mxarg}) = max(msk(:));
end
end


function granulo = calculate3DVolumeGranulometry(greyData,msk, granulobins)

% calculates volume granulometry just for the pixels of msk
greyData(~msk) = 0;
granulo = maxtree_granulo3d(greyData, 0, 2, granulobins);
% this is not the best way of doing it but I will for now

end

