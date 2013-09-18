% create a dummy test case for blocked wise component  labelleing
root = 'D:\mouse_brain\tests'
labels = zeros(300,200, 100,'uint16');
greylevel = zeros(300,200, 100,'uint8');
stream = RandStream.getDefaultStream
reset(stream)
rand(1);

% create random components 
%cube1 = [20:30, 20:30, 1:10];
%cube2 = [20:30, 20:30, 12:20];
%cube3 = [210:220, 120:130, 35:44];
%cube4 = [210:220, 120:130, 95:99];


labels(20:30, 20:30, 1:10) = 1; 
labels(20:30, 20:30, 12:20) = 2; 
labels(210:220, 120:130, 35:44) = 3; 
labels(10:220, 50:130, 95:99) = 4;



greylevel(20:30, 20:30, 1:10) = 100; 
greylevel(20:30, 20:30, 12:20) = 120; 
greylevel(210:220, 120:130, 35:44) = 140; 
greylevel(10:220, 50:130, 95:99) = 180; 

CC = bwconncomp(labels);
regioninfo = regionprops(CC, 'Centroid','Area', 'MajorAxisLength','MinorAxisLength','Eccentricity');


[sy, sx, sz] = size(labels);
flippable_size = [sz, sy, sx] ; 

h5create([root,'\labels.h5'],'/labels',flippable_size,'Datatype','uint16', ...
                 'FillValue',uint16(0),'ChunkSize',[32 32 32],'Deflate',1);

h5create([root,'\gray.h5'],'/gray',flippable_size,'Datatype','uint8', ...
                'FillValue',uint8(0),'ChunkSize',[32 32 32],'Deflate',1);
          
writeMatlabCubeToHDF5inXYZOrder([root,'\labels.h5'], '/labels', labels,[1,1,1],[sx, sy, sz] );
writeMatlabCubeToHDF5inXYZOrder([root,'\gray.h5'], '/gray', greylevel, [1,1,1],[sx, sy, sz] );