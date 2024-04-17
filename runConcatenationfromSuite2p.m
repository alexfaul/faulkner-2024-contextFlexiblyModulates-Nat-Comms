function [startIdx, endIdx,ops] =runConcatenationfromSuite2p(dsnidaq,Suite2pData)

nFrames=length(dsnidaq.frames2p);

%% Add check for multiple runs together, add correction - port to own function?
if length(suite2pData.F)~=nFrames  
    if isempty(runNums)
    runConcat; runsConcatenate=sort(runsConcatenate);           % dialog box to enter runs to cat together if not specified when called
    runNums=runsConcatenate;
    else
    runNums=arrayfun(@(x) sprintf('%03d', mod(x,100)), runNums, 'UniformOutput', false);  
    end
% end  
 % Find full path of all dsNidaq files in the directory the cell clicked imaging data comes from  
                                                
  ext2='_dsNidaq.mat';
  rundirs=findFilePathAF(newdir,ext2);   
  runDirs=rundirs(find(contains(rundirs,runNums)));   % isolate nidaq files matching the runs manually specified
    
  if length(runNums)~=length(runDirs)
        sprintf('Cannot find nidaq files for all runs associated with Fall.mat file')
        return
  end
  
for ii=1:length(runDirs)
    [~,fname,~]=fileparts(runDirs{ii});                             % runDirs has 
    dsNidaq.(fname)=load(runDirs{ii});                              % load each nidaqfile that matches user-input runs in a loop
    nFrames(ii)=length(dsNidaq.(fname).EEG);                        % get number of frames for each respective run so we can do neuropil on run-by run basis
                                                                    % can be anything, just arbitrarily chose EEG
end

fields = fieldnames(dsnidaq);            %# Get the field names from the 1st loaded nidaq file
runIdx = fieldnames(dsNidaq);            %# Get the run names of all runs relevant to the suite2p data registered together

for ii=1:length(fields);
concatenateddata.(fields{ii})=[];        % create empty structure to append all nidaq data to for desired runs
end

for ii=1:length(runIdx)
   for kk = 1:length(fields);
   fname = fields{kk};
   if isequal(dsNidaq.(runIdx{ii}).(fname),concatenateddata.(fname))~=1 | strcmp(fname,'frames2p')==1 ; %if the info is the same, then skip. If it contains different info, then proceed with concatenation
   concatenateddata.(fname) = ...
       horzcat(concatenateddata.(fname),dsNidaq.(runIdx{ii}).(fname));
   end 
   end
end 
for ii=2:length(runDirs) % adjusting timestamps
concatenateddata.timeStamps2p(:,ii)=concatenateddata.timeStamps2p(:,ii)+...
    (concatenateddata.timeStamps2p(end,ii-1));
end 
concatenateddata.timeStamps2p=...
    reshape(concatenateddata.timeStamps2p,[1,sum(nFrames)]);
dsnidaq=concatenateddata; % replace
clearvars concatenateddata dsNidaq runsConcatenate
end 
    endIdx    = cumsum(nFrames);
    startIdx= ([0,endIdx]+1);
    startIdx=startIdx(1:length(endIdx))
    ops=suite2pData.ops
end 