%knossos xml to matlab array

xDoc = parseNML('interareal-somamap-complete.nml')

nChilds = length(xDoc.Children);
gtmarks = zeros(nChilds, 6)-1; % tid, id, radius, z,y,x
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
    end
end

% some nodes have no node

posids = gtmarks(:,1)>0;
validnodes = gtmarks(posids,:);
validids = gtmarks(:,2)>0;
validannotations=gtmarks(validids,:);
% magnification is embedded into coordinates remove it. 
gtmag =4; 
validannotations(:,3:6) = validannotations(:,3:6)./gtmag;  
validannotations= floor(validannotations);

% possibly this is zero based index- must add one. but did not
zerobasedindexing = 1
save('gtintereal20130506.mat', 'gtmarks', 'validannotations', 'zerobasedindexing');
% save this thing
% also some node's have no attribute, check validmarks second column > 0
% for valid marks.

                            

