function CC=blockWiseComponentAccumulator(folder, filename, datasetname, ...
    chunkSizeMultiplier, Volume_th, saveResults,verbose)
%function blockWiseComponentAccumulator(folder, filename, datasetname, ...
%chunkSizeMultiplier, Volume_th, saveResults,verbose)
%
% This function calculates bounding box, centroid, and voxel coordinate lists
%   from a labelled volume (uint32) stored in an hdf5 dataset located in
%   'folder/filename/datasetname'.
%
% It performs this by blockwise accumulation of the components.
% an optional threshold Volume_th eliminates smaller components
%
%
% Arguments: folder, filename, datasetname
%
%
% [optional arguments]: chunkSizeMultiplier, Volume_th, saveResults,verbose
%
% chunkSizeMultiplier: hdf5dataset is processed in blocks which are a
%   chunkSizeMultiplier multiple of data chunkSize.
%
% Volume_th: threshold value to eliminate small components. Default value
%   is 5
%
% saveResults: it saves intermediate and final results to mat files in the
%   same folder. if saveResults parameter is a string it assumes that this
%   is the output filename to be written in the same folder as input.
%
% verbose: displays some information during operation.
%
% NOTE: if you get memory errors during operation you can
%   increase Volume_th to eliminate more components.
%
%


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


%% arguments
if(nargin<3)
    error('You must supply at least folder, filename, and datasetname');
    return;
else
    disp('Processing dataset:');
    inf1 = h5info([folder, filename],datasetname)
    chunkSize = inf1.ChunkSize
    nZ = inf1.Dataspace.Size(1);
    nX = inf1.Dataspace.Size(3);
    nY = inf1.Dataspace.Size(2);
    
    % ilastik produces xyz order prediction which is protected by
    % connected components.
    xyzOrder= 1;
    
    if(nargin<4)
        disp('using default values for:');
        chunkSizeMultiplier = 1
        Volume_th = 5
        verbose = 1
        saveResults = 1
    elseif (nargin<5)
        chunkSizeMultiplier
        disp('using default values for:');
        Volume_th = 5
        verbose = 1
        saveResults=1
    elseif(nargin<6)
        chunkSizeMultiplier
        Volume_th
        disp('using default values for:');
        saveResults=1
        verbose = 1
    elseif (nargin<7)
        chunkSizeMultiplier
        Volume_th
        verbose
        saveResults
        disp('using default value for');
        verbose = 1
    else
        chunkSizeMultiplier
        Volume_th
        verbose
        saveResults
        verbose
    end
end

    if(ischar(saveResults))
    if(~strcmpi(saveResults(end-3:end),'.mat'))
        error([saveResults,' has not a .mat extension'])
    end
    resultsMatFile = strcat([folder,saveResults]);
elseif( saveResults ==1)
    resultsMatFile = strcat(folder, filename(1:end-4),'_bwca.mat');
end

if(verbose)
    fprintf('             \n');
end


%%
%start with calculating block starting positions.

subCubeDims = chunkSize*chunkSizeMultiplier;%e.g.[128 128 128]; % z,y,x
setz = 1:subCubeDims(1):nZ;
if (setz(end)~= nZ)
    setz = [setz, nZ];
end

sety =  1:subCubeDims(2):nY;
if (sety(end)~= nY)
    sety = [sety, nY];
end

setx = 1: subCubeDims(3):nX;
if (setx(end)~= nX)
    setx = [setx, nX];
end

%% find maximum label value first.
if(verbose)
    disp('computing the maximum:                          ');
end
mxlabel = -1;
for iz= 1:length(setz)-1
    sz = setz(iz);
    for iy = 1:length(sety)-1
        sy = sety(iy);
        for ix = 1: length(setx)-1
            if(verbose)
                completed = floor(iz/length(setz)*100);
                progressDisp(completed);
            end
            
            sx = setx(ix);
            % the start position
            startix = [sz,sy,sx];
            % cube dimensions to read in z,y,x
            counts = [subCubeDims(1),subCubeDims(2),subCubeDims(3)];
            if (iz == length(setz)-1)
                counts(1) = setz(end)-startix(1)+1;
            end
            if (iy == length(sety)-1)
                counts(2) = sety(end)-startix(2)+1;
            end
            if (ix == length(setx)-1)
                counts(3) = setx(end)-startix(3)+1;
            end
            % read it directly
            subcube= h5read([folder, filename],datasetname,startix,counts);
            % check max
            maxlabelcube = max(subcube(:));
            if ( mxlabel< maxlabelcube)
                mxlabel =maxlabelcube;
            end
            
        end
    end
end
% display max label
if(verbose)
    mxlabel
    disp('now counting number of voxels in each component:                  ');
end
%%

% then calculate length of each component first.
labelhist = zeros(mxlabel+1,1);
for iz= 1:length(setz)-1
    sz = setz(iz);
    for iy = 1:length(sety)-1
        sy = sety(iy);
        for ix = 1: length(setx)-1
            if(verbose)
                completed = floor(iz/length(setz)*100);
                progressDisp(completed);
            end
            sx = setx(ix);
            startix = [sz,sy,sx];
            counts = [subCubeDims(1),subCubeDims(2),subCubeDims(3)];
            if (iz == length(setz)-1)
                counts(1) = setz(end)-startix(1)+1;
            end
            if (iy == length(sety)-1)
                counts(2) = sety(end)-startix(2)+1;
            end
            if (ix == length(setx)-1)
                counts(3) = setx(end)-startix(3)+1;
            end
            % read the cubse
            subcube= h5read([folder, filename],datasetname,startix,counts);
            % add one because labels are zero based
            subcubevec = subcube(:)+1;
            % find unique in this cube
            uniq_labels = unique(subcubevec);
            % calculate hist which basically counts the voxels for each
            % label
            tk = hist(double(subcubevec), double(uniq_labels))';
            % this histogram is accumulated
            labelhist(uniq_labels) = labelhist(uniq_labels)+tk;
        end
    end
