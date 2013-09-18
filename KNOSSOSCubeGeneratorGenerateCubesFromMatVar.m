function KNOSSOS_cubeGenerator_generateCubesFromMatVar(matVar,kn_outputParentFolder,...
    kn_voxelsize,kn_datasetIDstr)
%function KNOSSOS_cubeGenerator_generateCubesFromMatVar(matVar,kn_outputParentFolder,...
%    kn_voxelsize,kn_datasetIDstr)
    
%     dattt = load ('charimg');
% 
%     cubedata3d = repmat(dattt.t,[2,3,1]);
%     cubedata3d = repmat(cubedata3d,[1,1,128]);
%     matVar = cubedata3d;
    sizeData = size(matVar);
    
    %kn_bboxes = [onlyones,repmat(sizeData(1),sizeData(3),1), ...
    %    onlyones, repmat(sizeData(2),sizeData(3),1), [1:sizeData(3)]', [1:sizeData(3)]'];
    %[kn_bboxes, kn_fnames]= xlsread(kn_xlsfname);
    %kn_txtoffset=1;
    
    kn_outputcubesize = [128 128 128];
    kn_cuberange = [1 sizeData(1)/kn_outputcubesize(1);1 sizeData(2)/kn_outputcubesize(2);1 sizeData(3)/kn_outputcubesize(3)];
    KNOSSOS_writeKconfFile(kn_outputParentFolder,kn_datasetIDstr,kn_cuberange(:,2)'*128,kn_voxelsize,1);
    for kn_z=kn_cuberange(3,1):kn_cuberange(3,2)
        for kn_x=kn_cuberange(2,1):kn_cuberange(2,2)
            for kn_y=kn_cuberange(1,1):kn_cuberange(1,2)
                tic
                kn_thisBBox = [([kn_x kn_y kn_z]-1)*128 + 1;
                    [kn_x kn_y kn_z]*128]';
                kn_thiscube = matVar(kn_thisBBox(2,1):kn_thisBBox(2,2), kn_thisBBox(1,1):kn_thisBBox(1,2),...
                    kn_thisBBox(3,1):kn_thisBBox(3,2));
                    %kn_thiscube = reshape(kn_thiscube,prod(kn_outputcubesize),1);
                    kn_thiscube = reshape(permute(kn_thiscube, [2,1,3]),prod(kn_outputcubesize),1);
                
                    kn_outputpname = KNOSSOS_generateDir(kn_outputParentFolder,[kn_x kn_y kn_z]-1);
                    fid=fopen(fullfile(kn_outputpname,sprintf('%s_x%04.0f_y%04.0f_z%04.0f.raw',kn_datasetIDstr,[kn_x kn_y kn_z]-1)),'w+');
                    fwrite(fid,kn_thiscube);
                    fclose(fid);
                
                fprintf('cube [x y z] = [%d %d %d] done.\n',[kn_x kn_y kn_z]-1);
                toc
            end
        end
    end
    
end
