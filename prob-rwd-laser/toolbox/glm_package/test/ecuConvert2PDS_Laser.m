% Convert the output of eCurator (Takaya modified Julia's one for laser test) into PDS structure
% for further analysis. 
%
% Task: Laser
%%%%%%%%%%%%%%%%%%%%%
clear

% Load in the eCurated data file
ecDir1 = 'Y:\MONKEYDATA\Sabbath\LaserTest\PLEXON\CuratorOutputs\';
ecDir2 = 'Y:\MONKEYDATA\Slayer2\Laser test\PLEXON\CuratorOutputs\';
addpath(ecDir1); addpath(ecDir2);

ecDirFiles1      = dir([ecDir1 '*.mat']);
ecDirFiles2      = dir([ecDir2 '*.mat']);

ecDirFiles = [ecDirFiles1; ecDirFiles2];

ecDirFiles      = {ecDirFiles.name};
nEcFiles        = length(ecDirFiles);



for ii = 1:nEcFiles
    ecFilename      = ecDirFiles{ii}
    
    pathoffile = which(ecFilename);
    load(pathoffile);
    
%     load([ecDir ecFilename]);

    % Get key for trial event codes
    codefile        = 'C:\Users\Takaya\Dropbox\LASER\SpikeAnalysisWorkflow\dependency\';
    addpath(codefile);
    codes           = stimcodes;

    % Specify the task you want data from (eCurated files combine across pl2
    % files recorded from multiple tasks)
    taskName        = 'LaserTest';  
    taskRange       = find(strcmp(out.trial.task_name, taskName));
    
    taskStart       = min(taskRange);
    taskEnd         = max(taskRange);
    nT              = length(taskRange);

% Specify directory for saving out PDS files to
   if contains(out.metadata.basic.Subj, 'sb')
    saveDir         ='Y:\MONKEYDATA\Sabbath\LaserTest\PLEXON\PDS\';
   elseif contains(out.metadata.basic.Subj, 'sl')
       saveDir         ='Y:\MONKEYDATA\Slayer2\Laser test\PLEXON\PDS\';
   end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get times for each trial's events 
    trialCodes      = out.trial.event.code(taskRange);
    trialCodeTimes  = out.trial.event.t_s(taskRange);
%     allcodes        = vertcat(trialCodes{:});

    % Initialize variables for all trials
    trialnumber     = nan(1, nT);
    trialstarttime  = nan(1, nT); %codes.trialBegin
    trialendtime    = nan(1, nT); % codes.trialEnd
    timefpon        = nan(1, nT); % codes.fixdoton
    timetargeton    = nan(1, nT);    % codes.targeton
    timetargeton2    = nan(1, nT);  %  c.codes.targeton2;

    timeLaser = nan(1, nT); % codes.laser OR codes.nolaser
    PunishmentRange1 = nan(1, nT); % (c.PunishmentRange1+12500); PunishmentRange1 = [2 4 6 8];
    PunishmentRange2 = nan(1, nT); % (c.PunishmentRange2+13500); PunishmentRange2 = [2 4 6 8];
    PunishStrength1_ = nan(1, nT); % ( c.energy(c.PunishmentRange1./2)+12700); %% seems not to correctly be sent to Plexon
    PunishStrength2_ = nan(1, nT); % ( c.energy(c.PunishmentRange2./2)+13700); %% Check with Ilya!
    
    timereward     = nan(1, nT); % codes.reward
    RewardRange1 = nan(1, nT); % (c.RewardRange1+12000); RewardRange1 = [0 2 4 6];
    RewardRange2 = nan(1, nT); % (c.RewardRange2+13000); RewardRange2 = [0 2 4 6];

    chosenwindow    = nan(1, nT);  %chodes.window2chosen OR codes.window1chosen
    timeChoice         = nan(1, nT);  %chodes.window2chosen OR codes.window1chosen

    rewardorpunishfirst = nan(1, nT); %(c.rewardorpunishfirst+11000);

    ChoiceMatrix = nan(nT, 5);

    for iT = 1:nT 
        cc          = trialCodes{iT};
        ct          = trialCodeTimes{iT};
        tStart      = ct(cc==codes.trialBegin);

        % trial events
        trialnumber(iT)     = iT;
        trialstarttime(iT)  = ct((cc==codes.trialBegin));
        trialendtime(iT)    = ct(cc==codes.trialEnd);
        %%% even timing relative to trial start time %%%%%%%%%%%%%%

        temp = ct(cc==codes.fixdoton) - tStart;
        if ~isempty(temp); timefpon(iT) = temp; end

        temp = ct(cc==codes.targeton) - tStart;
        if ~isempty(temp); timetargeton(iT) = temp; end
        
        temp = ct(cc==codes.targeton2) - tStart;
        if ~isempty(temp); timetargeton2(iT) = temp; end
        
        temp = ct(cc==codes.laser | cc == codes.nolaser) - tStart;
        if ~isempty(temp); timeLaser(iT) = temp; end
       
        temp = ct(cc==codes.reward) - tStart;
        if ~isempty(temp); timereward(iT) = temp; end
        
       %% need to check task script (when is the true choice timing?)
        temp = ct(cc==codes.window2chosen | cc==codes.window1chosen) - tStart;
        if ~isempty(temp); timeChoice(iT) = temp; end

        %%% trial information %%%%%%%%%%%%%%%%%%%%%%%%%
        temp = cc(ismember(cc, 12500:12510));
        if ~isempty(temp); PunishmentRange1(iT) = temp - 12500; end
        
        temp = cc(ismember(cc, 13500:13510));
        if ~isempty(temp); PunishmentRange2(iT) = temp - 13500; end
       
        temp = cc(ismember(cc, 12000:12010));
        if ~isempty(temp); RewardRange1(iT) = temp - 12000; end
        
        temp = cc(ismember(cc, 13000:13010));
        if ~isempty(temp); RewardRange2(iT) = temp - 13000; end
        
         temp = cc(ismember(cc, 9000:9010));
        if ~isempty(temp); chosenwindow(iT) = temp - 9000; end
        
         temp = cc(ismember(cc, 11000:11010));
        if ~isempty(temp); rewardorpunishfirst(iT) = temp - 11000; end
        
        

    end
    
    ChoiceMatrix = [RewardRange1' PunishmentRange1' RewardRange2' PunishmentRange2' chosenwindow'];
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % For each sorted unit, save out a separate PDS file containing trials and
    % spikes from good time windows.
    nUnits = length(out.unit);  % number of sorted units

    for iU = 1:nUnits
       un           = out.unit{iU}; 
       unValid      = find(un.valid.trial.ok);
       validRange   = intersect(unValid, taskRange);
       nValid       = length(validRange);

       unId         = out.cl.info.id(iU);
%        saveFile     = strsplit(ecFilename, '_');
%        saveFile     = saveFile{1};
       saveFile     = strsplit(ecFilename, '-');
       saveFile     = [saveFile{1},'-',saveFile{2},'-',saveFile{3}(1:3)];
       saveFile     = [saveDir saveFile '_' taskName '_cl' num2str(unId)];

       if isempty(validRange)
           continue % if this unit wasn't isolated during the task, continue to next sorted cluster
       else
           sptimes  = cell(1, nValid);
           for iT_ = 1:nValid
                iT      = validRange(iT_);
                tStart  = out.trial.tstart_s(iT);
                tEnd    = out.trial.tend_s(iT);
                tSp     = un.spiketimes_s(un.spiketimes_s>tStart & un.spiketimes_s<tEnd) - tStart;
                sptimes{iT_} = tSp';
           end
           % save out information for trials where unit was valid
           r           = ismember(taskRange, validRange);

           PDS              = struct;
           PDS.datetime_recording_started = out.metadata.datetime_recording_started;
           PDS.recinfo      = out.metadata.basic;
           PDS.position     = out.unit{iU}.pos.chan;

           PDS.trialnumber  = trialnumber(r);
           PDS.trialstarttime = trialstarttime(r);
           PDS.trialendtime = trialendtime(r);
           PDS.timefpon     = timefpon(r);
           PDS.timetargeton = timetargeton(r);
           PDS.timetargeton2 = timetargeton2(r);
           PDS.timeLaser   = timeLaser(r);
           PDS.PunishmentRange1 = PunishmentRange1(r);
           PDS.PunishmentRange2 = PunishmentRange2(r);
           PDS.timereward  = timereward(r);
           PDS.RewardRange1 = RewardRange1(r);
           PDS.RewardRange2     = RewardRange2(r);
           PDS.chosenwindow    = chosenwindow(r);
           PDS.timeChoice = timeChoice(r);
           PDS.rewardorpunishfirst = rewardorpunishfirst(r);
           PDS.ChoiceMatrix = ChoiceMatrix(r,:);
           
           PDS.sptimes      = sptimes;

           PDS.channel = un.wave.chan;
           PDS.wave.mean = un.wave.mean;
           PDS.wave.sd = un.wave.sd;
           PDS.wave.time = out.wave.t_s;
           PDS.sessionID = ii;
           
           
           save([saveFile '_PDS.mat'], 'PDS', '-v7.3');

       end
    end
end

