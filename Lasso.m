




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% % X = randn(100,20);
% % weights = [.4;.2;.3];
% % mu = exp(X(:,[5 10 15])*weights + 1);
% % y = poissrnd(mu);
% % Construct a cross-validated lasso regularization of a Poisson regression model of the data.

test=diff(visstim_on);                       %create onset vector so that when an offset happens, moves forward one in
test=[0,test];                                              %append 0 to front since cant have known offset at 0
k=0;            
                                                    %don't need to loop through k but do need to initialize as 1 if first visstim on is 2nd trial
for i=(1:length(visstim_on))                 % initialize as 0 if first onset is Trial1
    if test(i)==3 %changed from -3, finding onsets
            k=k+1;                                          %If there is an onset, move the index to get trial and condition forward
    end 
   if i<trialonsets(1)
            cond_full(i)=0;                                  
            trial_full(i)=0;
   elseif i>trialonsets(1)
        if visstim_on(i)==4
             cond_full(i)=condition(k);  %
             trial_full(i)=trial(k);
        elseif visstim_on(i)~=4
            cond_full(i)=0; 
            trial_full(i)=0;
        end 
   end  
end  

find(quinine~=0)
figure;plot(shock)
test2=[0,diff(cond_full)]
for ii=1:length(shock)
if test2(ii)==-90 | test2(ii+1)==-90
    shock2(ii)=1;
else
    shock2(ii)=0;
end 
end 
sum(shock2)
    
%% 
trials0=cond_full;
trials45=cond_full;
trials90=cond_full;
trials135=cond_full;

trials0(trials90~=1)=0;
trials45(trials0~=2)=0;
trials90(trials90~=3)=0;
trials135(trials135~=4)=0;
runningVelocity=typecast(runningVelocity,'single');

X=[runningVelocity;trials0;trials45;trials90;trials135];
runningVelocity(runningVelocity==ans(2))=1;
runningVelocity(runningVelocity==ans(3))=2;
runningVelocity(runningVelocity==ans(4))=3;
runningVelocity(runningVelocity==ans(5))=4;
unique(runningVelocity)

X=X';
y=dFF(303,:);
y(y<0) = 0;
[B,FitInfo] = lasso(X,y,'CV',10);
Examine the cross-validation plot to see the effect of the Lambda regularization parameter.

lassoPlot(B,FitInfo,'plottype','CV'); 
legend('show') % Show legend

idxLambdaMinDeviance = FitInfo.IndexMinDeviance;
mincoefs = find(B(:,idxLambdaMinDeviance))
unique(runningVelocity)

bestValue = find(FitInfo.Lambda == FitInfo.LambdaMinMSE)

idxLambda1SE = FitInfo.Index1SE;
min1coefs = find(B(:,idxLambda1SE))
%%%find nonzero
lam = fitinfo.Index1SE;
fitinfo.MSE(lam)





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mouse='T10'
root    ='Z:\AFdata\2p2019\Experiments\T10';                    %% as character 
ext = 'Fall.mat';
ext = 'Suite2p_dff.mat';
suite2pdir = findFILE(root,ext);
suite2pDir = suite2pdir(end);
%% left off 622 T07
%%left off 0412 T23
for mm=1:length(suite2pDir)
    tic
    clearvars -except suite2pDir mouse root ext mm suite2pdir
load(suite2pDir{mm})
dFF=suite2pData.dFF;
[basePath,fileName]=fileparts(suite2pDir{mm})
ext = 'eye_proc.mat';
eyeDir = findFILE(basePath,ext);
ext = 'dsNidaq.mat';
nidaqDir = findFILE(basePath,ext);

%%%
%%%  make matrix of x predictors for Lasso 
%%%  pupil, motSVD (facemap) 
%%%  runningVel, licking, shock (nidaq)  %%%%%%%%% 
%%%  visstim (dummy coded, plus how to adjust for offset issue when shock
%%%  present....???????????????????????????)
%%% 

numVisstim=length(suite2pData.nidaqAligned.Stim.orientationsUsed)
totalPredic=numVisstim+6;
X=zeros(totalPredic,length(suite2pData.F));
% ii=1
     pupil=[]
