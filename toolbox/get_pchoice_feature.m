function [data_out] = get_pchoice_feature(choice_info)

rwd_punish_values = get_unique_rwdpunish(choice_info);

outcome_type = {'punish','rwd'};
measure_type = {'amt','prob'};

for option_i = 1:2
    for outcome_i = 1:2
        for measure_i = 1:2

            cond_vals = [];
            cond_vals = rwd_punish_values.(['option_' int2str(option_i)]).(outcome_type{outcome_i}).(measure_type{measure_i});

            out_val = [];
            for i = 1:length(cond_vals)
                in_val = []; in_val = cond_vals(i);
                trials = []; trials = find(choice_info.(['option' int2str(option_i) '_' outcome_type{outcome_i} '_' measure_type{measure_i}]) == in_val);
                out_val(1,i) = mean(choice_info.option_selected(trials) == 1);
                out_val(2,i) = in_val;
                out_val(3,i) = i;
            end

            choice_p_option.(['option_' int2str(option_i)]).(outcome_type{outcome_i}).(measure_type{measure_i}) = ...
                out_val;
        end
    end
end

%% Extract data by option
option_i = 2; count = 0;
clear option2_prob option2_val option2_label option2_x_val
for outcome_i = 1:2
    for measure_i = 1:2
        data_in = []; data_in = choice_p_option.(['option_' int2str(option_i)]).(outcome_type{outcome_i}).(measure_type{measure_i});

        for val_i = 1:size(data_in,2)
            count = count + 1;

            option2_prob(1,count) = data_in(1,val_i);

            switch measure_type{measure_i}
                case 'prob'
                    option2_val(1,count) = data_in(2,val_i)*100;
                case 'amt'
                    option2_val(1,count) = data_in(2,val_i)/5;
            end

            option2_label{1,count} = [outcome_type{outcome_i} '_' measure_type{measure_i} '_' int2str(option2_val(1,count))];
            option2_x_val(1,count) = count;
        end
    end
end


option_i = 1; count = 0;
clear option1_prob option1_val option1_label option1_x_val
for outcome_i = 1:2
    for measure_i = 1:2
        data_in = []; data_in = choice_p_option.(['option_' int2str(option_i)]).(outcome_type{outcome_i}).(measure_type{measure_i});

        for val_i = 1:size(data_in,2)
            count = count + 1;

            option1_prob(1,count) = data_in(1,val_i);

            switch measure_type{measure_i}
                case 'prob'
                    option1_val(1,count) = data_in(2,val_i)*100;
                case 'amt'
                    option1_val(1,count) = data_in(2,val_i)/5;
            end

            option1_label{1,count} = [outcome_type{outcome_i} '_' measure_type{measure_i} '_' int2str(option1_val(1,count))];
            option1_x_val(1,count) = count;
        end
    end
end


data_out.option1.x_val = option1_x_val;
data_out.option1.p_choice = option1_prob;
data_out.option1.label = option1_label;

data_out.option2.x_val = option2_x_val;
data_out.option2.p_choice = option2_prob;
data_out.option2.label = option2_label;






% Figure
figure('Renderer', 'painters', 'Position', [100 100 500 400]);
subplot(2,1,1)
bar(option1_x_val,option1_prob)
xticklabels(option1_label); xlabel('Option 1 Parameters')
ylim([0 1]); ylabel('P(Choose Option 2)')
set(gca,'TickLabelInterpreter','none')
hline(0.5,'k--')

subplot(2,1,2)
bar(option2_x_val,option2_prob)
xticklabels(option2_label); xlabel('Option 2 Parameters')
ylim([0 1]); ylabel('P(Choose Option 2)')
set(gca,'TickLabelInterpreter','none')
hline(0.5,'k--')
