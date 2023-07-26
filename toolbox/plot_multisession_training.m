files = {'ProbRwdPunish_12_07_2023_12_00.mat';...
    'ProbRwdPunish_13_07_2023_11_33.mat';...
    'ProbRwdPunish_14_07_2023_11_45.mat';...
    'ProbRwdPunish_17_07_2023_11_52.mat';...
    'ProbRwdPunish_18_07_2023_10_58.mat';...
    'ProbRwdPunish_19_07_2023_11_05.mat';...
    'ProbRwdPunish_20_07_2023_11_12.mat';...
    'ProbRwdPunish_21_07_2023_10_28.mat';... 
    'ProbRwdPunish_24_07_2023_11_55.mat'};

clear reward_glm_logOdd laser_glm_logOdd constant_glm_logOdd...
    p_highest_*

for file_i = 1:length(files)
    
    fprintf('Extracting: %s [%i of %i]  \n', files{file_i}, file_i, length(files))    
    
    % Load data ---------------------------------------------------
    data = load(fullfile(dirs.data,files{file_i}));
    
    % Processing --------------------------------------------------
    % Get trial event times and trial information
    [trialEventTimes, trialInfo] = get_trial_timeinfo(data.PDS);
    
    % Get choice specific information
    [choice_info] = get_choice_info(data.PDS, trialInfo);
    % Clean/remove no-option trials
    choice_info = clean_choice_info(choice_info);
    
    choice_trial_data = choice_ev_trial(choice_info);
    
    
    % GLM ----------------------------------------------------------
    clear rawbehav
    rawbehav.choices=[choice_info.option1_rwd_ev,...
        choice_info.option1_punish_ev,...
        choice_info.option2_rwd_ev,...
        choice_info.option2_punish_ev,...
        choice_info.option_selected+1];
    
    rawbehav.choices(find(rawbehav.choices(:,5) < 1),:) = [];
    
    clear bbd modan bfit
    bbd.monk.sva{1} = aatradeoff_subjective_value_analysis_v04(rawbehav.choices);
    modan = bbd.monk.sva{1}.model;
    bfit = bbd.monk.sva{1}.model.analysis{1}.behav_full_fit;
        
    % Concatenate data across files
    reward_glm_logOdd(file_i,1) = bfit.b(1);
    laser_glm_logOdd(file_i,1) = bfit.b(2);
    constant_glm_logOdd(file_i,1) = bfit.b(3);
    
    p_highest_diff_ev(file_i,1) = nanmean(choice_trial_data.diff_selectPosVal);
    p_highest_laser_ev(file_i,1) = nanmean(choice_trial_data.punish_selectBigEV);
    p_highest_reward_ev(file_i,1) = nanmean(choice_trial_data.rwd_selectBigEV);
    
    xlabel_name{file_i,1} = strrep(files{file_i}(15:24),'_','/');
end



%% Figure

figure('Renderer', 'painters', 'Position', [100 100 500 500]);
subplot(2,1,1); hold on
plot(1:length(files),p_highest_diff_ev','k'); scatter(1:length(files),p_highest_diff_ev',30,'k','filled');
plot(1:length(files),p_highest_laser_ev','b'); scatter(1:length(files),p_highest_laser_ev',30,'b','filled');
plot(1:length(files),p_highest_reward_ev','r'); scatter(1:length(files),p_highest_reward_ev',30,'r','filled');
xlim([0 length(files)+1]); ylim([0 1]);
xticks([1:length(files)]); xticklabels(xlabel_name); xticklabel_rotate([],45);
xlabel('Session date'); ylabel('P(Choose highest EV)');
annotation('textbox',[.8 .8 .1 .1],'String','Reward','EdgeColor','none','Color','r');
annotation('textbox',[.8 .75 .1 .1],'String','Laser','EdgeColor','none','Color','b');
annotation('textbox',[.8 .7 .1 .1],'String','Diff','EdgeColor','none','Color','k');

subplot(2,1,2); hold on
plot(1:length(files),constant_glm_logOdd','k'); scatter(1:length(files),constant_glm_logOdd',30,'k','filled');
plot(1:length(files),laser_glm_logOdd','b'); scatter(1:length(files),laser_glm_logOdd',30,'b','filled');
plot(1:length(files),reward_glm_logOdd','r'); scatter(1:length(files),reward_glm_logOdd',30,'r','filled');
xlim([0 length(files)+1]); ylim([-0.5 1.5]);
xticks([1:length(files)]); xticklabels(xlabel_name); xticklabel_rotate([],45);
xlabel('Session date'); ylabel('logOdds of choosing option 2');
annotation('textbox',[.8 .3 .1 .1],'String','Reward','EdgeColor','none','Color','r');
annotation('textbox',[.8 .25 .1 .1],'String','Laser','EdgeColor','none','Color','b');
annotation('textbox',[.8 .2 .1 .1],'String','Diff','EdgeColor','none','Color','k');