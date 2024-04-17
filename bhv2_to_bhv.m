function [ bhv_struct ] = bhv2_to_bhv(datafile,configfile)
%% I/O

% datafile is path to .bhv2 file
% config file is name of config (.txt) Monkeylogic file. Optional bc it will parse the info within .bhv2, 
% but if there are duplicate files w/ same names + diff info, could 

%% 
[filepath,~,~]=fileparts(char(datafile))

BHV=bhv_read('Z:\AFdata\ML_output_BHV\Experiment-AS20-07-12-2016-run2.bhv');
datafile=char(datafile);
[data, MLConfig, TrialRecord, ~] = mlconcatenate(datafile);                  %not returning fieldname, duplicate of datafile
bhv2_struct=mlread(datafile); 

%%%putting all matching fieldnames from ML concetenate into new BHV
%%%structure
output_bhv=fieldnames(BHV);
hold=num2cell(NaN(1,length(output_bhv)))';
bhv_struct = cell2struct(hold,output_bhv,1);

% clearvars -except bhv2_struct bhv_struct datafile condpath
 [data, MLConfig, TrialRecord]= mlread(datafile); %must be character string of path until .bhv2

 
[~, cname, ~] = fileparts(MLConfig.MLPath.ConditionsFile);
if nargin<2,
configfile=fullfile(which([cname,'.txt']));
end
 
if nargin==2 & strcmp(cname,configfile)==0
        sprintf('config file entered does not match conditions file listed in original BHV: %s ', cname) %6f
end 
%% 
 
if ~ispref('MonkeyLogic', 'Directories'),
    success = set_ml_preferences;
    if ~success,
        return
    end
end
MLDATA.Directories = getpref('MonkeyLogic', 'Directories');
expdir = MLDATA.Directories.ExperimentDirectory;

if isempty(datafile),
    [datafile, pathname] = uigetfile([expdir '*.bhv2'], 'Choose BHV2 file');
    if datafile == 0,
        return
    end
    datafile = [pathname datafile];
end

[pname, fname, ext] = fileparts(datafile);
if isempty(pname),
    pname = expdir;
else
    pname = [pname filesep];
end
if isempty(ext),
    ext = '.bhv2';
end
datafile = [pname fname ext];
bhv_struct.DataFileName = fname;
bhv_struct.FullDataFile = datafile;
bhv_struct.TimingFileByCond=TrialRecord.TaskInfo.TimingFileByCond;
%% Finding 

% % % getting fieldnames of all structures to grab same fieldnames
output_bhv2=fieldnames(MLConfig);                                           %This won't work on anything nested below first level
output_bhv2_2=fieldnames(data);                                             %so manually will manually find those stragglers
output_bhv2_3=fieldnames(TrialRecord);
fields=intersect(output_bhv,output_bhv2);
fields2=intersect(output_bhv,output_bhv2_2);
fields3=intersect(output_bhv,output_bhv2_3);

for i=1:length(fields)                                                           %Looping through all produced structures to grab overlapping fieldnames from workspace
bhv_struct.(fields{i})=MLConfig.(fields{i});                                          %and put into bhv_struct
end                                                                         %This could also be accomplished with strcmp
for j=1:length(fields2)  
bhv_struct.(fields2{j})=data.(fields2{j});
end 
for k=1:length(fields3)
 bhv_struct.(fields3{k})=TrialRecord.(fields3{k});
end 
clearvars -except BHV bhv_struct bhv2_struct configfile datafile MLConfig MLDATA pname temp TrialRecord data expdir ext

%%
bhv_struct.configPath=configfile;

bhv_struct.TrialNumber = [bhv2_struct.Trial];
bhv_struct.BlockNumber = [bhv2_struct.Block];
bhv_struct.TrialWithinBlock = [bhv2_struct.TrialWithinBlock];
bhv_struct.ConditionNumber = [bhv2_struct.Condition];
bhv_struct.AbsoluteTrialStartTime = [data.TrialDateTime];
bhv_struct.TimeElapsed = [data.AbsoluteTrialStartTime];