end
%% saving
if(verbose & saveResults)
    disp('');
    disp('saving maximum label value and component voxel counts');
    save(resultsMatFile,'mxlabel', 'labelhist');
end


%% Volume thresholding elimination of smaller components
ccpixlistI = cell(mxlabel+1,1);
labelhist(1)= 0;
validregioncounter =0;
for ic = 1: mxlabel
    if(labelhist(ic) >= Volume_th)
        ccpixlistI{ic} = zeros(labelhist(ic),1,'uint64');
        validregioncounter = validregioncounter+1;
    end
end
if(verbose)
    disp(strcat('Total regions with size greater than area th:',int2str(validregioncounter)));
    disp('now accumulating voxel lists                        ');
end
labelcounter  = ones(size(labelhist));
%%
for iz= 1:length(setz)-1
    sz = setz(iz);
    for iy = 1:length(sety)-1
        sy = sety(iy);
        for ix = 1: length(setx)-1
            if(verbose)
                completed = floor(iz/length(setz)*100);
                progressDisp(completed);
            end
            
            sx = setx(ix);
            startix = [sz,sy,sx];
            counts = [subCubeDims(1),subCubeDims(2),subCubeDims(3)];
            if (iz == length(setz)-1) % last remaining cubes may not be multiple of 128
                counts(1) = setz(end)-startix(1)+1;
            end
            if (iy == length(sety)-1)
                counts(2) = sety(end)-startix(2)+1;
            end
            if (ix == length(setx)-1)
                counts(3) = setx(end)-startix(3)+1;
            end
            subcube= h5read([folder, filename],datasetname,startix,counts);
            %  unfortunately we have to do this because of ilastik xyz
            %  order and matlab's y,x,z order needs double permutation
            %  of data
            % Below first converts data to zyx then yzx.
            % if data is zyx is order you do not need to do double
            % permute. if (xyzOrder)
            subcube = permute(permute(subcube, [3, 2, 1]),[2,1,3]);
            % end
            [h,w,d] = size(subcube);
            subcubevec =subcube(:);
            labels_in_cube = unique(subcubevec);
            
            % start accumulation for each label in this cube
            for lbix = 1: length(labels_in_cube)
                
                curlabel =labels_in_cube(lbix);
                
                % 0 is the label of the background
                if(curlabel ==0 || labelhist(curlabel+1)< Volume_th)
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
                %transform these to global volume coordinates
                Ix = sub2ind([nY, nX, nZ], volumey, volumex, volumez);
                % add this many voxels
                lenIx = length(Ix);
                % keeps track of how many vox written of this label so
                % far
                curcount = labelcounter(base0labelindex);
                %we write in the compenent list
                if(isempty(ccpixlistI{base0labelindex}))
                    warning('the pixel list count and labels are not consistent, make sure that background label is zero');
                    %pause;
                end
                ccpixlistI{base0labelindex}(curcount:curcount+lenIx-1) =  Ix;
                curcount = curcount+lenIx;
                labelcounter(base0labelindex) = curcount;
            end
        end
    end
end

%% saving again
if(verbose)
    disp('');
    disp(' saving maximum label value, component voxel counts, and component voxel lists');,
end
if  saveResults
    save(resultsMatFile,'mxlabel','labelhist','Volume_th','labelcounter','ccpixlistI','-v7.3');
end
if verbose
    disp('now calcualating region props');
end

%% calculating region props, bounding box and centroids
% call matlab's regionprops, takes some time but it does it.
% other-wise we can simply loop over the ccpixlistI and calculate everything
% simply.

% take only non eliminated and non empty components
nonempty = find(~cellfun(@isempty,ccpixlistI));

dummy = zeros(1,1,1);
CC = bwconncomp(dummy);
CC.PixelIdxList = ccpixlistI(nonempty);
CC.NumObjects = length(CC.PixelIdxList);
CC.ImageSize = [nY, nX, nZ];
CC.Connectivity = 6;

%
s  = regionprops(CC, 'centroid','BoundingBox','Area');
CC.centroids = cat(1, s.Centroid);
CC.bbx =  cat(1, s.BoundingBox);
CC.areas =  cat(1, s.Area);

if(verbose)
    disp('');
    disp('saving the data structure which ');
end
if saveResults
    save(resultsMatFile,'CC','Volume_th','-v7.3');
end

%% optionally you can dump them to txt files which takes too long;
% fid = fopen('detectionsbb_all.txt','wt');
% for ix = 1: length(bbx)
%     fprintf(fid, '%d %d %d %d', ix, bbx(ix,:), areas(ix,:),centroids(ix,:));
%     fprintf(fid, '\n');
% end

end
function progressDisp(completed)
    fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');
    fprintf('Completed:%3d/100', completed);
end