root    ='Z:\AFdata\2p2019\Experiments\T02';                    %% change mouse here 
ext = '.sbx';
sbxDirs = findFILE(root,ext);

sbxdirs=sbxDirs(4:2:end) %get only even # files, stat at 4, go by 2 to the end

for kk=1:length(sbxdirs)
i=kk %changing this I changes the file its referencing (T02_200202_002 vs T02_202002_004)

[path, temp]=fileparts(sbxdirs{1})

fname=[path '\' temp]
for ii=0:13999
image=sbxread(fname,ii,1);
meanImg(ii+1)=mean(image(:));
clear image
end
savePath=[path,'\',temp,'meanImg']
save(savePath, 'meanImg');
clearvars meanImg

end