bhv_struct.AbsoluteTrialStartTime=reshape(bhv_struct.AbsoluteTrialStartTime, 6,[])';
bhv_struct.TrialError = [bhv2_struct.TrialError]';
bhv_struct.CodeTimes = cellfun(@(x) x.CodeTimes, ...
    {bhv2_struct.BehavioralCodes}, 'UniformOutput', false);
bhv_struct.CodeNumbers = cellfun(@(x) x.CodeNumbers, ...
    {bhv2_struct.BehavioralCodes}, 'UniformOutput', false);
temp = [bhv2_struct.AnalogData];
[temp.EyeSignal] = temp.Eye;
bhv_struct.AnalogData = rmfield(temp, 'Eye');
bhv_struct.ReactionTime = [bhv2_struct.ReactionTime];
bhv_struct.ObjectStatusRecord = [bhv2_struct.ObjectStatusRecord];
temp = [bhv2_struct.RewardRecord];
[temp.RewardOnTime] = temp.StartTimes;
[temp.RewardOffTime] = temp.EndTimes;
temp = rmfield(temp, 'StartTimes');
bhv_struct.RewardRecord = rmfield(temp, 'EndTimes');
bhv_struct.UserVars = [bhv2_struct.UserVars];
bhv_struct.ConditionsFile = [MLConfig.MLPath.ConditionsFile];