%     motSVD=[]
    if length(eyeDir)==length(nidaqDir)
    for ii=1:length(eyeDir)
    facemapTemp=load(eyeDir{ii});
    pupilTemp=facemapTemp.pupil{1,1}.area(1:suite2pData.nidaqAligned.endIdx(1));
    pupil=[pupil,pupilTemp];

%     motTemp=facemapTemp.motSVD_0(1:suite2pData.endIdx(ii),1);
%     motSVD=[motSVD;motTemp]
    clear pupilTemp %motTemp
    end
    pupil_z = (pupil - nanmean(pupil))/nanstd(pupil);
    suite2pData.nidaqAligned.pupil_z=pupil_z;
    suite2pData.nidaqAligned.pupil=pupil
    else
    facemapTemp = zeros(1,length(suite2pData.F))
    pupil_z=[facemapTemp];
    suite2pData.nidaqAligned.pupil_z=[]
    clear facemapTemp
    end
    %%%%%%%%%%%%%%
try
for ii=1:length(suite2pData.Stim.fullConditions)
    for kk=1:length(suite2pData.Stim.orientations{1,ii})
    trialType{kk,ii}=suite2pData.Stim.fullConditions{1,ii}{kk,4};
    all_oris{kk,ii}=suite2pData.Stim.orientationsOrderedbyCond{1,ii}{kk,:};
    end
end
catch
    suite2pData.Stim.fullConditions={suite2pData.Stim.fullConditions} %%%%% TRY CATCH NEW STATEMENT FOR SEPARATED RUNS
    suite2pData.Stim.orientations={suite2pData.Stim.orientations}
    suite2pData.Stim.orientationsOrderedbyCond={suite2pData.Stim.orientationsOrderedbyCond}
    for ii=1:length(suite2pData.Stim.fullConditions)
    for kk=1:length(suite2pData.Stim.orientations{1,ii})
    trialType{kk,ii}=suite2pData.Stim.fullConditions{1,ii}{kk,4};
    all_oris{kk,ii}=suite2pData.Stim.orientationsOrderedbyCond{1,ii}{kk,:};
    end
    end
end 

if size(all_oris, 2) == 2 && isequal(all_oris(:,1), all_oris(:,2))
    oriLabels=all_oris(:,1)
elseif  size(all_oris, 2) ~= 2 || ~isequal(all_oris(:,1), all_oris(:,2))
    oriLabels= all_oris
end 


% Check if fileName contains '_001002_'
if contains(fileName, '_001002_')
    % Do nothing, leave pupil_z alone
elseif contains(fileName, '_001_')
    % Assign values to pupil_z for '_001_' case
    pupil=pupil(1:25000);
    pupil_z = pupil_z(1:25000);
elseif contains(fileName, '_002_')
    % Assign values to pupil_z for '_002_' case
    pupil=pupil(25001:50000);
    pupil_z = pupil_z(25001:50000);
    suite2pData.Stim.trialoffsets=suite2pData.Stim.trialoffsets-25000
    suite2pData.Stim.trialonsets = suite2pData.Stim.trialonsets-25000
end
suite2pData.nidaqAligned.pupil=pupil;

suite2pData.nidaqAligned.pupil_z=pupil_z;


if size(trialType, 2) == 2 && isequal(trialType(:,1), trialType(:,2))
    trialTypelabels=trialType(:,1)
elseif  size(trialType, 2) ~= 2 || ~isequal(trialType(:,1), trialType(:,2))
    trialTypelabels= trialType
end 
 

% vars = who(); 
% TF = contains(vars, num2str(oriLabels{ii}))
% neutral=oriLabels{ii}
%%%%%%
%%%%%%%%%%% NEED TO ADD CATCH FOR IF THE TWO TRIALS ARE DISPARATE!!!
if size(trialTypelabels, 2) == 1
for ii=1:length(trialTypelabels)
if trialTypelabels{ii}(3)=='n'
    trialAdjustment(ii)=6;
elseif trialTypelabels{ii}(3)=='p'
    trialAdjustment(ii)=0;
elseif trialTypelabels{ii}(3)=='m'
 trialAdjustment(ii)=7;
end 
end
else
   sprintf('different trialTypes in different runs, to use these days need to add good way to index through that downstream of this function')
