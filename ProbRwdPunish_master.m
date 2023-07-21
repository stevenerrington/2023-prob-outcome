%% ProbRwdPunish main sheet

%% Setup workspace
clear all; close all; clc; warning off
dirs = get_dirs_probrwdpunish('mac');

% Define and load example datafile
datafile = 'ProbRwdPunish_21_07_2023_10_28';
data = load(fullfile(dirs.data,datafile));

%% Processing
% Get trial event times and trial information
[trialEventTimes, trialInfo] = get_trial_timeinfo(data.PDS);

% Get choice specific information
[choice_info] = get_choice_info(data.PDS, trialInfo);
% Clean/remove no-option trials
choice_info = clean_choice_info(choice_info);

%% Exports
% Plot daily session behavior
plot_session_beh(choice_info,data,datafile);

% Plot daily session glm
glm_out = plot_session_glm(choice_info);

%% Legacy
%  probrwdpunish_workspace

% In development: merge multiple files from one day - dev_mergeFiles


