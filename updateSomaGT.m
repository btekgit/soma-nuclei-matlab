%% add additional soma's to Shawn original  
function gtlist = updateSomaGT(gtlist)
s = load('btek_marked_gt.txt')
%columns x,y,z,Label of the detection (to learn the size. ) 

% however I will skip the size and use a fix size of radius =10;
slabels = s(:,4);
% some are duplicate
[slabels_unique, ix] = unique(slabels,'last');

%
length(ix)
%disp(' additional gt');
add_gt = s(ix,1:3);
FIX_RADIUS = ones(length(ix),1).*12; 
add_gt = [FIX_RADIUS,add_gt];
fprintf('original gt size:%d, added = %d \n', length(gtlist), length(ix));
gtlist = [gtlist;add_gt];
length(gtlist)
%search for overlaping ones of the ones we are adding. 
clean_new_gt =[];
for i = 1:  length(gtlist)
    dist_centers = (gtlist(i,2)-gtlist(:,2)).*(gtlist(i,2)-gtlist(:,2))+...
        (gtlist(i,3)-gtlist(:,3)).*(gtlist(i,3)-gtlist(:,3))+ ...
        (gtlist(i,4)-gtlist(:,4)).*(gtlist(i,4)-gtlist(:,4));
    % there is a another gt less than one radius away
    closeenough = sqrt(dist_centers)<= gtlist(i,1); 
    % by checking this I want to ensure if a detection was counted as hit
    % before it is not used again.
    closeenough_other = setdiff(find(closeenough),i);
    if ~isempty(closeenough_other)
        for j = 1: length(closeenough_other)
            fprintf('gt %d and gt %d ',i, closeenough_other(j));
            gtlist(i,:)
            gtlist(closeenough_other(j),:)
            %pause;
        end
    end
end
        
% post study  confirmed  that indices 44, 1008, 3147 are doubles. 
remove_indices = [44,1008,3147];
fprintf('removing index: %d \n', remove_indices);

valids = setdiff(1:length(gtlist), remove_indices);
gtlist = gtlist(valids,:);
fprintf('final length of gts:%d \n', length(gtlist));

    
