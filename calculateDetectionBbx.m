% calculate bounding boxes form the volume

%fname = 'D:\mouse_brain\shawnnew\20130506-interareal_mag4\20130506-interareal_mag4\cc_all.h5'
root = '/mnt/disk/btek/mouse_brain/'
fname = 'cc_th_50.h5'
dsetname = '/cc'

inf1 = h5info([root, fname],dsetname);
nZ = inf1.Dataspace.Size(1);
nX = inf1.Dataspace.Size(3);
nY = inf1.Dataspace.Size(2);
chunkSize = inf1.ChunkSize

%h5create(outputfname,dsetname2,[nZ,nY, nX]);

%setlocations = cell(1);
%k = 1; 
subCubeDims = chunkSize*1;%[128 128 128]; % z,y,x
OL = 1;
%divz = ceil(nZ/subCubeDims(1))+1; setz = floor(linspace(0,nZ,divz));
setz = 1:subCubeDims(1)/OL:nZ;
if (setz(end)~= nZ) 
    setz = [setz, nZ];
end
%divy = ceil(nY/subCubeDims(2))+1; sety =  floor(linspace(0,nY,divy));
sety =  1:subCubeDims(2)/OL:nY;
if (sety(end)~= nY) 
    sety = [sety, nY];
end

%divx = ceil(nX/subCubeDims(3))+1; setx =  floor(linspace(0,nX,divx));
setx = 1: subCubeDims(3)/OL:nX;
if (setx(end)~= nX) 
    setx = [setx, nX];
end




%% find max first. 
%labellist = [];
mxlabel = 0; 
for iz= 1:length(setz)-1
    sz = setz(iz);
    for iy = 1:length(sety)-1 
            sy = sety(iy);
            for ix = 1: length(setx)-1
                sx = setx(ix);
                startix = [sz,sy,sx]; 
                %startix = [sz+1,sy+1,sx+1]; 
                counts = [subCubeDims(1),subCubeDims(2),subCubeDims(3)];
                if (iz == length(setz)-1) % last remaining cubes may not be 128
                    counts(1) = setz(end)-startix(1)+1;
                end
                if (iy == length(sety)-1) % last remaining cubes may not be 128
                    counts(2) = sety(end)-startix(2)+1;
                end
                if (ix == length(setx)-1) % last remaining cubes may not be 128
                    counts(3) = setx(end)-startix(3)+1;
                end
                endix = startix+counts; % startix <= pos< endix
                [startix;counts;endix];  
                subcube= h5read([root, fname],dsetname,startix,counts);
                maxlabelcube = max(subcube(:));
                %ulabels = unique(subcube(:));
                %subcube = permute(permute(subcube, [3, 2, 1]),[2,1,3]);
                %labelllist = [labellist,ulabels];
                if ( mxlabel< maxlabelcube)
                    mxlabel =maxlabelcube
                end
                    
            end
    end
end
%%
%% then size of each component first. 
labelhist = zeros(mxlabel+1,1);
%mxlabel = 0; 
for iz= 1:length(setz)-1
    sz = setz(iz);
    for iy = 1:length(sety)-1 
            sy = sety(iy);
            for ix = 1: length(setx)-1
                sx = setx(ix);
                startix = [sz,sy,sx]; 
                %startix = [sz+1,sy+1,sx+1]; 
                counts = [subCubeDims(1),subCubeDims(2),subCubeDims(3)];
                if (iz == length(setz)-1) % last remaining cubes may not be 128
                    counts(1) = setz(end)-startix(1)+1;
                end
                if (iy == length(sety)-1) % last remaining cubes may not be 128
                    counts(2) = sety(end)-startix(2)+1;
                end
                if (ix == length(setx)-1) % last remaining cubes may not be 128
                    counts(3) = setx(end)-startix(3)+1;
                end
                endix = startix+counts; % startix <= pos< endix
                [startix;counts;endix] ;
                subcube= h5read([root, fname],dsetname,startix,counts);
                subcubevec = subcube(:)+1;
                uniq_labels = unique(subcubevec);
                tk = hist(double(subcubevec), double(uniq_labels))';
                labelhist(uniq_labels) = labelhist(uniq_labels)+tk;
                %pause;
                %ulabels = unique(subcube(:));
                %subcube = permute(permute(subcube, [3, 2, 1]),[2,1,3]);
                %labelllist = [labellist,ulabels];
                %if ( mxlabel< maxlabelcube)
                %    mxlabel =maxlabelcube
                %end
                    
            end
    end
end

% for small volume it was 
%mxlabel= 476567
%%
    save(strcat(root, fname(1:end-4),'_detectionbb_mxlabel.mat'),'mxlabel', 'labelhist');
    %load(strcat(fname,'detectionbb_mxlabel.mat'));
    %ccpixlistxyz = cell(mxlabel,1);%, [1 1 1 1 1]);
    ccpixlistI = cell(mxlabel+1,1);%, [1 1 1 1 1]);
    labelhist(1)= 0; 
    Area_th = 1; 
    validregioncounter =0; 
    for ic = 1: mxlabel
        if(labelhist(ic) >= Area_th) 
            ccpixlistI{ic} = zeros(labelhist(ic),1);%, [1 1 1 1 1]);
            labelhist(ic);
            validregioncounter = validregioncounter+1;
        end
    end
    disp(strcat('total regions with size greater than area th:',int2str(validregioncounter)));
    labelcounter  = ones(size(labelhist)); 
