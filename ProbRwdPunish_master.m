% Setup workspace
clear all; close all; clc
dirs = get_dirs_probrwdpunish('wustl');

% Define and load example datafile
datafile = 'ProbRwdPunish_29_06_2023_12_05';
data = load(fullfile(dirs.data,datafile));

% In development: merge multiple files from one day - dev_mergeFiles

% Extract key session information for processing
[trialEventTimes, trialInfo] = get_trial_timeinfo(data.PDS);
[choice_info] = get_choice_info(data.PDS, trialInfo);
choice_info = clean_choice_info(choice_info);

% Plot daily session behavior
plot_session_beh(choice_info,data,datafile)

%% Legacy
%  probrwdpunish_workspace

