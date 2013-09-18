function KNOSSOS_copy_cube_subset(kl_bbox_cubeIDs,kl_sourceDir,kl_targetDir)

    kl_systemStr = sprintf('mkdir \"%s\"',kl_targetDir)
    system(kl_systemStr);

    for kl_x=kl_bbox_cubeIDs(1,1):kl_bbox_cubeIDs(1,2)
        kl_systemStr = sprintf('mkdir \"%s\"',fullfile(kl_targetDir,sprintf('x%04.0f',kl_x)))
        system(kl_systemStr);
        for kl_y=kl_bbox_cubeIDs(2,1):kl_bbox_cubeIDs(2,2)
            kl_systemStr = sprintf('mkdir \"%s\"',fullfile(kl_targetDir,sprintf('x%04.0f',kl_x),sprintf('y%04.0f',kl_y)))
            system(kl_systemStr);
            for kl_z=kl_bbox_cubeIDs(3,1):kl_bbox_cubeIDs(3,2)
                kl_systemStr = sprintf('mkdir \"%s\"',fullfile(kl_targetDir,sprintf('x%04.0f',kl_x),sprintf('y%04.0f',kl_y),sprintf('z%04.0f',kl_z)))
                system(kl_systemStr);
                
                kl_systemStr = sprintf('copy \"%s\" \"%s\" ',...
                    fullfile(kl_sourceDir,sprintf('x%04.0f',kl_x),sprintf('y%04.0f',kl_y),sprintf('z%04.0f',kl_z),'*.*'),...
                    fullfile(kl_targetDir,sprintf('x%04.0f',kl_x),sprintf('y%04.0f',kl_y),sprintf('z%04.0f',kl_z)))
                system(kl_systemStr);
            end
        end
    end



    kl_systemStr = sprintf('copy \"%s\" \"%s\"',fullfile(kl_sourceDir,'Knossos.conf'),kl_targetDir);
    system(kl_systemStr);













end