%%
for iz= 1:length(setz)-1
    sz = setz(iz);
    for iy = 1:length(sety)-1 
            sy = sety(iy);
            for ix = 1: length(setx)-1
                sx = setx(ix);
               startix = [sz,sy,sx]; 
                counts = [subCubeDims(1),subCubeDims(2),subCubeDims(3)];
                if (iz == length(setz)-1) % last remaining cubes may not be 128
                    counts(1) = setz(end)-startix(1)+1;
                end
                if (iy == length(sety)-1) % last remaining cubes may not be 128
                    counts(2) = sety(end)-startix(2)+1;
                end
                if (ix == length(setx)-1) % last remaining cubes may not be 128
                    counts(3) = setx(end)-startix(3)+1;
                end
                endix = startix+counts; % startix <= pos< endix
                [startix;counts;endix]  ;
                subcube= h5read([root, fname],dsetname,startix,counts);
                %  unfortunately we have to do this because of ilastik xyz
                %  order
                subcube = permute(permute(subcube, [3, 2, 1]),[2,1,3]);

                [h,w,d] = size(subcube);
                subcubevec =subcube(:);
                labels_in_cube = unique(subcubevec);
                for lbix = 1: length(labels_in_cube)
                    
                    
                    curlabel =labels_in_cube(lbix); 
                    
                    % 0 is the label of the background
                    if(curlabel ==0 || labelhist(curlabel+1)< Area_th)
                        continue; 
                    end
                   %curlabel;
                   base0labelindex = curlabel+1;
                    labelhist(base0labelindex);
                     
                   
                    newI= find(subcube==curlabel);
                    [newpy, newpx,newpz] = ind2sub([h,w,d], newI);
                    %offsets of the current cube
                    volumex = newpx+startix(3)-1;  
                    volumey = newpy+startix(2)-1; 
                    volumez = newpz+startix(1)-1;
                    %transform these to big volume coordinates
                    Ix = sub2ind([nY, nX, nZ], volumey, volumex, volumez);
                    % we will add this many pixels
                    lenIx = length(Ix);
                    % keeps track of how many pix written of this label so
                    % far
                    curcount = labelcounter(base0labelindex);
                    %we write in the compoenent list 
                    if(isempty(ccpixlistI{base0labelindex}))
                        curcount
                        wrongg=1
                        %pause;
                    end
                    ccpixlistI{base0labelindex}(curcount:curcount+lenIx-1) =  Ix;
                    curcount = curcount+lenIx;
                    labelcounter(base0labelindex) = curcount;
                    %ccpixlistxyz{curlabel} = [ccpixlistxyz{curlabel};[volumex,volumey, volumez]];
                    
                end
                
                
                %CC = bwconncomp(subcube,6);%CC =bwconncomp(cubefilled,6);
                %for i = 1: CC.NumObjects
               % for i = 1: length(subcubevec)
               %     cclist{subcubevec} = [cclist{subcubevec}
               % end
                %subcubedecperm = permute(permute(subcubedec, [3, 2, 1]),[2,1,3]);
                
            end
    end
end

save(strcat(root, fname(1:end-3),'_detection_bbx_Ath',num2str(Area_th),'.mat'),'mxlabel','labelhist','labelcounter','ccpixlistI','-v7.3');
%save(strcat(fname,'_pixlist.mat'),'mxlabel','labelhist','labelcounter','ccpixlistI');
%%
% label, radius, cx,cy,cz, bblow, bbhigh
%ccpixbb = cell(0);%, [1 1 1 1 1]);
% fid = fopen(strcat(fname,'detection_pixlist_all.txt'),'wt');
% for ix = 1: length(ccpixlistxyz)
%     fprintf(fid, '%d ', ix);
%     fprintf(fid, '%d,', ccpixlistxyz{ix});
%     fprintf(fid, '\n');
% end
% fclose(fid);

% take only non eliminated and non empty components
nonempty = find(~cellfun(@isempty,ccpixlistI));

dummy = zeros(1,1,1);
CC = bwconncomp(dummy);
CC.PixelIdxList = ccpixlistI(nonempty);
CC.NumObjects = length(CC.PixelIdxList);
CC.ImageSize = [nY, nX, nZ];
CC.Connectivity = 6; 
% lets see if we can use regionprops
s  = regionprops(CC, 'centroid','BoundingBox','Area');
CC.centroids = cat(1, s.Centroid);
CC.bbx =  cat(1, s.BoundingBox);
CC.areas =  cat(1, s.Area);
%CC.mxlabel =CC.NumObjects;
% now find bbbox and centroids and dump
% fid = fopen('detectionsbb_all.txt','wt');
% for ix = 1: length(bbx)
%     fprintf(fid, '%d ', ix);
%     fprintf(fid, '%d ', int32(bbx(ix,:)));
%     fprintf(fid, '%d ', int32(areas(ix,:)));
%     fprintf(fid, '%d ', int32(centroids(ix,:)));
%     fprintf(fid, '\n');
% end

save(strcat(root, fname(1:end-3),'_detection_bbx_Ath_',num2str(Area_th),'_regionprops.mat'),'CC','Area_th','-v7.3');
%save(strcat(fname,'detectionbb_mxlabel_all_regionProps.mat'),'CC','Area_th');

