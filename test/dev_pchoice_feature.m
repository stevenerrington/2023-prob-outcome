function data_out = dev_pchoice_feature(choice_info)

rwd_punish_values = get_unique_rwdpunish(choice_info);

clear p_choice_feature
feature_list = {'punish_amt','punish_prob','rwd_amt','rwd_prob'};
feature_val_list = {[5, 10], [0, 0.5, 1], [5, 10], [0, 0.5, 1]};

for feature_i = 1:length(feature_list)
    for feature_val_i = 1:length(feature_val_list{feature_i})
        
        option_feature = feature_list{feature_i};
        option_feature_val = feature_val_list{feature_i}(feature_val_i);
        
        option_1_label = ['option1_' option_feature];
        option_2_label = ['option2_' option_feature];
        
        option_choice_label = [option_feature '_' int2str(feature_val_i)];
        
        p_choice_feature.(option_choice_label) = ...
            (sum(choice_info.(option_1_label) == option_feature_val & choice_info.option_selected == 0 ) + ...
            sum(choice_info.(option_2_label) == option_feature_val & choice_info.option_selected == 1 ))...
            ./... % Number of times the option with the given feature was selected, divided by...
            (sum(choice_info.(option_1_label) == option_feature_val) + ...
            sum(choice_info.(option_2_label) == option_feature_val)); % Total number of trials with feature
    end
end

bar_data = [];
bar_data = [p_choice_feature.punish_amt_1, p_choice_feature.punish_amt_2,...
    p_choice_feature.punish_prob_1, p_choice_feature.punish_prob_2, p_choice_feature.punish_prob_3,...
    p_choice_feature.rwd_amt_1, p_choice_feature.rwd_amt_2, p_choice_feature.rwd_prob_1, p_choice_feature.rwd_prob_2, p_choice_feature.rwd_prob_3];

%%

data_out.x = [1:length(bar_data)];
data_out.y = bar_data;

end
