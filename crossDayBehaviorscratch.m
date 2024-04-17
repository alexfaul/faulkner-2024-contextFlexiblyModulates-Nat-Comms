%% eye comparisons

root    ='Z:\AFdata\2p2019\W10';                    %% as character 
ext = 'eye_area.mat';
stimdir = findFILE(root,ext);
 stimidx=[2:10,12]
 stimDir=stimdir(stimidx)
[~,filenames]=cellfun(@fileparts,stimDir,'UniformOutput',false)

for ii=1:length(stimDir)
      W10Data.(filenames{ii})=[]
    end 
    
    for ii=1:length(stimDir)
       W10Data.(filenames{ii}) =load(stimDir{ii})
        
    end 
        
    %% 
    
%    

    
    
    
     root    ='Z:\AFdata\2p2019\W10';                    %% as character 
     ext = 'Suite2p_dff.mat';
     dffdir = findFILE(root,ext);
 dffDirs=dffdir(2:end)
         [~,filenames]=cellfun(@fileparts,dffDirs,'UniformOutput',false)



for ii=1:length(dffDirs)
      W10stim.(filenames{ii})=[]
    end 
    
    for ii=1:length(dffDirs)
       W10stim.(filenames{ii}) =load(dffDirs{ii})
        
    end 
    
    %% 
    stimIdx=fieldnames(W10stim)
    eyeIdx=fieldnames(W10Data)
    
    
    startPt=suite2pData.Stim.trialonsets;
    endPt=suite2pData.Stim.trialoffsets;  
    diffTrialTimes=max(endPt-startPt);
    winLength=round(diffTrialTimes);
    %% 
    
    for ii=1:length(dffDirs)
      eyeArea.(eyeIdx{ii})=[]
    end 
   
        
    for kk=1:length(eyeIdx)
    for ii=1:length(W10stim.(stimIdx{kk}).suite2pData.Stim.trialonsets)
   eyeArea.(eyeIdx{kk})(ii)= ...
mean(W10Data.(eyeIdx{kk}).parea(W10stim.(stimIdx{kk}).suite2pData.Stim.trialonsets(ii):W10stim.(stimIdx{kk}).suite2pData.Stim.trialoffsets(ii)))
    
    end
    end
    
    
    
    for ii=1:length(stimIdx{kk})
       tempOri=unique(W10stim.(stimIdx{kk}).suite2pData.Stim.trialonsets)
       for ii=1:length(tempOri)
       oriIdx
       end    
           
    end
    
    
    
    
for ii=1:length
     Stimtimes.(filenames{ii}).trialonsets =cStim.trialonsets
     Stimtimes.(filenames{ii}).trialoffsets=W10Data.(filenames{ii}).suite2pData.Stim.trialoffsets
end 