% % 
% % if nargin<2
% %     txtFiles=dir([newdir,'\','**\*.txt']);
% %     cFiles=strfind({txtFiles.name},cname);
% %     cFiles=find(ismember({txtFiles.name},[cname,'.txt']))
% %     config_file=fullfile(txtFiles(cFiles).name);
% %     
% % 
% % end 
bhv_struct.FinishTime=datetime([bhv_struct.AbsoluteTrialStartTime(end,:)],'InputFormat','dd-MMM-yyyy HH:mm:ss');
bhv_struct.StartTime=datetime([bhv_struct.AbsoluteTrialStartTime(1,:)],'InputFormat','dd-MMM-yyyy HH:mm:ss');
bhv_struct.StartTime=datestr(bhv_struct.StartTime);
bhv_struct.FinishTime=datestr(bhv_struct.FinishTime);
bhv_struct.ScreenBackgroundColor=MLConfig.SubjectScreenBackground;
bhv_struct.BlockNumber=bhv_struct.BlockNumber';
bhv_struct.TrialNumber=bhv_struct.TrialNumber';
bhv_struct.ConditionNumber=bhv_struct.ConditionNumber';
bhv_struct.Stimuli=TrialRecord.TaskInfo.Stimuli; %not the same structure
bhv_struct.ScreenXresolution=str2num(extractBefore(MLConfig.Resolution,'x'));
bhv_struct.VideoRefreshRate=extractAfter(MLConfig.Resolution,12);
bhv_struct.ScreenYresolution=str2double(extractBetween(MLConfig.Resolution,7,12));
bhv_struct.AnalogInputFrequency=MLConfig.AISampleRate;
bhv_struct.JoyTransform=MLConfig.JoystickTransform;

fidbhv = fopen(datafile, 'r');
if fidbhv == -1,
    error(sprintf('*** Unable to open data file: %s', datafile));
end
bhv_struct.MagicNumber = fread(fidbhv, 1, 'uint32');
if bhv_struct.MagicNumber ~= 13,
    error('*** %s is not recognized as a "BHV2" file ***', datafile);
end

% out=strsplit(bhv_struct.ConditionsFile,'\');
% out2=out(1:end-1);
% base=fullfile(out2(1),out2(2),out2(3),out2(4),out2(5),out2(6)); % presumably be working out of this file directory
[filepath,name,ext] = fileparts(bhv_struct.ConditionsFile);                           %%getting filenames of ALL timing condition files (not just ones used)
TimingFileByCond=bhv_struct.TimingFileByCond;
for k = 1:length(TimingFileByCond)                                              % should find a better way to automate this
  endfile=(TimingFileByCond(k));
  fullFileName(k) = fullfile(filepath, endfile);
end
bhv_struct.TimingFiles=unique(fullFileName);            %Take out unique if want duplicates. Doesn't look like duplicates are a thing in original. 
%% 
% stim=bhv_struct.Stimuli
% extension = regexp(stim,'\\([^\\]*)$','tokens','once')
% 
% for ii=1:length(extension)
% stimNames(ii)=extractBefore(extension{ii},'.avi')
% end 
% 
% 
% [~,name,ext] = fileparts(bhv_struct.ConditionsFile);                           %%getting filenames of ALL timing condition files (not just ones used)
% [filepath,~,~] = fileparts(bhv_struct.FullDataFile);                           %%getting filenames of ALL timing condition files (not just ones used)
% con_file=fullfile(filepath,[name ext]); % presumably be working out of this file directory
%configfile='Z:\AFdata\2p2019\Eight_orientations_AF.txt'
%conditions_path=importdata(configfile);
%% 
   
try conditions_path=importdata(configfile); %% MAKE SURE NO SPACES AFTER LAST TASK OBJECT OR THIS WILL ERROR
    catch     sprintf('CANNOT FIND CONFIGURATION FILE') %6f
        return
end
expression = '\t';
splitStr = regexp(conditions_path,expression,'split');
for i=1:length(splitStr);
     temp_cell=splitStr{i,1};
     idx1=find(~cellfun(@isempty,temp_cell));
     output(i,(1:length(idx1)))=(temp_cell(idx1));
     clear idx1
end 
output = regexprep(output, ' ', '_');
output = regexprep(output, '#', '_');
output2=cell2table(output(2:end,:), 'VariableNames',output(1,:));
bhv_struct.FullConditions=output2;
output3=table2array(output2(:,5:end));
output3=(output2(:,5:end));
bhv_struct.TaskObject=output3;

%% 
FileName=[pname,'\',bhv_struct.DataFileName,'_','bhv'];
save(FileName, '-struct', 'bhv_struct');
success=1;

%% work in progress

%%%%%%%%%%%%%%%%%%% figuring out how to generate path names for timing
%%%%%%%%%%%%%%%%%%% conditions 



% % %%indexing not working
% % bhv_struct.VariableChanges.reward_dur.Value=unique(data.VariableChanges.reward_dur, 'rows');
% % bhv_struct.VariableChanges.reward_dur.Trial=1;
% % 
% % % % Figure out how to resolve this, using unique on data might be better
% % % way to go
% % temp=struct2cell(data.BehavioralCodes);
% % temp_codenum=cell2mat(temp(2,:));
% % bhv_struct.CodeNumbersUsed=unique(temp_codenum);
% % % bhv_struct.CodeNamesUsed=TrialRecord.TaskInfo.BehavioralCodes.CodeNames;
% % %%this is not working 
% % idx=ismember(bhv_struct.CodeNumbersUsed,TrialRecord.TaskInfo.BehavioralCodes.CodeNumbers)
% % for i=1:length(bhv_struct.CodeNumbersUsed)
% %     if idx(i)==1
% %        [bhv_struct.CodeNamesUsed(i)]=(TrialRecord.TaskInfo.BehavioralCodes.CodeNames{i})
% %     else 
% %        bhv_struct.CodeNamesUsed(i)=NaN
% %     end 
% % end 
% % 
% % 
% % fid = fopen('fgetl.m');
% % tline = fgetl(fid);
% % while ischar(tline)
% %     disp(tline)
% %     tline = fgetl(fid);
% % end
% % ugh = textscan(fileID,'%s','Delimiter','tab');
% % 
% % fclose(fid);
% % fileID = fopen('Z:\MonkeyLogic\MonkeyLogic Scripts\FF_training_all_options\Burgess_FF_0Deg_Reward_3Ori\Burgess_FF_0Deg_Reward_3Ori.txt');
% % 
% % fclose(fileID);
% % 
% % ugh = textscan(fileID,'%c %c %c %c %c %c %c','Delimiter','tab');
% % 
% % %%this works to get a string with all this. 
% % ugh=fileread('Z:\MonkeyLogic\MonkeyLogic Scripts\FF_training_all_options\Burgess_FF_0Deg_Reward_3Ori\Burgess_FF_0Deg_Reward_3Ori.txt')
% % ugh2=strsplit(ugh);
% % 
% % 
% % 
% % %trying to get same stimuli format
% % for i=1:length(TrialRecord.TaskInfo.Stimuli) 
% %     temp=(TrialRecord.TaskInfo.Stimuli{i})
% %     [~,name(i),ext(i)] = fileparts(temp)
% % end 
% % 
% % clearvars -except BHV bhv_struct bhv2_struct datafile MLConfig MLDATA pname temp TrialRecord data expdir ext
% % %% Getting infobycond, TaskObject
% % 
% % objs = {bhv2_struct.TaskObject};
% % conds = unique([bhv2_struct.Condition]);
% % columns = max(cellfun(@length, objs));
% % bhv_struct.TaskObject = cell(length(conds), columns);
% % for c = 1:length(conds)
% %     cond = conds(c);
% %     egs = objs([bhv2_struct.Condition] == cond);
% %     eg = egs{1};
% %     idx=fieldnames(eg);    
% %     L = length(idx);
% %     for j = 1:L
% %         if length(idx) <= 3
% %             cstr = sprintf('%s(%d, %d)', eg{L}{:});
% %         else
% %             cstr =  eg.(idx{j})%sprintf('%s(%s, %d, %d)',);
% %         end
% %         bhv_struct.TaskObject{c, j} = cstr;
% %     end
% % end
% % 
% % cond_whitespace = '\t';
% % cond_header = 1;
% % txtspec = '%s%s%s%s%s%s%s%s%s%s';
% % condfile = textscan(fopen(condpath), txtspec, 'Whitespace', cond_whitespace);
% % infoByCond = cell(length(conds), 1);
% % 
% % %% infobycond taskobject scratch
% % 
% % % 
% % cond = conds(1);
% %     egs = objs([bhv2_struct.Condition] == cond);
% %     eg = egs{1};
% %     idx=fieldnames(eg);    
% %     L = length(idx);
% % 
% % for c = 1:length(conds)           % C/O-AF 4/19
% %     cond = conds(1);
% %     egs = objs([bhv2_struct.Condition] == cond);
% %     eg = egs{1};
% %     idx=fieldnames(eg);    
% %     L = length(idx);
% %     for j = 1:L
% %         if length(L) <= 3 
% %            cstr = sprintf('%s(%d, %d)', eg(idx(L{1})));
% %         else
% %            cstr{L} = sprintf('%s(%d, %d)\n', eg.(idx{L})(:));
% %             %{l}{:});
% %         end
% %         bhv_struct.TaskObject{c, j} = cstr;
% %     end
% % end
% % 
% % % for c = 1:length(conds)           % C/O-AF 4/19
% % %     cond = conds(1);
% % %     egs = objs([bhv2_struct.Condition] == cond);
% % %     eg = egs{1};
% % %     L = length(eg);
% % %     for j = 1:L
% % %         if length(eg(L)) <= 3 
% % %             cstr = sprintf('%s(%d, %d)', eg(L(:)));
% % %         else
% % %             cstr = sprintf('%s(%s, %d, %d)', eg(L(:)))
% % %             %{l}{:});
% % %         end
% % %         bhv_struct.TaskObject{c, j} = cstr;
% % %     end
% % % end
% % 
% % cond_whitespace = '\t';
% % cond_header = 1;
% % txtspec = '%s%s%s%s%s%s%s%s%s%s';
% % condfile = textscan(fopen(condpath), txtspec, 'Whitespace', cond_whitespace);
% % infoByCond = cell(length(conds), 1);
% % for i = 1:length(condfile)
% %     if strcmp(condfile{i}{1}, 'Info')
% %         for j = 1:length(conds)
% %             entr = strsplit(condfile{i}{j+cond_header}, ',');
% %             st = struct();
% %             for k = 1:length(entr)/2
% %                 entrInd = 2*k - 1;
% %                 field = strrep(entr{entrInd}, '''', '');
% %                 val = strrep(entr{entrInd+1}, '''', '');
% %                 st.(field) = val;
% %                 infoByCond{j} = st;
% %             end
% %         end
% %     end
% % end
% %  bhv_struct.InfoByCond = infoByCond;


end

