function [gt,dt,nDt,nTd, nFp, overlap] = compareCube2GT(labelledcube, gt, dt, boundslow, boundshigh)


CCdetections = bwconncomp(labelledcube);
ndtpoints = CCdetections.NumObjects;
if (ndtpoints ==0)
    disp('no detected objects');
    nDt = 0;
    nTd = 0;
    nFp = 0;
    return; 
end

s  = regionprops(CCdetections, 'centroid');
 % this is xyz order I guess, we must add the lowerbounds
dtCentroids = cat(1, s.Centroid);
dtCentroids(:,1) = boundslow(1)+dtCentroids(:,1); % X
dtCentroids(:,2) = boundslow(2)+dtCentroids(:,2); % Y
dtCentroids(:,3) = boundslow(3)+dtCentroids(:,3); % Z

dthitlist = zeros(ndtpoints,1);
nTd = 0; 
nFp = 0; 
gtlist = gt.validannotations;

% get coordinates
gtcoordx = gtlist(:,4);
gtcoordy = gtlist(:,5);
gtcoordz = gtlist(:,6);

[gtlistROI, gtIndx, gtMask] = getGTInROI(gtlist, boundslow, boundshigh);
toProcess_idx = gtIndx; % to know of GT processed

% check if they are already processed
processed_status = gt.processed(gtIndx);
% if(any(processed_status))
%     sum(processed_status)
%     disp('points already processed')
%     toProcess_idx = toProcess_idx(~processed_status);
% end

gt.processed(toProcess_idx) = gt.processed(toProcess_idx)+1;  %% this will give how many times we visited same gt


%sliceview(double(gtmask)+labelledcube)
% calculate intersections and overlap
accumulate_intersections = gtmask;
accumulate_intersections(:,:,:) = 0; 
for igt = 1: ngtpoints
    submask = gtmask==igt;
    if(sum(submask(:))==0) 
        disp('somethings wrong');
    end
    % intersect and union
    submask_int = submask & labelledcube;
    submask_int_volume = sum(submask_int(:));
    submask_volume = 4/3*pi*gtr(igt).^3;
    submask_overlap_ratio = submask_int_volume/submask_volume;
    if(submask_overlap_ratio>gt.overlap(toProcess_idx(igt)))
      gt.overlap(toProcess_idx(igt)) = submask_overlap_ratio;
      
      accumulate_intersections(submask_int) = 1;
      % the value in the labelled cube
      mskdetection = unique(labelledcube(submask_int>0))
      dtlabel = unique(mskdetection(:));
      gt.hits(toProcess_idx(igt),:) = dtCentroids(dtlabel(1),:);
      dthitlist(dtlabel) = submask_overlap_ratio; 
    end
    
end
% number of detection regions, assuming edge overlappings are cleared.
% labelled_rec = imreconstruct(accumulate_intersections, labelledcube);
% labelled_nothit = labelledcube-labelled_rec;
% nothit_relabelled= bwlabeln(labelled_nothit);
% mxlabel = max(nothit_relabelled(:)); %% this seems as fpositive for now.
% 
% nuniquelabels = length(unique(labelledcube(:)));
% if(mxlabel~=nuniquelabels)
%     disp('relabelling');
%     labelledcube = bwlabeln(labelledcube,6);
%     mxlabel = max(labelledcube(:));
% end




% s  = regionprops(CC, 'centroid');
% % this is xyz order I guess, we must add the lowerbounds
% dtCentroids = cat(1, s.Centroid);
% dtCentroids(:,1) = boundslow(1)+dtCentroids(:,1); % X
% dtCentroids(:,2) = boundslow(2)+dtCentroids(:,2); % Y
% dtCentroids(:,3) = boundslow(3)+dtCentroids(:,3); % Z

% prepare lists.
%dtfplist = dthitlist;

%TH_R = 30; % to say true detection we must be 10 pixels close to another point
% true detection


% %for igt = 1: ngtpoints
%     % labelled cube y,x,z order
%     labelatpoint = labelledcube(gty(igt)-boundslow(2),gtx(igt)-boundslow(3),gtz(igt)-boundslow(1));
%     gt.overlap(toProcess_idx(igt)) = labelatpoint;
%     
%     for idt = 1: ndtpoints
%         
%         % do not match 2-1 check if gt is closeenough
%         if(~dthitlist(idt))
%             diste = (gtz(igt)-dtCentroids(idt,3))*(gtz(igt)-dtCentroids(idt,3))+...
%                 (gty(igt)-dtCentroids(idt,2))*(gty(igt)-dtCentroids(idt,2))+ ...
%                 (gtx(igt)-dtCentroids(idt,1))*(gtx(igt)-dtCentroids(idt,1));
%             closeenough = sqrt(diste)< TH_R;
%             %sqrt(diste)
%             if( closeenough)
%                 
%                 gt.hitdistance(toProcess_idx(igt)) = sqrt(diste);
%                 gt.hitCentroidHits(toProcess_idx(igt)) = 1;
%                 
%                 dthitlist(idt)= 1;
%                 break;
%                 
%                 % calculate overlap  will be completed later 
% %                 gtgridpoints = ngrid(ceil(gtz(igt)-gtr(igt)):floor(gtz(igt)-gtr(igt)),...
% %                 ceil(gtz(igt)-gtr(igt)):floor(gtz(igt)-gtr(igt)), ...
% %                 ceil(gtz(igt)-gtr(igt)):floor(gtz(igt)-gtr(igt)));
% %                 labelledcubeidx = labelledcube==idt;
% %                 cubelabelvolume = 
% %                 gt.overlap 
%                
%             end
%         end
%     end
% end
nDt = ndtpoints
nTd = sum(dthitlist>0)
nFp = nDt -nTd
nFn = sum(gt.overlap(toProcess_idx) ==0)
    
% dtlist is a growing list of centroids, so I will not process same
% centroid twice. and calculate false positive correctly 
% order centroid, z,y,x, hit |miss
dt = [dt;[dtCentroids,dthitlist]];




% for ix =1:10:length(msk(:))
%     [sy,sx,sz] = ind2sub(sizcube,ix);
%     ssy = sy.*ones(lengt,1);ssx = sx.*ones(lengt,1);ssz = sz.*ones(lengt,1);
% 	
%     dist = abs(ssy-y)+abs(ssx- x)+abs(ssz- z);
%     distinrange = dist<=r; 
% 	lab = min(find(distinrange==1));
% 	if ( ~isempty(lab))
% 		msk(ix) = lab;
% 	end
%     
% end



