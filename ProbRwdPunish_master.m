
% Setup workspace
clear all; close all; clc
dirs = get_dirs_probrwdpunish('wustl');

% Define and load example datafile
datafile = 'ProbRwdPunish_19_06_2023_11_28';
data = load(fullfile(dirs.root,'data',datafile));

[trialEventTimes, trialInfo] = get_trial_timeinfo(data.PDS);
[option_info] = get_option_info_glm(data.PDS, trialInfo);

glmModel = get_task_glm(option_info);

