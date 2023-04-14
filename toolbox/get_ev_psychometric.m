
choiceA_ev_rwd    = trialInfo.choiceA_rwd_amt.*trialInfo.choiceA_rwd_prob;
choiceA_ev_punish = trialInfo.choiceA_punish_amt.*trialInfo.choiceA_punish_prob;

choiceB_ev_rwd    = trialInfo.choiceB_rwd_amt.*trialInfo.choiceB_rwd_prob;
choiceB_ev_punish = trialInfo.choiceB_punish_amt.*trialInfo.choiceB_punish_prob;

choiceA_ev_global = choiceA_ev_rwd-choiceA_ev_punish;
choiceB_ev_global = choiceB_ev_rwd-choiceB_ev_punish;

overall_ev_global = choiceA_ev_global-choiceB_ev_global; % +ve = A higher


ev_all = unique([choiceA_ev_global;choiceB_ev_global]);

for ev_i = 1:length(ev_all)
    ev_trials_A = []; ev_trials_B = [];
    ev_trials_A = find(choiceA_ev_global == ev_all(ev_i));
    ev_trials_B = find(choiceB_ev_global == ev_all(ev_i));
    
    p_choice_A(ev_i) = mean(trialInfo.choiceSelected(ev_trials_A) == 1);
    ntrl_choice_A(ev_i) = length(ev_trials_A);
    
    p_choice_B(ev_i) = mean(trialInfo.choiceSelected(ev_trials_B) == 2);
    ntrl_choice_B(ev_i) = length(ev_trials_B);
end



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



%% NEEDS WORK - DOESN'T ACCOUNT FOR CHOICE
ev_all_test = unique(overall_ev_global);
for ev_i = 1:length(ev_all_test)
    
    ev_trials_test = [];
    ev_trials_test = find(ev_all_test == ev_all_test(ev_i));
    
    if length(ev_trials_test > 3)
    p_choice_test(ev_i) = mean(trialInfo.choiceSelected(ev_trials_test) == 1);
    ntrl_choice_test(ev_i) = length(ev_trials_test);
    else
       p_choice_test(ev_i) =NaN;
       ntrl_choice_test(ev_i) =NaN;
    end
    
end


[pred_x_range_test, pred_y_range_test, bestFitParams_test] =...
    fit_ev_psychometric_function(ev_all_test,p_choice_test,ntrl_choice_test);

figure
subplot(1,1,1); hold on
plot(ev_all_test,p_choice_test)
plot(pred_x_range_test,pred_y_range_test)


