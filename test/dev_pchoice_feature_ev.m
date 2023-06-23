rwd_punish_values = get_unique_rwdpunish(choice_info);

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

bar_data = [];
bar_data = [p_choice_feature.punish_ev_1, p_choice_feature.punish_ev_2,...
    p_choice_feature.punish_ev_3, p_choice_feature.punish_ev_4,...
    p_choice_feature.rwd_ev_1, p_choice_feature.rwd_ev_2,...
    p_choice_feature.rwd_ev_3];

figure('Renderer', 'painters', 'Position', [100 100 500 350]);
b = bar([1:length(bar_data)],bar_data,'EdgeColor','none','BarWidth',0.75);
xticklabels({'1: PunishEV','2: PunishEV','3: PunishEV','4: PunishEV',...
    '1: RewardEV','2: RewardEV','3: RewardEV'})
xtickangle( gca , 45 )

b.FaceColor = 'flat';

b.CData(1,:) = [181 220 255]./255;
b.CData(2,:) = [124 204 253]./255;
b.CData(3,:) = [4 150 239]./255;
b.CData(4,:) = [2 67 108]./255;
b.CData(5,:) = [249 171 171]./255;
b.CData(6,:) = [243 87 86]./255;
b.CData(7,:) = [223 17 16]./255;

box off
hline(0.5,'k--'); ylim([0 1])
xlabel('Option feature')
ylabel('P(Choosing option w/feature)')


dim = [0.15 0.7 0.3 0.2];
str = {['Session: ' datafile]; ['Monkey: Slayer']; ['Trials: ' int2str(size(choice_info,1))]};
annotation('textbox',dim,'String',str,'FitBoxToText','on','EdgeColor','none', 'Interpreter', 'none');
