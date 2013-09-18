function kn_writtenFile = KNOSSOS_cubeGenerator_generateXLSfile
    [XLSFileName,XLSPathName,FilterIndex] = uiputfile('.xls','please select xls file to write info to') 
    if XLSFileName~=0
        [FileName,PathName,FilterIndex] = uigetfile('.tif','Please select input files','MultiSelect','on')
        if iscell(FileName)
            kn_xlsCell = {};
            kn_txtoffset=1;
            kn_xlsCell = {'filename','bbox xmin','bbox xmax','bbox ymin','bbox ymax','bbox zmin','bbox zmax'};
            for i=1:size(FileName,2)
                kn_xlsCell{i+kn_txtoffset,1} = fullfile(PathName,FileName{i});
                kn_thisinfo = imfinfo(fullfile(PathName,FileName{i}));
                kn_xlsCell{i+kn_txtoffset,2} = 1;
                kn_xlsCell{i+kn_txtoffset,3} = kn_thisinfo.Width;
                kn_xlsCell{i+kn_txtoffset,4} = 1;
                kn_xlsCell{i+kn_txtoffset,5} = kn_thisinfo.Height;
                kn_xlsCell{i+kn_txtoffset,6} = i;
                kn_xlsCell{i+kn_txtoffset,7} = i;
            end
            xlswrite(fullfile(XLSPathName,XLSFileName),kn_xlsCell);
        end
    end
    kn_writtenFile = fullfile(XLSPathName,XLSFileName);
end