end 
%%%%%%%%%%%%%%%%%%%%
    if isfield(suite2pData.nidaqAligned, 'runVel')==0
    suite2pData.nidaqAligned.runVel=zeros(1,length(suite2pData.F));
    end
    
    running = zscore(suite2pData.nidaqAligned.runVel);
    shock   = suite2pData.nidaqAligned.shock;
    licking = suite2pData.nidaqAligned.licking;
    visstim0 = zeros(1,length(suite2pData.F));
    visstim90= zeros(1,length(suite2pData.F));
    visstim225=zeros(1,length(suite2pData.F));
    offsets   =zeros(1,length(suite2pData.F));
for ii=1:length(suite2pData.Stim.trialonsets)
    %offsets=(1,suite2pData.nidaqAligned.Stim.trialoffsets(ii):suite2pData.nidaqAligned.Stim.trialoffsets(ii)+30)=1;

    if suite2pData.nidaqAligned.Stim.oriTrace(ii)==0
    index = find([oriLabels{:}] == 0);
    visstim0(1,suite2pData.Stim.trialonsets(ii):suite2pData.Stim.trialoffsets(ii)-trialAdjustment(index))=1;
    offsets(1,suite2pData.Stim.trialoffsets(ii)-trialAdjustment(index):suite2pData.Stim.trialoffsets(ii)-trialAdjustment(index)+30)=1;
    elseif suite2pData.Stim.oriTrace(ii)==90
    index = find([oriLabels{:}] == 90);
    visstim90(1,suite2pData.Stim.trialonsets(ii):suite2pData.Stim.trialoffsets(ii)-trialAdjustment(index))=1;
    offsets(1,suite2pData.Stim.trialoffsets(ii)-trialAdjustment(index):suite2pData.Stim.trialoffsets(ii)-trialAdjustment(index)+30)=1;
    elseif suite2pData.Stim.oriTrace(ii)==225
    index = find([oriLabels{:}] == 225);
    visstim225(1,suite2pData.Stim.trialonsets(ii):suite2pData.Stim.trialoffsets(ii)-trialAdjustment(index))=1;
    offsets(1,suite2pData.Stim.trialoffsets(ii)-trialAdjustment(index):suite2pData.Stim.trialoffsets(ii)-trialAdjustment(index)+30)=1;
    end
end

suite2pData.nidaqAligned.Stim.offsetAdjustmentNeeded=trialAdjustment;
ensureProc=process_ensure(suite2pData.nidaqAligned.ensure)
suite2pData.nidaqAligned.ensureProc=ensureProc;


X=[pupil_z;running;shock;licking;offsets;visstim0;visstim90;visstim225;ensureProc]

for kk=1:size(dFF,1)
y=dFF(kk,:);
y(y<0) = 0;
[B,FitInfo] = lasso(X',y,'CV',5);
%  lassoPlot(B,FitInfo,'plottype','CV'); 
% legend('show') % Show legend

idxLambdaMinDeviance = FitInfo.Index1SE;
mincoefs = (B(:,idxLambdaMinDeviance))

%%%find nonzero
idx = FitInfo.Index1SE;
FitInfo.Lambda(idx);
lassoBetas(kk,:)=mincoefs;
end
toc
Betas.labels=["pupil","running","shock","licking","offsets","visstim0","visstim90","visstim225","reward"]
Betas.betaValues=lassoBetas;
fileName=extractBefore(fileName,'_Suite2p_dff')
Filename=[basePath '\' 'LASSObetas2_' fileName '.mat'];
save(Filename, 'Betas','-v7.3','-nocompression');
Filename=[basePath '\' fileName '_Suite2p_dff.mat'];
save(Filename, 'suite2pData','-v7.3','-nocompression')
% % 
% % figure
% % plot(visstim0)
% % hold on
% % plot(visstim225)
% % hold on
% % plot(visstim90)
% % hold on
% % plot(suite2pData.nidaqAligned.visstim)
%%%
%%%
%%%
%     else
%     sprintf('not enough eyeFiles babe, go check')
%     continue
     
end

figure
imshow(suite2pData.ops.refImg)
hold on
imshow(suite2pData.stat{1,3}.xpix)
