% nearest neighbour and ripley 

% nearest neighbor
function res_dists = nnDistance3D(loc3d)
[N,k]=size(loc3d);
if(k==3)
    disp('this works with 3d');
end
DX = repmat(loc3d(:,1),1,N)-repmat(loc3d(:,1)',N,1);
DY = repmat(loc3d(:,2),1,N)-repmat(loc3d(:,2)',N,1);
DZ = repmat(loc3d(:,3),1,N)-repmat(loc3d(:,3)',N,1);
dists = sqrt(DX.^2+DY.^2+DZ.^2);
dists_sorted = sort(dists);
res_dists = dists_sorted(2,:);

% measure radius change with respect to Z axis. 
% measure spacing btw somas with respect o Z