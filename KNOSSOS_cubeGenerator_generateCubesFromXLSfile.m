function KNOSSOS_cubeGenerator_generateCubesFromXLSfile(kn_xlsfname,kn_outputParentFolder,...
    kn_cuberange,kn_voxelsize,kn_datasetIDstr)


    [kn_bboxes, kn_fnames]= xlsread(kn_xlsfname);
    kn_txtoffset=1;
    
    kn_outputcubesize = [128 128 128];
    %         kn_cuberange = [1 24;1 9;1 1];
    KNOSSOS_writeKconfFile(kn_outputParentFolder,kn_datasetIDstr,kn_cuberange(:,2)'*128,kn_voxelsize,1);
    for kn_z=kn_cuberange(3,1):kn_cuberange(3,2)
        for kn_x=kn_cuberange(1,1):kn_cuberange(1,2)
            for kn_y=kn_cuberange(2,1):kn_cuberange(2,2)
                tic
                kn_thisBBox = [([kn_x kn_y kn_z]-1)*128 + 1;
                    [kn_x kn_y kn_z]*128]';
                kn_thiscube = repmat(uint8(0),kn_outputcubesize);
                kn_anyData=0;
                for kn_roic=1:size(kn_bboxes,1)
                    %                         [kn_x kn_y kn_z kn_roic]
                    kn_thisroibbox = reshape(kn_bboxes(kn_roic,:),[2 3])';
                    kn_overlapBbox = mh_bboxOverlap(kn_thisBBox,kn_thisroibbox);
                    if ~isempty(kn_overlapBbox)
                        kn_anyData=1;
                        kn_overlapBBox_incube = kn_overlapBbox-repmat(kn_thisBBox(:,1),[1 2])+1;
                        kn_overlapBBox_insource = kn_overlapBbox-repmat(kn_thisroibbox(:,1),[1 2])+1;
                        kn_overlapBBox_insource(3,:) = [1 1]; % brute force change later
                        kn_image = imread(kn_fnames{kn_txtoffset+kn_roic})';
                        kn_thiscube(kn_overlapBBox_incube(1,1):kn_overlapBBox_incube(1,2),...
                            kn_overlapBBox_incube(2,1):kn_overlapBBox_incube(2,2),...
                            kn_overlapBBox_incube(3,1):kn_overlapBBox_incube(3,2)) = ...
                            kn_image(kn_overlapBBox_insource(1,1):kn_overlapBBox_insource(1,2),...
                            kn_overlapBBox_insource(2,1):kn_overlapBBox_insource(2,2),...
                            kn_overlapBBox_insource(3,1):kn_overlapBBox_insource(3,2));
                    end
                end
                if kn_anyData>0
                    kn_outputpname = KNOSSOS_generateDir(kn_outputParentFolder,[kn_x kn_y kn_z]-1);
                    fid=fopen(fullfile(kn_outputpname,sprintf('%s_x%04.0f_y%04.0f_z%04.0f.raw',kn_datasetIDstr,[kn_x kn_y kn_z]-1)),'w+');
                    fwrite(fid,kn_thiscube);
                    fclose(fid);
                end
                fprintf('cube [x y z] = [%d %d %d] done.\n',[kn_x kn_y kn_z]-1);
                toc
            end
        end
    end
    
end
