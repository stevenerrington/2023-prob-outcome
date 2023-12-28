clear all; clc;

%% Set simulation parameters
reward_probability = [0 33 66 100]; % Probabilities: to have a medium amount, I have done 33% and 66%. I would expect 33% to correspond to uncertain, and 66% to correspond to medium
delays = [2 5 8]; % Delay times: 2, 5 (uncertain), or 8 seconds
delay_value = [3 2 1]; % Delay values: this will be used for calculating subjective value  (as shorter rewards are weighted more highly)
pres_order = [1 2]; % Presentation order: will the monkey recieve reward or delay first
timer_cue = [0 1]; % Timer cue: Will the delay epoch be cued or not (i.e. will the timer run?)
reveal_cue = [0 1]; % Reveal cue: will the reward outcome be revealed or not?

n_trl_sim = 1000; % Number of simulated trials to run
p_trials_engaged = 0.8; % Proportion of trials in which the monkey chose
fixed_trial_time = 6; % Sum of fixation time, choice onset, interstimuli interval (estimated, in seconds).

%% Run simulation
for trial_i = 1:n_trl_sim

    pres_order(trial_i,1) = randi([1 2]);

    offer1_rwd_idx = 0; offer1_delay_idx = 0;
    offer2_rwd_idx = 0; offer2_delay_idx = 0;

    while offer1_rwd_idx == offer2_rwd_idx & offer1_delay_idx == offer2_delay_idx
        offer1_rwd_idx =  randi([1, length(reward_probability)]);
        offer1_delay_idx =  randi([1, length(delays)]);
        offer2_rwd_idx =  randi([1, length(reward_probability)]);
        offer2_delay_idx =  randi([1, length(delays)]);
    end

offer_1(trial_i,:) = [reward_probability(offer1_rwd_idx) , delays(offer1_delay_idx)];
offer_2(trial_i,:) = [reward_probability(offer2_rwd_idx) , delays(offer2_delay_idx)];

offer1_ev(trial_i,:) = offer_1(trial_i,1) * delay_value(offer1_delay_idx);
offer2_ev(trial_i,:) = offer_2(trial_i,1) * delay_value(offer2_delay_idx);

[~, choice(trial_i,:)] = max([offer1_ev(trial_i,:) offer2_ev(trial_i,:)]);

cued_timer(trial_i,1) = randi([0 1]);
cued_reveal(trial_i,1) = randi([0 1]);

switch choice(trial_i,:)
    case 1
        choice_offer(trial_i,:) = offer_1(trial_i,:);
    case 2
        choice_offer(trial_i,:) = offer_2(trial_i,:);
end

simulation_table(trial_i,:) = table(trial_i, pres_order(trial_i,:), offer_1(trial_i,:), offer_2(trial_i,:), offer1_ev(trial_i,:), offer2_ev(trial_i,:), choice(trial_i,:), choice_offer(trial_i,:), cued_timer(trial_i,:), cued_reveal(trial_i,:),...
    'VariableNames',{'trial_i','pres_order','offer1','offer2','offer1_ev','offer2_ev','choice','choice_offer','cued_timer','cued_reveal'});

end

%{
Find the proportion of choices with small, medium, large, and uncertain
rewards
%}

for rwd_prob_i = 1:length(reward_probability)
    fprintf('> In %i percent of trials (%i/%i), the monkey chose the %i percent reward probability \n',...
        mean(simulation_table.choice_offer(:,1) == reward_probability(rwd_prob_i)) * 100,...
        sum(simulation_table.choice_offer(:,1) == reward_probability(rwd_prob_i)),...
        n_trl_sim,...
        reward_probability(rwd_prob_i))
end


%{
Find the proportion of choices with short, long, and uncertain delays
%}
for delay_i = 1:length(delays)
    fprintf('> In %i of trials (%i/%i), the monkey chose the %i second day \n',...
        mean(simulation_table.choice_offer(:,2) == delays(delay_i)) * 100,...
        sum(simulation_table.choice_offer(:,2) == delays(delay_i)),...
        n_trl_sim,...
        delays(delay_i))
end

%{
Find the proportion of uncertain outcomes with cued timer and cued reveal
Find the proportion of uncertain outcomes with cued timer and non-cued reveal
Find the proportion of uncertain outcomes with non-cued timer and cued reveal
Find the proportion of uncertain outcomes with non-cued timer and non-cued reveal
%}



mean(simulation_table.choice_offer(:,1) == 33  & simulation_table.cued_timer == 1 & simulation_table.cued_reveal == 1)
mean(simulation_table.choice_offer(:,1) == 33  & simulation_table.cued_timer == 1 & simulation_table.cued_reveal == 0)
mean(simulation_table.choice_offer(:,1) == 33  & simulation_table.cued_timer == 0 & simulation_table.cued_reveal == 1)
mean(simulation_table.choice_offer(:,1) == 33  & simulation_table.cued_timer == 0 & simulation_table.cued_reveal == 1)