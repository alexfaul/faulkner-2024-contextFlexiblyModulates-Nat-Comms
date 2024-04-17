%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Adpating the cross day outputs from ziv to 
%%%%%%%%%%%%%% take in the Ransona 
%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%
%% modified code to accept suite2p inputs is here..... ROIMatchPub-suite2p
roiMatchPub

%%% which is first step??
%%% or see which of the other crossday ones could work -- **update** the CIAtah
%%% is full registratoin pipeline
%%% just run the ransona as is for the days i want?? actually
%%% straightforward enough lmao
%%% can try the new one
%%% and then can adapt the xday outputs (IF ALVIN HAS THEM ALREADYYYYYYYY)
%%% for the ransona to intake 
%%% the Ziv lab xday outputs 
%%% otherwise do ransona for now?????

%%% in roiMatchData, commited=1 means its present in ALL sessions
%% make sure the format of .mapping aligns with format of Ziv ouput object
%% 

T07='Z:\AFdata\2p2019\Experiments\T07\xday\xday_obj_struct.mat'
T23='Z:\AFdata\2p2019\Experiments\T23\xday_FINAL_T23\xday_obj.mat'
T10='Z:\AFdata\2p2019\Experiments\T10\xday\xday_obj_struct.mat'
T27='Z:\AFdata\2p2019\Experiments\T27\xday_FINAL_T27\xday_obj.mat'
T26='Z:\AFdata\2p2019\Experiments\T26\xday_FINAL_T26\xday_obj.mat'

mouse=T10
[zivfolderPath, ~, ~] = fileparts(mouse);
obj=load(mouse)
% s = struct(obj)
% s.dffDirs=obj.obj.dffDirs %%% PATHS, match to the paths you already have to only pull those files
% mapIndex=find(~cellfun(@isempty,obj.obj.xdayalignmentall)) %%%% one 
% s.mapping=obj.obj.xdayalignmentall{mapIndex}.cell_to_index_map
s.dffDirs=obj.T10xday.dffDirs %%% PATHS, match to the paths you already have to only pull those files
s.mapping=obj.T10xday.xdayalignment.cell_to_index_map


