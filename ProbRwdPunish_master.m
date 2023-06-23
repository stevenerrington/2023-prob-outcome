
% Setup workspace
clear all; close all; clc
dirs = get_dirs_probrwdpunish('wustl');

% Define and load example datafile
datafile = 'ProbRwdPunish_21_06_2023_10_56';
data = load(fullfile(dirs.root,'data',datafile));

[trialEventTimes, trialInfo] = get_trial_timeinfo(data.PDS);
[choice_info] = get_choice_info(data.PDS, trialInfo);

dev_pchoice_feature
dev_pchoice_feature_ev

[p_choice_feature] = get_pchoice_feature(choice_info);



[option_info] = get_option_info_glm(data.PDS, trialInfo);

glmModel = get_task_glm(option_info);

