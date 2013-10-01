function newCC=componentWiseFiltering(root, inpCCName,Volume_th, outputFile)
%function newCC=cleanSomaDetectionbyCC(root, inpCCName,Volume_th,outputFile)
%
% The purpose of this function is to apply filtering and morphological
% operations to separate attached nuclei, and fill volumes.
%
% It works on connected component list in 3D that is stored in
% location [root, inpCCName]
%
% It applies threshold value Volume_th (default is 1000) to clean
% up objects and to validate new nuclei after opening the volume
% with a sphere shaped SE.
%
%
% optional outputFile shows destination matfile name

% by F. Boray Tek 02.10.2013 
% 
%
% You can redistribute, and/or modify this code. 
% This code is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% BTEK: 02.10.2013 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



if nargin ==0
    root = 'D:\mouse_brain\shawnnew\ccout\whole\'
    inpCCName  ='cc_th_90.h5detectionbb_mxlabel_all_regionProps.mat';
end
d = load (strcat(root,inpCCName));

% one by one reconstruct all the detections if valid. keep them,
% if possible fill them . and update CC
if(nargin ==2)
    Volume_th = 1000;
end
imSize = d.CC.ImageSize;
numObjects = d.CC.NumObjects
Disk_ratio = 5;
MAX_SPHERE_RADIUS =11;
erased = zeros(numObjects,1);
newObjectCounter = 1;
dummy = zeros(1,1,1);
newCC = bwconncomp(dummy);
newCC.ImageSize = d.CC.ImageSize;
newCC.Connectivity = d.CC.Connectivity;
for o = 1: numObjects
    completed = floor(o/numObjects*100);
    if (mod(o,50)==0)
        fprintf('\b\b\b');
        fprintf('%3d', completed);
    end
    
    % A quick clean up to speed up things
    if ( d.CC.areas(o) < Volume_th/8)
        erased(o) = 1;
        continue;
    end
    
    % take bounding box
    bbx = floor(d.CC.bbx(o,:));
    base = zeros(bbx(5), bbx(4),bbx(6));
    pix = d.CC.PixelIdxList{o};
    [py,px,pz] = ind2sub(imSize, pix);
    % transform to local
    newpy = py-bbx(2);
    newpx = px-bbx(1);
    newpz = pz-bbx(3);
    newI = sub2ind(size(base), newpy, newpx, newpz);
    % reconstruct the volume shape
    base(newI) = 1;
    
    % apply filling
    newbase = imfill(base,'holes');
    vol = sum(newbase(:));
    if (vol < Volume_th)
        erased(o) = 1;
        continue;
    end
    % calculate pseudo-rad
    pseudorad = (3*vol/4/pi).^(1/3);
    
    % create a disk with 1/Disk_ratio of the pseudo radius.
    opening_radius = pseudorad/Disk_ratio;
    
    % below limits the radius with 11 and size SE 22x22x22
    % due to performance reasons.
    if ( opening_radius>MAX_SPHERE_RADIUS)
        opening_radius = MAX_SPHERE_RADIUS;
    end
    
    se = createDiskSe(floor(opening_radius));
    
    % apply opening
    openedbase = imopen(newbase, se);
    % apply filling
    openedfilled = imfill(openedbase, 'holes');
    
    % count how many objects are there here.
    relabel = bwlabeln(openedfilled);
    
    % calculate their area and coordinates as new Objects.
    s  = regionprops(relabel,'Area','PixelIdxList');
    lens = length(s);
    for i = 1: lens
        % we have a parted object
        if ( s(i).Area> Volume_th)
            % it is big enough to record
            % transform the coordinates.
            Ip = s(i).PixelIdxList;
            [ppy,ppx,ppz] = ind2sub(size(base), Ip);
            oldpy = ppy+bbx(2);
            oldpx = ppx+bbx(1);
            oldpz = ppz+bbx(3);
            oldI = sub2ind(imSize, oldpy, oldpx, oldpz);
            %transformed coordinates are on oldI
            newCC.PixelIdxList{newObjectCounter} = oldI;
            %
            newObjectCounter = newObjectCounter+1;
        end
    end
end

% the new CC has newObjectCounter-1 objects 
newCC.NumObjects = newObjectCounter-1;

%recompute everything, to make sure. 
s  = regionprops(newCC, 'centroid','BoundingBox','Area');

% write the structure
newCC.centroids = cat(1, s.Centroid);
newCC.bbx =  cat(1, s.BoundingBox);
newCC.areas =  cat(1, s.Area);
CC = newCC;
% store the output in the file
save(strcat(root,inpCCName(1:end-4),'cc_processed_th_',num2str(Volume_th),'.mat'),'CC','Volume_th');

end



function se = createDiskSe(r)
[x,y,z] = meshgrid(-r:r,-r:r,-r:r);
se = (x).^2 + (y).^2 + (z).^2 <= r;
end
