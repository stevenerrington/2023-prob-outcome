function [selection_info] = get_selection_info_choiceMatrix(option_info, datafile)

% Estimate expected values for reward, punishment, and their difference,
% for each trial
for trl_i = 1:size(option_info,1)
    
       selection_info.option1_rwd_ev(trl_i,1) = option_info.option1_rwd_amt(trl_i,1) .* option_info.option1_rwd_prob(trl_i,1);
       selection_info.option1_punish_ev(trl_i,1) = option_info.option1_punish_amt(trl_i,1) .* option_info.option1_punish_prob(trl_i,1);
       selection_info.option1_diff_ev(trl_i,1) = selection_info.option1_rwd_ev(trl_i,1) - selection_info.option1_punish_ev(trl_i,1) ;
       
       selection_info.option2_rwd_ev(trl_i,1) = option_info.option2_rwd_amt(trl_i,1) .* option_info.option2_rwd_prob(trl_i,1);
       selection_info.option2_punish_ev(trl_i,1) = option_info.option2_punish_amt(trl_i,1) .* option_info.option2_punish_prob(trl_i,1);
       selection_info.option2_diff_ev(trl_i,1) = selection_info.option2_rwd_ev(trl_i,1) - selection_info.option2_punish_ev(trl_i,1) ;

end

% Find the unique expected values (difference; reward - punish)
option_1_unique_diffev = unique(selection_info.option1_diff_ev);
option_2_unique_diffev = unique(selection_info.option2_diff_ev);

option_1_unique_diffev = option_1_unique_diffev(~isnan(option_1_unique_diffev));
option_2_unique_diffev = option_2_unique_diffev(~isnan(option_2_unique_diffev));

% Create a choice matrix
for opt_1_i = 1:length(option_1_unique_diffev)
    for opt_2_i = 1:length(option_2_unique_diffev)

        opt1_val = option_1_unique_diffev(opt_1_i);
        opt2_val = option_1_unique_diffev(opt_2_i);

        trials = [];
        trials = find(selection_info.option1_diff_ev == opt1_val & selection_info.option2_diff_ev == opt2_val);

        if isempty(trials)
            choice_matrix(opt_1_i, opt_2_i) = NaN;
        else
            choice_matrix(opt_1_i, opt_2_i) = mean(option_info.option_selected(trials) == 0);
        end

    end
end



outcome_type = {'punish','rwd'};
measure_type = {'amt','prob'};

option_i = 1;
outcome_i = 1;
measure_i = 1;

['option_' int2str(option_i) '_unique_' outcome_type{outcome_i} '_' measure_type{measure_i}]


out_val = [];
% Option 2
for i = 1:length(option_1_unique_punish_amt)
    in_val = []; in_val = option_1_unique_punish_amt(i);
    trials = []; trials = find(option_info.option1_punish_amt == in_val);
    out_val(i) = mean(option_info.option_selected(trials) == 0);
end




%% Create figures

% Choice matrix, heatmap
max_val_range = max(abs([option_1_unique_diffev; option_2_unique_diffev]));

figure;
plot_h = imagesc('XData',option_1_unique_diffev,'YData',option_2_unique_diffev,'CData',choice_matrix);
set(plot_h, 'AlphaData', ~isnan(choice_matrix))

xlim([-max_val_range-1, max_val_range+1]);
ylim([-max_val_range-1, max_val_range+1]);
xticks(option_1_unique_diffev); yticks(option_2_unique_diffev)
xlabel('Option 1: EV_r_w_d - EV_p_u_n_i_s_h','FontSize',12); ylabel('Option 2: EV_r_w_d - EV_p_u_n_i_s_h','FontSize',12)

plot_colorbar = colorbar; colormap(plasma)
ylabel(plot_colorbar,'P(Option 2 Selected)','FontSize',12,'Rotation',270);
plot_colorbar.Label.Position(1) = 4;

detail_text = {['Session: ' datafile]; ['Monkey: Slayer']; ['NTrials: ' int2str(size(option_info,1))]};

annotation('textbox',[0.15 0.6 0.2 0.3],'String',detail_text,...
    'FitBoxToText','on','EdgeColor',[1 1 1],'Interpreter','none');


