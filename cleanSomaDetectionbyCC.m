function newCC=cleanSomaDetectionbyCC(root, inpCCName,Volume_th)


%t3 = bwlabeln(inpVolume);
%maxlabel = max(t3(:));
if nargin ==0
    %root = 'D:\mouse_brain\shawnnew\ccout\training\'
    root = 'D:\mouse_brain\shawnnew\ccout\whole\'
    %inpCCName  ='cc_th_50.h5detectionbb_mxlabel_all_regionProps.mat';
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
erased = zeros(numObjects,1);
parted = zeros(numObjects,1);
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
    if ( d.CC.areas(o) < Volume_th/8)
        erased(o) = 1;
        continue;
    end
    bbx = floor(d.CC.bbx(o,:));
    base = zeros(bbx(5), bbx(4),bbx(6));
    
    pix = d.CC.PixelIdxList{o};
    [py,px,pz] = ind2sub(imSize, pix);
    newpy = py-bbx(2);
    newpx = px-bbx(1);
    newpz = pz-bbx(3);
    newI = sub2ind(size(base), newpy, newpx, newpz);
    base(newI) = 1;
    newbase = imfill(base,'holes');
    vol = sum(newbase(:));
    if (vol < Volume_th)
        erased(o) = 1;
        continue;
    end
    pseudorad = (3*vol/4/pi).^(1/3);
    % create a disk with 1/10 of the pseudo radius.
    opening_radius = pseudorad/Disk_ratio;
    if ( opening_radius>11)
        opening_radius = 11; 
    end
    se = createDiskSe(floor(opening_radius));
    openedbase = imopen(newbase, se);
    openedfilled = imfill(openedbase, 'holes');
    
    % to count how many objects are there here.
    relabel = bwlabeln(openedfilled);
    % rewrite them as new Objects.
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
            %if( newObjectCounter>20 && newObjectCounter<30)
            %sliceview(openedbase);
            %pause;
            %end

        end
    end
    
    
    
    
end

newCC.NumObjects = newObjectCounter-1;
s  = regionprops(newCC, 'centroid','BoundingBox','Area');
newCC.centroids = cat(1, s.Centroid);

newCC.bbx =  cat(1, s.BoundingBox);
newCC.areas =  cat(1, s.Area);
CC = newCC;
save(strcat(root,inpCCName(1:end-4),'cc_processed_th_',num2str(Volume_th),'.mat'),'CC','Volume_th');

end



function se = createDiskSe(r)
[x,y,z] = meshgrid(-r:r,-r:r,-r:r);
se = (x).^2 + (y).^2 + (z).^2 <= r;
end

