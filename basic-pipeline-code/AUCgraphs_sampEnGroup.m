%%%%%%%%%%%%%% write AUC graphs  + sample entropy
%%%%%%%% for alllllll
%%%%%% DISTRIBUTION!

  root    ='Z:\AFdata\2p2019\Experiments\T01';                    %% as character 
 ext = 'Suite2p_dff.mat';

    dffdirs = findFILE(root,ext);
    dffDirs=dffdirs(:) 

for ii=1:length(dffDirs)
%% deconvolved peaks
%%% SNR
ii=1
load(dffDirs{ii})
suite2pData.AUC

    
end
