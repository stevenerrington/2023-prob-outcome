function data_out = dev_pchoice_feature_ev(choice_info)

rwd_punish_values = get_unique_rwdpunish(choice_info);

% Color map
rwd_colors = {[181 220 255]./255; [124 204 253]./255; [4 150 239]./255; [2 67 108]./255;};
punish_colors = {[249 171 171]./255; [243 87 86]./255; [223 17 16]./255; [200 5 5]./255};

clear p_choice_feature
feature_list = {'punish_ev','rwd_ev'};
feature_val_list = {[rwd_punish_values.option_all.punish.ev'], [rwd_punish_values.option_all.rwd.ev']};

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

ev_labels = fieldnames(p_choice_feature);
rwd_count = 0; pun_count = 0;

bar_data = []; bar_labels = [];
for label_i = 1:size(ev_labels,1)
    bar_data = [bar_data, p_choice_feature.(ev_labels{label_i})];
    bar_labels = [bar_labels; ev_labels(label_i)];
    
    
    if startsWith(ev_labels{label_i},'rwd')
        rwd_count = rwd_count + 1;
        out_color = rwd_colors{rwd_count};
    end
    if startsWith(ev_labels{label_i},'punish')
        pun_count = pun_count + 1;
        out_color = punish_colors{pun_count};
    end    
    
    bar_color_data(label_i,:) = out_color;
    
end



data_out.x = [1:length(bar_data)];
data_out.y = bar_data;
data_out.labels = bar_labels;
data_out.color = bar_color_data;

end