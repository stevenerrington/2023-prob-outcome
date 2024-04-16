clear all; clc

% Define monkey to analyse --------------------
monkey = 'Zepp'; % 'Zepp' or 'Slayer'

% Define file directory --------------------
mat_dir = ['/Users/stevenerrington/Desktop/ProbRwdDelay Data/' monkey '/'];
mat_files = dir_mat_files(mat_dir);

% Restructure data across multiple sessions --------------------
data_table = [];

for file_i = 1:length(mat_files)
    load(fullfile(mat_dir,mat_files{file_i}))
    clear outstruct; c;
    outstruct = gen_online_beh_multi(PDS); % Get behavior from the single file

    % Concatenate the relevant data that we want to plot
    data_table = [data_table; outstruct.datatable]; % Data table
    p_array(file_i,:) = outstruct.p_array; % P(choice) array (1)
    p_array_ind(file_i,:) = outstruct.p_array_2; % P(choice) array (1)
    p_attrib_1_chosen(file_i,:,:) = outstruct.p_attrib_1_chosen; % P(choice) array (2)
end

%% 

plot_probrwddelay_prob (outstruct, p_array, p_attrib_1_chosen)




%%  Probability plot

rwd_prob = p_array_ind(:,1:4);
delay_prob = p_array_ind(:,[8, 7, 6, 5]);
order_prob = p_array_ind(:,[9, 10]);

color_rwd = cbrewer('seq', 'Blues', 4);
color_delay = cbrewer('seq', 'Reds', 4);


figuren('Renderer', 'painters', 'Position', [100 100 900 600]);
nsubplot(2,6,[1 2]); hold on
bar_a = bar(nanmean(rwd_prob),'LineStyle','None');
er = errorbar(1:size(rwd_prob,2),nanmean(rwd_prob),sem(rwd_prob));    
er.Color = [0 0 0];        
er.LineWidth = 3;
er.LineStyle = 'none';  
xticks(1:length(rwd_prob))
xticklabels(outstruct.p_array_label2(1:4))
xlim([0 5]); ylim([0 1])

nsubplot(2,6,[3 4]);
bar(nanmean(delay_prob),'LineStyle','None')
er = errorbar(1:size(delay_prob,2),nanmean(delay_prob),sem(delay_prob));    
er.Color = [0 0 0];        
er.LineWidth = 3;
er.LineStyle = 'none';  
xticks(1:length(delay_prob))
xticklabels(outstruct.p_array_label2([8, 7, 6, 5]))
xlim([0 5]); ylim([0 1])

nsubplot(2,6,[5 6]);
bar(nanmean(order_prob),'LineStyle','None')
er = errorbar(1:size(order_prob,2),nanmean(order_prob),sem(order_prob));    
er.Color = [0 0 0];        
er.LineWidth = 3;
er.LineStyle = 'none';  
xticks(1:length(order_prob))
xticklabels({'R > D','D > R'})
xlim([0 3]); ylim([0 1])


%% GLM plot
% Run GLM --------------------
glm_out = probrwddelay_glm(data_table, 'conceptual separate for AttOrder');

% Plot GLM weights --------------------
nsubplot(2,6,[7 8]);
bar(1,glm_out.b(1),'LineStyle','None')
er = errorbar(1,glm_out.b(1),glm_out.stats.se(1));    
er.Color = [0 0 0];        
er.LineWidth = 3;
er.LineStyle = 'none';  
xticklabels({[],'Order',[]})
ylim([-1 3]); ylabel('Effect on log odds of predicted variable')
glm_out.xname

nsubplot(2,6,[9 10 11 12]);
er = errorbar(1:5,glm_out.b(2:6),glm_out.stats.se(2:6));    
er.Color = [0 0 0];        
er.LineWidth = 2;

er = errorbar(1:5,glm_out.b(8:12),glm_out.stats.se(8:12));    
er.Color = [1 0 0];        
er.LineWidth = 2;

xlim([0 6]); ylim([-1 3])
hline(0,'k')
xticks(1:5)
xticklabels({'Reward','Delay','Reward Uncertainty','Delay Uncertainty','Reward x Delay'})
yticklabels({})
legend({'Delay > Reward','Reward > Delay'})



figuren('Renderer', 'painters', 'Position', [100 100 900 600]);
eglm_plot_fit(glm_out)


%% Test
glm_out = probrwddelay_glm(data_table, 'RU test');
figuren('Renderer', 'painters', 'Position', [100 100 900 600]);
eglm_plot_fit(glm_out)









