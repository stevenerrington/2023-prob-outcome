% Setup workspace
clear all; close all; clc
dirs = get_dirs_probrwdpunish('home');

% Define and load example datafile
datafile = 'ProbRwdPunish_18_07_2023_10_58';
data = load(fullfile(dirs.data,datafile));

% In development: merge multiple files from one day - dev_mergeFiles

% Extract key session information for processing
[trialEventTimes, trialInfo] = get_trial_timeinfo(data.PDS);
[choice_info] = get_choice_info(data.PDS, trialInfo);
choice_info = clean_choice_info(choice_info);

% Plot daily session behavior
plot_session_beh(choice_info,data,datafile);

% Plot daily session glm
glm_out = plot_session_glm(choice_info);

%% Legacy
%  probrwdpunish_workspace

