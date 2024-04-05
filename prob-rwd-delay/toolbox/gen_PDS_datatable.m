function delay_datatable = gen_PDS_datatable(PDS)

%% Set up data structure
% Create table
delay_datatable = table(...
    PDS.trialnumber',... % Trial number
    PDS.goodtrial',... % Good trial flag
    PDS.attribute_order_pres_all(:,1),... % Offer 1 - Attribute Order
    PDS.attribute_order_pres_all(:,2),... % Offer 2 - Attribute Order
    PDS.offer1_choice_rwd' ,... % Offer 1 - Reward
    PDS.offer1_choice_delay',... % Offer 1 - Delay
    PDS.offer2_choice_rwd',... % Offer 2 - Reward
    PDS.offer2_choice_delay',... $ Offer 2 - Delay
    PDS.chosenwindow',... % Chosen offer
    'VariableNames',{'trialN','goodtrial','offer1_att_order','offer2_att_order','offer1_rwd','offer1_delay','offer2_rwd','offer2_delay','choice'});

% Cut to specific trials
trials_to_include = []; trials_to_include = 1:size(delay_datatable,1);
delay_datatable = delay_datatable(trials_to_include,:);

% Remove non-trials
delay_datatable = delay_datatable(delay_datatable.goodtrial == 1,:);

% Get a variable for the chosen option
for trial_i = 1:size(delay_datatable,1)
    delay_datatable.offer1_first(trial_i) = PDS.first_offer_idx(trial_i) == 1;
    delay_datatable.offer2_first(trial_i) = PDS.first_offer_idx(trial_i) == 2;
    delay_datatable.delay_first(trial_i) = PDS.attribute_order_pres(trial_i) == 1;
    delay_datatable.reward_first(trial_i) = PDS.attribute_order_pres(trial_i) == 2;

    delay_datatable.chosen_rwd(trial_i) = delay_datatable.(['offer' int2str(delay_datatable.choice(trial_i)) '_rwd'])(trial_i);
    delay_datatable.chosen_delay(trial_i) = delay_datatable.(['offer' int2str(delay_datatable.choice(trial_i)) '_delay'])(trial_i);
    delay_datatable.chosen_rt(trial_i) = PDS.timeChoice(trial_i) - PDS.timeOffer2(trial_i);
end

end
