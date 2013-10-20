%knossos xml to matlab array

% This is the first ground truth used in isbi 2013
%xDoc = parseNML('interareal-somamap-complete.nml')
xDoc = parseNML('D:\mouse_brain\20130506-interareal_mag4\gtfiles\interareal-somamap-complete-labeled.nml')

nChilds = length(xDoc.Children);
gtmarks = zeros(nChilds, 6)-1; % tid, id, radius, z,y,x
gtlabels = zeros(nChilds,2)-1;
for i = 1: nChilds
    thischild = xDoc.Children(i)
    if(strcmp(thischild.Name,'thing'))
        attribute = thischild.Attributes(6);
        tid = -2;
        if(strcmp(attribute.Name, 'id'));
            tid = attribute.Value;
        end
        gtmarks(i,1) = str2double(tid);
        nchildren = length(thischild.Children);
        for c = 1: nchildren
            if(strcmp(thischild.Children(c).Name, 'nodes'))
                thisnodes = thischild.Children(c);
                nnodes = length(thisnodes.Children);
                for n = 1: nnodes
                    if(strcmp(thisnodes.Children(n).Name,'node'))
                        thisnode = thisnodes.Children(n);
                        thisnodeAtt = thisnode.Attributes;
                        na = length(thisnodeAtt);
                        for a =1: na
                            thisAtt = thisnodeAtt(a);
                            if(strcmp(thisAtt.Name, 'id'))
                                gtmarks(i,2) = str2double(thisAtt.Value);
                            elseif (strcmp(thisAtt.Name, 'radius'))
                                gtmarks(i,3) = str2double(thisAtt.Value);
                                
                            elseif (strcmp(thisAtt.Name, 'x'))
                                gtmarks(i,4) = str2double(thisAtt.Value);
                                
                            elseif (strcmp(thisAtt.Name, 'y'))
                                gtmarks(i,5) = str2double(thisAtt.Value);
                                
                            elseif (strcmp(thisAtt.Name, 'z'))
                                gtmarks(i,6) = str2double(thisAtt.Value);
                            end
                        end
                    end
                end
            end
        end
    elseif(strcmp(thischild.Name,'comments'))
        nchildren = length(thischild.Children);
        for c = 1: nchildren
            thisnode = thischild.Children(c);
            if(~strcmp(thisnode.Name,'comment'))
                continue;
            end
            thisnodeAtt = thisnode.Attributes;
            na = length(thisnodeAtt);
            for a =1: na
                thisAtt = thisnodeAtt(a);
                index =-1;
                if(strcmp(thisAtt.Name, 'node'))
                    index = int32(str2double(thisAtt.Value));
                    gtlabels(c,1) = index;
                elseif (strcmp(thisAtt.Name, 'content'))
                    thislabel = thisAtt.Value;
                    if(strcmp(thislabel,'n'))
                        gtlabels(c,2) = 1;
                    elseif(strcmp(thislabel,'g'))
                        gtlabels(c,2) = 2;
                    elseif(strcmp(thislabel,'v'))
                        gtlabels(c,2) = 3;
                    elseif(strcmp(thislabel,'gc'))
                        gtlabels(c,2) = 4;
                    else
                        gtlabels(c,2) = 5;
                        thislabel
                    end
                    
                end
            end
        end
        
    end
    
end

% some nodes have no node

posids = gtmarks(:,1)>0;
validnodes = gtmarks(posids,:);
validids = gtmarks(:,2)>0;
validannotations=gtmarks(validids,:);

validids = gtlabels(:,2)>0;
validClassLabels=gtlabels(validids,:);
% magnification is embedded into coordinates remove it.
gtmag =4;
validannotations(:,3:6) = validannotations(:,3:6)./gtmag;
validannotations= floor(validannotations);

% possibly this is zero based index- must add one. but did not
zerobasedindexing = 1

%save('gtintereal20130506.mat', 'gtmarks', 'validannotations', 'zerobasedindexing');
save('gtintereal20130506_12_10_13.mat', 'gtmarks', 'validannotations', 'zerobasedindexing');

% save this thing
% also some node's have no attribute, check validmarks second column > 0
% for valid marks.



