%% eye comparisons

root    ='Z:\AFdata\2p2019\W10';                    %% as character 
    ext = 'eye_area.mat';
    eyedir = findFILE(root,ext);
    
    crossDayBehavior(eyedir)
    
ext = 'motSVD.mat';
    motSVDdir = findFILE(root,ext);
idx=[2:10 12]
    eyeDir=eyedir(idx)
    motSVDDir=motSVDdir(idx)
    
    %% 
    
    root    ='Z:\AFdata\2p2019\W10';                    %% as character 
    ext = 'Suite2p_dff.mat';
    stimdir = findFILE(root,ext);
        [~,filenames]=cellfun(@fileparts,stimdir,'UniformOutput',false)
filenames=filenames(2:end);
stimDir=stimdir(2:end);
    
for ii=1:length(filenames)
      W10Data.(filenames{ii})=[]
end 
    
for ii=1:length(filenames)
       W10Data.(filenames{ii}) =load(stimDir{ii})
end 
    
    
for ii=1:length(motSVDDir)
       W10motSVD. (filenames{ii})=[]
       W10motSVD.(filenames{ii}) =load(motSVDDir{ii})
end
    
    

for ii=1:length(motSVDDir)
       W10eye. (filenames{ii})=[]
       W10eye.(filenames{ii}) =load(eyeDir{ii})
end



    %% 
orientationsUsed=suite2pData.Stim.orientationsUsed(unique(suite2pData.Stim.condition));
%% Create array with all stim
for ii=1:length(filenames)
orientationsUsed=W10Data.(filenames{ii}).suite2pData.Stim.orientationsUsed(unique(W10Data.(filenames{ii}).suite2pData.Stim.oriTrace));
end

for ii=1:length(filenames)
    orientationsUsed=W10Data.(filenames{ii}).suite2pData.Stim.orientationsUsed;
    tempData=W10Data.(filenames{ii}).suite2pData.Stim.oriTrace;
    idx.(filenames{ii})=suite2pData.Stim.orientations;
    fieldnames(=W10Data.(filenames{ii}).suite2pData.Stim.
for kk=1:length(orientationsUsed);
    
    idx.(filenames{ii}).(kk,:)=find(tempData==orientationsUsed(kk));
end    
end

trialTypeIDX=fieldnames(dffTrials)
halfWin=winLength/2;

for kk=1:length(trialTypeIDX) %loop through each trial type (Trials0, Trials90 etc)                                                                      
    oriTrialIDX=idx.(trialTypeIDX{kk});                                                      %temporary variable name for the Trial # index separated by Ori
    for ii=1:length(oriTrialIDX)                                                                %go through the index of trial number within each trial type (ii=3 corresponds to Trial 9 for example)
        dataTemp=suite2pData.dFF(:,startPt(oriTrialIDX(ii)):endPt(oriTrialIDX(ii))); %ROI by time across that trial matrix
        baselineTemp=suite2pData.dFF(:,(startPt(oriTrialIDX(ii)))-winLength:(startPt(oriTrialIDX(ii))-1)); %ROI by time across that trial matrix

        dataTempfirstHalf=suite2pData.dFF(:,startPt(oriTrialIDX(ii)):endPt(oriTrialIDX(ii))-halfWin); %ROI by time across that trial matrix

        dataTempsecondHalf=suite2pData.dFF(:,startPt(oriTrialIDX(ii)):startPt(oriTrialIDX(ii))+halfWin); %ROI by time across that trial matrix
        
        
        dffFirstHalf.(trialTypeIDX{kk})(:,ii)=mean(dataTempfirstHalf,2)
        dffSecondHalf.(trialTypeIDX{kk})(:,ii)=mean(dataTempsecondHalf,2)        
        dffTrials.(trialTypeIDX{kk})(:,ii)=mean(dataTemp,2);                                    %gives average values across entire trial, separated by trial type
        baselineTrials.(trialTypeIDX{kk})(:,ii)=mean(baselineTemp,2);                                    %gives average values across entire trial, separated by trial type

    end
end 