save([zivfolderPath '\' 'xday_obj_struct.mat'],'s','-v7.3')
clearvars s

matfile()




T07='Z:\AFdata\2p2019\Experiments\T07\xday\xday_obj_struct.mat'
T23='Z:\AFdata\2p2019\Experiments\T23\xday_FINAL_T23\xday_obj_struct.mat'
T10='Z:\AFdata\2p2019\Experiments\T10\xday\xday_obj_struct.mat'
T27='Z:\AFdata\2p2019\Experiments\T27\xday_FINAL_T27\xday_obj_struct.mat'
T26='Z:\AFdata\2p2019\Experiments\T26\xday_FINAL_T26\xday_obj_struct.mat'



s.dffDirs=obj.dffDirs %%% PATHS, match to the paths you already have to only pull those files

mapIndex=find(~cellfun(@isempty,obj.xdayalignmentall)) %%%% one 
mapping=obj.xdayalignmentall{mapIndex}.cell_to_index_map


%%%%%%%%%%%%%%%%
%%%% T23
%%%%%%%%%%%%%% 
zivPath='Z:\AFdata\2p2019\Experiments\T23\xday_FINAL_T23\xday_obj.mat'
load(zivPath)  %% Ziv
load('Z:\AFdata\2p2019\Experiments\T23\Ransona_crossDayyyyT23.mat') %% Ransona
[zivfolderPath, ~, ~] = fileparts(zivPath);
GOALZ=fieldnames(roiMatchData) % get fieldnames to emulate

%%%%%%%%%%%%%% find the suite2p dff file that the rest of the images are
%%%%%%%%%%%%%% aligned to (the suite2p file of the "best day" in the Ziv as
%%%%%%%%%%%%%% this is what the reference image is
originalPath = obj.dffDirs{obj.best_day};
newPath = strrep(originalPath, '/nfs/turbo/umms-crburge/', 'Z:/');
load(newPath);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% recreate the Ransona output through combination of Ziv outputs
%%%%%%%%%% and info in Suite2p dff file
roiMatchDataEmulate.refImage=suite2pData.ops.meanImg;
%%%%%%%%%%%%%%%%
matrixSize = length(obj.dffDirs);                   %comparison matrix
identityMatrix = eye(matrixSize);
roiMatchDataEmulate.comparisonMatrix=identityMatrix;

originalPaths = obj.dffDirs;  %%% update paths to pull from Turbo
roiMatchDataEmulate.allRois = cellfun(@(path) strrep(path, '/nfs/turbo/umms-crburge/', 'Z:/'), originalPaths, 'UniformOutput', false)';
mapIndex=find(~cellfun(@isempty,obj.xdayalignmentall))
mapping=obj.xdayalignmentall{mapIndex}.cell_to_index_map

%%%%%%%%%%%%%%%%%%%%%%      %%%% take out all zero rows if any to match
%%%%%%%%%%%%%%%%%%%%%%      Ransona
nonZeroRows = any(mapping, 2);
% Extract the non-zero rows
resultMatrix = mapping(nonZeroRows, :);
roiMatchDataEmulate.mapping = unique(resultMatrix, 'rows');
%%%%%%%%%%%%%%%%%%%%%%      %%% get neurons present across all SESSIONS
roiMatchDataEmulate.allSessionMapping = roiMatchDataEmulate.mapping(all(roiMatchDataEmulate.mapping ~= 0, 2), :);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%      %%%         %     UPDATE GUI TO MAKE PARTIAL MATCHES     %     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


figure
imagesc(roiMatchDataEmulate.refImage)
figure
imshow(obj.obj.masks_warped(:,:,3))

ext ='.tif';                                 
tifdirs = findFILE(zivfolderPath,ext);                %% Will return cell array of all files under root containing extList
matchingPaths = tifdirs(contains(tifdirs, 'FOV_registered'));  %% Get final registered image 
%%%%%%%%%%%% READ IN ZIV REGISTERED TIFF STACK to get registered image for
%%%%%%%%%%%% each run
tifStackInfo = imfinfo(matchingPaths{:}); % Determine the dimensions of the stack
numFrames = numel(tifStackInfo);
imageWidth = tifStackInfo(1).Width;
imageHeight = tifStackInfo(1).Height;
tifStack = zeros(imageHeight, imageWidth, numFrames, 'uint16'); % Initialize an empty 3D matrix to store the TIFF stack


% Read each frame and store it in the 3D matrix
for frame = 1:numFrames
    tifStack(:,:,frame) = multibandread(tifStackFilename, [imageHeight, imageWidth], frame, 'uint16', 'ieee-le');
end

%%%%%%%%%%%
for ii=1:length(obj.warpfields)
tempSuite2p=load(roiMatchDataEmulate.allRois{ii})
roiMatchDataEmulate.rois{1,ii}.cellCount=size(tempSuite2p.suite2pData.F,1);
roiMatchDataEmulate.rois{1,ii}.meanFrame = tempSuite2p.suite2pData.ops.meanImg ;
   
roiMatchDataEmulate.rois{1,ii}.meanFrameRegistered=double(tifStack(:,:,ii))
roiMatchDataEmulate.rois{1,ii}.roiMapRegistered=obj.masks_warped(:,:,ii)


roiMatchDataEmulate.rois{1,ii}.committed=  %%% if present 

% %%%%%%%%%%%%%%%%%%%%%
% roiMatchDataEmulate.rois{1,ii}.trans.moving_out=[];
% roiMatchDataEmulate.rois{1,ii}.trans.fixed_out=[];
end 


%%%%%%%%%%%%%%%%%%%%
%%% the ziv and the ransona are formatted differently
%% does this matter??
%% test by taking out all the zeros from the ransona, reloading
%% if it works the same, then no need to change the mapping....??
%% roiMatchData.mapping  is where the repeated ones are with 
%% some all zero rows


