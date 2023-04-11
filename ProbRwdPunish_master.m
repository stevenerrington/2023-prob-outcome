
% Setup workspace
clear all; close all; clc
dirs = get_dirs_probrwdpunish('wustl');

% Define and load example datafile
datafile = 'ProbRwdPunish_11_04_2023_09_48';
data = load(fullfile(dirs.root,'data',datafile));

% Setup table of key event times
trialEventTimes = table();
trialEventTimes.i = data.PDS.trialnumber';
trialEventTimes.trialStart = data.PDS.trialstarttime;
trialEventTimes.fixOn      = trialEventTimes.trialStart+data.PDS.timefpon';
trialEventTimes.choiceA_on = trialEventTimes.trialStart+data.PDS.timetargeton';
trialEventTimes.choiceB_on = trialEventTimes.trialStart+data.PDS.timetargeton2';
trialEventTimes.punish = trialEventTimes.trialStart+data.PDS.TimeofPunish';
trialEventTimes.reward = trialEventTimes.trialStart+data.PDS.timereward';
trialEventTimes.trialEnd = trialEventTimes.trialStart+data.PDS.trialover';

trialInfo = table();
trialInfo.i = data.PDS.trialnumber';
trialInfo.choice_order = data.PDS.whichtoshowfirst';
trialInfo.choiceSelected = data.PDS.chosenwindow';
trialInfo.delivered_punish = data.PDS.PunishStrength_';


(10./data.PDS.punfactoffer2')/10;
(10./data.PDS.rewfactoffer2')/10;

trialInfo.choiceA_present_rwdAmt = (data.PDS.RewardRange1*10)';
trialInfo.choiceA_present_rwdProb = (10./data.PDS.rewfactoffer1')/10;
trialInfo.choiceA_present_rwdEV = 0;
trialInfo.choiceA_present_punishAmt = 0;
trialInfo.choiceA_present_punishProb = (10./data.PDS.punfactoffer1')/10;
trialInfo.choiceA_present_punishEV = 0;

