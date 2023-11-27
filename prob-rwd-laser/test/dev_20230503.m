

%% Determine expected value for each option
% > Choice A (right)
ev_data.choiceA.reward = trialInfo.choiceA_rwd_amt.*trialInfo.choiceA_rwd_prob; % Reward
ev_data.choiceA.punish = trialInfo.choiceA_punish_amt.*trialInfo.choiceA_punish_prob; % Punishment
ev_data.choiceA.global = ev_data.choiceA.reward - ev_data.choiceA.punish; % Reward - Punishment (+ve = +ve valence)


% > Choice B (left)
ev_data.choiceB.reward = trialInfo.choiceB_rwd_amt.*trialInfo.choiceB_rwd_prob; % Reward
ev_data.choiceB.punish = trialInfo.choiceB_punish_amt.*trialInfo.choiceB_punish_prob; % Punishment
ev_data.choiceB.global = ev_data.choiceB.reward - ev_data.choiceB.punish; % Reward - Punishment (+ve = +ve valence)

% > Joint (Overall)
ev_data.joint.reward = ev_data.choiceA.reward - ev_data.choiceB.reward; % Reward - Punishment (+ve = +ve valence)
ev_data.joint.punish = ev_data.choiceA.punish - ev_data.choiceB.punish; % Reward - Punishment (+ve = +ve valence)
ev_data.joint.global = ev_data.choiceA.global - ev_data.choiceB.global; % Reward - Punishment (+ve = +ve valence)


%% Workspace:
choice_labels = {'choiceA','choiceB','joint'};
valence_labels = {'punish','reward','global'};

% Find all experienced expected values

for valence_i = 1:length(valence_labels)
    
    ev_all = [];
    ev_all = unique([ev_data.choiceA.(valence_labels{valence_i});ev_data.choiceB.(valence_labels{valence_i})]);

    % For each unique expected value
    for ev_i = 1:length(ev_all)
        
        % Find trials which had the given expected value
        ev_trials_A = []; ev_trials_B = [];
        ev_trials_A = find(ev_data.choiceA.(valence_labels{valence_i}) == ev_all(ev_i)); % Right
        ev_trials_B = find(ev_data.choiceB.(valence_labels{valence_i}) == ev_all(ev_i)); % Left
        
        % Find proportion (and number) of these trials which option A was selected
        ev_data.analysis.(valence_labels{valence_i}).p_choice.A(ev_i) = mean(trialInfo.choiceSelected(ev_trials_A) == 1);
        ev_data.analysis.(valence_labels{valence_i}).ntrl_choice.A(ev_i) = length(ev_trials_A);
        
        ev_data.analysis.(valence_labels{valence_i}).p_choice.B(ev_i) = mean(trialInfo.choiceSelected(ev_trials_B) == 2);
        ev_data.analysis.(valence_labels{valence_i}).ntrl_choice.B(ev_i) = length(ev_trials_B);
    end

    
end


% For each unique expected value
for ev_i = 1:length(ev_all)
    
    % Find trials which had the given expected value
    ev_trials_A = []; ev_trials_B = [];
    ev_trials_A = find(choiceA_ev_global == ev_all(ev_i)); % Right
    ev_trials_B = find(choiceB_ev_global == ev_all(ev_i)); % Left
    
    % Find proportion (and number) of these trials which option A was selected
    p_choice_A(ev_i) = mean(trialInfo.choiceSelected(ev_trials_A) == 1);
    ntrl_choice_A(ev_i) = length(ev_trials_A);
    
    % Find proportion (and number) of these trials which option B was selected
    p_choice_B(ev_i) = mean(trialInfo.choiceSelected(ev_trials_B) == 2);
    ntrl_choice_B(ev_i) = length(ev_trials_B);
end



[pred_x_range_A, pred_y_range_A, bestFitParams_A] =...
    fit_ev_psychometric_function(ev_all,p_choice_A,ntrl_choice_A);
[pred_x_range_B, pred_y_range_B, bestFitParams_B] =...
    fit_ev_psychometric_function(ev_all,p_choice_B,ntrl_choice_B);

figure
subplot(1,2,1); hold on
scatter(ev_all,p_choice_A)
plot(pred_x_range_A,pred_y_range_A)

subplot(1,2,2); hold on
scatter(ev_all,p_choice_B)
plot(pred_x_range_B,pred_y_range_B)

