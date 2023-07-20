% Setup workspace
clear all; close all; clc
dirs = get_dirs_probrwdpunish('home');

% Define and load example datafile
datafile = 'ProbRwdPunish_18_07_2023_10_58';
data = load(fullfile(dirs.data,datafile));

<<<<<<< Updated upstream
% In development: merge multiple files from one day - dev_mergeFiles

% Extract key session information for processing
=======
% Get trial event times and trial information
>>>>>>> Stashed changes
[trialEventTimes, trialInfo] = get_trial_timeinfo(data.PDS);
[choice_info] = get_choice_info(data.PDS, trialInfo);
<<<<<<< Updated upstream
choice_info = clean_choice_info(choice_info);
=======
rwd_punish_values = get_unique_rwdpunish(choice_info);





[p_choice_feature] = get_pchoice_feature(choice_info);
>>>>>>> Stashed changes

% Plot daily session behavior
plot_session_beh(choice_info,data,datafile);

% Plot daily session glm
glm_out = plot_session_glm(choice_info);

<<<<<<< Updated upstream
%% Legacy
%  probrwdpunish_workspace
=======

















%% Legacy
% [option_info] = get_option_info_glm(data.PDS, trialInfo);
% glmModel = get_task_glm(option_info);
>>>>>>> Stashed changes

