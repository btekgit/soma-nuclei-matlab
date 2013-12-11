function [rates,tdgt, tddt, fd,gt_hit,dt_hit ] = evaluateWithCenters(gtlist,CC, sizeIm)
% this function only finds close centers as hits.
% because of 1-1 match. It consider unmatched detections as false.
% however dt_hit_relaxed calculates more relaxed detection of 1-to-many to
% analyse if we find multiple objects trying to hit the same soma.
dt_ctr=  CC.centroids;
dt_pixlist = CC.PixelIdxList;

gtx = gtlist(:,1);
gty = gtlist(:,2);
gtz = gtlist(:,3);
gtr = gtlist(:,4);

% this part is for comparison without reconstruction
ndetections = length(dt_ctr);
gt_hit = zeros(length(gtr),1);
gt_misIx =[];
gt_hitIx = [];
gt_hitrelaxed = zeros(length(gtr),1);
dt_hit = zeros(ndetections,1);
dt_hit_relaxed = zeros(ndetections,1);
ngt = length(gtlist);
disp('completed: ');
for igt = 1: ngt
    
    completed = floor(igt/ngt*100);
    if (mod(igt,50)==0)
        fprintf('\b\b\b');
        fprintf('%3d', completed);
    end
    % is there a close center
    dist_centers = (gtz(igt)-dt_ctr(:,3)).*(gtz(igt)-dt_ctr(:,3))+...
        (gty(igt)-dt_ctr(:,2)).*(gty(igt)-dt_ctr(:,2))+ ...
        (gtx(igt)-dt_ctr(:,1)).*(gtx(igt)-dt_ctr(:,1));
    closeenough = sqrt(dist_centers)<= 100;%(1.5*gtr(igt));
    % by checking this I want to ensure if a detection was counted as hit
    % before it is not used again.
    closeenough_free = find(closeenough & ~dt_hit);
    
    nclose = length(closeenough_free);
    if(nclose>0)
        % counting the first unhit detection as a hit point
        %[dist_val, dt_hit_index] = min(dist_centers(closeenough_free));
        [mxIx,mxVal, overlaps] = calculateBestOverlap(gty(igt), gtx(igt),...
            gtz(igt), gtr(igt), nclose, closeenough_free, dt_pixlist, sizeIm);
        %[dt_hit_index] = closeenough_free(1);
        %if (mxVal>100)
        if ( mxVal >= gtr(igt))
            gt_hit(igt) = 1;
            dt_hit(closeenough_free(mxIx)) = 1;
            dt_hit_relaxed(closeenough_free) = 1;
        end
    end
    
    if(gtx(igt)<320 & gtx(igt)>230 & gty(igt)<320 & gty(igt)>250 & gtz(igt)<80)
        gtlist(igt,:)
    end
    
    
    
    
end

tdgt = sum(gt_hit)
tddt = sum(dt_hit)
fddt_relaxed = ndetections -sum(dt_hit_relaxed)



fd = ndetections -tddt
% true detection vs number of false positives
rates = [tdgt/ngt, fd]
end

function [mxIx,mxVal,overlaps] = calculateBestOverlap(gty, gtx, gtz, gtr, ndets, dtpixIx, dtlist, sizeIm)

overlaps = zeros(ndets,1);
for i = 1: ndets
    pixlist = dtlist{dtpixIx(i)};
    nPix = calculateInRadiusPix(gty, gtx, gtz, gtr, pixlist, sizeIm);
    overlaps(i) = nPix;
end
[mxVal, mxIx] = max(overlaps);

end


