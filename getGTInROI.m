function [gtIn, gtIndex,gtMask] = getGTInROI(gtlist, boundslow, boundshigh, sizecube, removeEdges)
% returns back the ground truth points inside the Region Volume of Interest
% boundslow [minz, miny, minx], boundshigh [maxz,... 
%get coordinates of KNOSSOS ground truth
boundslow
boundshigh
gtcoordx = gtlist(:,2);
gtcoordy = gtlist(:,3);
gtcoordz = gtlist(:,4);
rng_x= [max(gtcoordx), min(gtcoordx)];
rng_y= [max(gtcoordy), min(gtcoordy)];
rng_z=[max(gtcoordz), min(gtcoordz)];


subvolumegt_idx = find(gtcoordz>=boundslow(1) & gtcoordy>=boundslow(2) & gtcoordx>=boundslow(3)...
    & gtcoordz<=boundshigh(1) & gtcoordy<=boundshigh(2) & gtcoordx<=boundshigh(3));

toProcess_idx = subvolumegt_idx; % to know of GT processed
gtz = gtcoordz(subvolumegt_idx);
gty = gtcoordy(subvolumegt_idx);
gtx = gtcoordx(subvolumegt_idx);
gtr = gtlist(subvolumegt_idx,1); % this is the column of radius

% number of gt marks in the subvolume
nGTSubvolume = length(gtr);

%create coordinates of the subvolume
%[gridz,gridy,gridx] = ngrid(boundslow(1):boundshigh(1),boundslow(2):boundshigh(2),boundslow(3):boundshigh(3));
if( removeEdges)
% remove non edge ones;
 nonEdgeGt_idx = find(((gtz-gtr)> boundslow(1)) & ((gtz+gtr) < boundshigh(1)) & ...
     ((gty-gtr) > boundslow(2)) & ((gtr+gty)<boundshigh(2)) & ...
     ((gtx-gtr) > boundslow(3)) & ((gtx+gtr) < boundshigh(3)));
 
toProcess_idx = subvolumegt_idx (nonEdgeGt_idx); % to know of GT processed
% 
 gtz = gtcoordz(toProcess_idx);
 gty = gtcoordy(toProcess_idx);
 gtx = gtcoordx(toProcess_idx);
 gtr = gtlist(toProcess_idx,1); % this is the column of radius
% % final gt points to compare
 nonedgeGTpoints = length(gtr);
end


gtIn = [gtr,gtx, gty,gtz];
gtIndex = toProcess_idx;
% reconstruct them to visualize % may be to measure overlap.
if(nargout==3)
    gtMask = reconstructGTMask(sizecube,gty-boundslow(2),gtx-boundslow(3),gtz-boundslow(1),gtr);
end
