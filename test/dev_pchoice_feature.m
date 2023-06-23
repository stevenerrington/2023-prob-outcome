rwd_punish_values = get_unique_rwdpunish(choice_info);

clear p_choice_feature
feature_list = {'punish_amt','punish_prob','rwd_amt','rwd_prob'};
feature_val_list = {[5, 10], [0, 0.5, 1], [5], [0, 0.5, 1]};

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
    p_choice_feature.rwd_amt_1, p_choice_feature.rwd_prob_1, p_choice_feature.rwd_prob_2, p_choice_feature.rwd_prob_3];

figure('Renderer', 'painters', 'Position', [100 100 500 350]);
b = bar([1:9],bar_data,'EdgeColor','none','BarWidth',0.75);
xticklabels({'Small Laser','Large Laser','0% Laser','50% Laser','100% Laser',...
    'Small Reward', '0% Reward','50% Reward','100% Reward' })
xtickangle( gca , 45 )

b.FaceColor = 'flat';
b.CData(1,:) = [70 106 128]./255;
b.CData(2,:) = [1 24 38]./255;
b.CData(3,:) = [124 204 253]./255;
b.CData(4,:) = [4 150 239]./255;
b.CData(5,:) = [2 67 105]./255;
b.CData(6,:) = [195 0 0]./255;
b.CData(7,:) = [255 167 167]./255;
b.CData(8,:) = [255 79 79]./255;
b.CData(9,:) = [246 0 0]./255;

box off
hline(0.5,'k--'); ylim([0 1])
xlabel('Option feature')
ylabel('P(Choosing option w/feature)')

dim = [0.15 0.7 0.3 0.2];
str = {['Session: ' datafile]; ['Monkey: Slayer']; ['Trials: ' int2str(size(choice_info,1))]};
annotation('textbox',dim,'String',str,'FitBoxToText','on','EdgeColor','none', 'Interpreter', 'none');
