%% Setup and load data
clear all; clc

% Change directory to temp folder
cd('/Users/stevenerrington/Desktop/Current/delay_temp')

monkey = 'Zeppelin';
clear files_in

% Define files
switch monkey
    case 'Zeppelin'
        files_in =...
            {'ProbRwdDelay_27_11_2023_10_49',...
            'ProbRwdDelay_22_11_2023_13_13',...
            'ProbRwdDelay_22_11_2023_10_26',...
            'ProbRwdDelay_21_11_2023_10_44',...
            'ProbRwdDelay_20_11_2023_10_37'};
    case 'Slayer'
        files_in =...
            {'ProbRwdDelay_27_11_2023_10_50',...
            'ProbRwdDelay_22_11_2023_10_18',...
            'ProbRwdDelay_21_11_2023_10_50',...
            'ProbRwdDelay_20_11_2023_10_38'};
end


%% Start analysis loop

n_files = length(files_in);
for file_i = 1:n_files
    session_file = files_in{file_i};
    fprintf('Analysing file: %s | %i of %i        \n', session_file, file_i, n_files)
    % Load in example data
    load(session_file)

    clear delay_datatable

    % Set up data structure %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create table
    delay_datatable = table(...
        PDS.trialnumber',... % Trial number
        PDS.goodtrial',... % Good trial flag
        PDS.offerInfo{1}.choice_rwd' ,... % Offer 1 - Reward
        PDS.offerInfo{1}.choice_delay',... % Offer 1 - Delay
        PDS.offerInfo{2}.choice_rwd',... % Offer 2 - Reward
        PDS.offerInfo{2}.choice_delay',... $ Offer 2 - Delay
        PDS.chosenwindow',... % Chosen offer
        'VariableNames',{'trialN','goodtrial','offer1_rwd','offer1_delay','offer2_rwd','offer2_delay','choice'});

    % Cut to specific trials
    trials_to_include = []; trials_to_include = 1:size(delay_datatable,1);
    delay_datatable = delay_datatable(trials_to_include,:);

    % Remove non-trials
    delay_datatable = delay_datatable(delay_datatable.goodtrial == 1,:);

    % Get a variable for the chosen option
    for trial_i = 1:size(delay_datatable,1)
        delay_datatable.chosen_rwd(trial_i) = delay_datatable.(['offer' int2str(delay_datatable.choice(trial_i)) '_rwd'])(trial_i);
        delay_datatable.chosen_delay(trial_i) = delay_datatable.(['offer' int2str(delay_datatable.choice(trial_i)) '_delay'])(trial_i);
        delay_datatable.chosen_rt(trial_i) = PDS.timeChoice(trial_i) - PDS.timetargeton(trial_i);
    end

    % Get probability matrix %%%%%%%%%%%%%%%%%%
    delay_list = [0 5 10];
    reward_list = [0 5 10];

    [p_attrib_1_chosen(:,:,file_i), sum_attrib_1_chosen(:,:,file_i), sum_attrib_1_offered(:,:,file_i)] = ...
        get_probability_matrix(reward_list,delay_list,delay_datatable);

    count = 0;

    for delay_i = 1:length(delay_list)
        for reward_i = 1:length(reward_list)
            count = count + 1;
            label{count} = ['Reward: ' int2str(reward_list(reward_i)) ' | Delay: ' int2str(delay_list(delay_i))];

            % Find trials with options that meet the current loop criteria (rwd
            % and delay magnitude)
            trial_index = []; trial_index = ...
                find((delay_datatable.offer1_rwd == reward_list(reward_i) & delay_datatable.offer1_delay == delay_list(delay_i)) |...
                (delay_datatable.offer2_rwd == reward_list(reward_i) & delay_datatable.offer2_delay == delay_list(delay_i)));

            % Find the probability that the option with the loop attributes was
            % selected
            p_array(file_i, count) = ...
                mean(delay_datatable.chosen_rwd(trial_index) == reward_list(reward_i) &...
                delay_datatable.chosen_delay(trial_index)  == delay_list(delay_i));


        end
    end

end


order = [7 4 1 8 5 2 9 6 3]; % for 3 (delay) x 3 (rwd) design


p_array_out = [];

for file_i = 1:n_files
    p_array_in = p_array(file_i, :);
    p_array_out(:,:,file_i) = p_array_in([1 4 7; 2 5 8; 3 6 9]);
end

average_p_array = nanmean(p_array);

average_p_attribute = sum(sum_attrib_1_chosen,3)./sum(sum_attrib_1_offered,3)*100;



%% Generate figure
% Figure
fig = figuren('Renderer', 'painters', 'Position', [100 300 1600 350]);
subplot(1,3,1)
h = heatmap(nanmean(p_array_out,3)*100);
ax = gca;
ax.XDisplayLabels= {'Short','Uncertain','Long'};
ax.YDisplayLabels= {'Small','Uncertain','Large'};
ax.XLabel = 'Delay attribute';
ax.YLabel = 'Reward attribute';

subplot(1,3,2); hold on
plot(1:length(average_p_array),average_p_array(order),'*-','LineWidth',2)
xlim([0 length(average_p_array)+1]); ylim([0 1])
xticks([1:1:length(average_p_array)]); xticklabels(label(order))
xlabel('Offer attribute')
ylabel('P(trials) option selected')
axis square
axis on

subplot(1,3,3); hold on
imAlpha=ones(size(average_p_attribute));
imAlpha(isnan(average_p_attribute))=0;
imagesc(average_p_attribute-50,'AlphaData',imAlpha)
xlim([0.5 length(order)+0.5]); ylim([0.5 length(order)+0.5]);
xticks([1:1:length(order)]); xticklabels(label(order))
yticks([1:1:length(order)]); yticklabels(label(order))
set(gca,'color',0*[1 1 1],'YDir','Reverse');
xlabel('Attribute 1')
ylabel('Attribute 2')

cmap = cbrewer2('RdBu');
colormap(flipud(cmap))
colorbar
axis square
axis on

% Output
set(fig,'Units','Inches');
pos = get(fig,'Position');
set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(fig,[session_file '-' monkey '-choiceP-multi.pdf'],'-dpdf','-r0')




