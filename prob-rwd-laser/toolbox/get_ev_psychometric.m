
% Get the expected value for reward and punish for option 1
option1_ev_rwd    = trialInfo.choiceA_rwd_amt.*trialInfo.choiceA_rwd_prob;
option1_ev_punish = trialInfo.choiceA_punish_amt.*trialInfo.choiceA_punish_prob;

option2_ev_rwd    = trialInfo.choiceB_rwd_amt.*trialInfo.choiceB_rwd_prob;
option2_ev_punish = trialInfo.choiceB_punish_amt.*trialInfo.choiceB_punish_prob;

option1_ev_global = option1_ev_rwd-option1_ev_punish;
option2_ev_global = option2_ev_rwd-option2_ev_punish;

overall_ev_global = option1_ev_global-option2_ev_global; % +ve = A higher


ev_all = unique(overall_ev_global);

for ev_i = 1:length(ev_all)
    ev_trials_in = []; ev_trials_in = find(option1_ev_global == ev_all(ev_i));
    
    p_choose_1(ev_i,1) = mean(trialInfo.choiceSelected(ev_trials_in) == 2);

end

figure;
bar(ev_all,p_choose_1)

[pred_x_range_A, pred_y_range_A, bestFitParams_A] =...
    fit_ev_psychometric_function(ev_all,p_choice_A,ntrl_choice_A);
[pred_x_range_B, pred_y_range_B, bestFitParams_B] =...
    fit_ev_psychometric_function(ev_all,p_choice_B,ntrl_choice_B);

figure
subplot(1,2,1); hold on
plot(ev_all,p_choice_A)
plot(pred_x_range_A,pred_y_range_A)

subplot(1,2,2); hold on
plot(ev_all,p_choice_B)
plot(pred_x_range_B,pred_y_range_B)

