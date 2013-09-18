function K = RipleysK(locs,distbins,box,method);
% RipleysK: Calculate K statistic
% 
% K = RipleysK(locs,dist, box,method) calculates G, the K statistic at each 
% distance for the data with x-y coordinates given by locs, and the
% bounding rectangle given by box=[minX maxX minY maxY minZ maxZ].
% If method=0, no edge correction is applied.
% If method=1, points are only used if they are at least h units away from
% the edge.
%
% Note: The L statistic may be calculated from the K statistic as follows: 
%   L = sqrt(K/pi)-h;
% Edited to make it work for 3D

if nargin<4, method=1; end
[N,k] = size(locs);
if k~=3, error('locs must have three columns for this version'); end
rbox = min([locs(:,1)'-box(1);box(2)-locs(:,1)';locs(:,2)'-box(3); box(4)-locs(:,2)';locs(:,3)'-box(5); box(6)-locs(:,3)' ] );
% rbox is distance to box

DX = repmat(locs(:,1),1,N)-repmat(locs(:,1)',N,1);
DY = repmat(locs(:,2),1,N)-repmat(locs(:,2)',N,1);
DZ = repmat(locs(:,3),1,N)-repmat(locs(:,3)',N,1);
dists = sqrt(DX.^2+DY.^2+DZ.^2);
dists = sort(dists);

if method==1
K = zeros(length(distbins),1);
for k=1:length(K)
    I = find(rbox>distbins(k));
    if ~isempty(I)
        K(k) = sum(sum(dists(2:end,I)<distbins(k)))/length(I);
    end
end
elseif method==0
    K = zeros(length(distbins),1);
    for k=1:length(K)
        K(k) = sum(sum(dists(2:end,:)<distbins(k)))/N;
    end
end

lambda = N/((box(2)-box(1))*(box(4)-box(3)));
K = K/lambda;