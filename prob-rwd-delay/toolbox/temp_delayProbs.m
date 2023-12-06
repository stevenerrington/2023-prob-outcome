%% Setup and load data
clear all; clc

% Change directory to temp folder
cd('/Users/stevenerrington/Desktop/Current/delay_temp')


session_file = 'ProbRwdDelay_27_11_2023_10_49.mat';
monkey = 'Zeppelin';

% Load in example data
load(session_file)

% Slayer:
% 'ProbRwdDelay_27_11_2023_10_50'
% 'ProbRwdDelay_22_11_2023_10_18'
% 'ProbRwdDelay_21_11_2023_10_50'
% 'ProbRwdDelay_20_11_2023_10_38'

% Zeppelin
% 'ProbRwdDelay_27_11_2023_10_49'
% 'ProbRwdDelay_22_11_2023_13_13'
% 'ProbRwdDelay_22_11_2023_10_26'
% 'ProbRwdDelay_21_11_2023_10_44'
% 'ProbRwdDelay_20_11_2023_10_37'


%% Set up data structure
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



%% Get contigency matrix
% Get marginal probabilities
% > Reward
p_rwd_small = sum(delay_datatable.chosen_rwd == 0);
p_rwd_large = sum(delay_datatable.chosen_rwd == 10);

% > Delay
p_delay_short = sum(delay_datatable.chosen_delay == 0);
p_delay_long = sum(delay_datatable.chosen_delay == 10);

% Get conditional probabilties
% > Short delay, small reward
p_delay_short_rwd_small = sum(delay_datatable.chosen_rwd == 0 & delay_datatable.chosen_delay == 0);
% > Short delay, large reward
p_delay_short_rwd_large = sum(delay_datatable.chosen_rwd == 10 & delay_datatable.chosen_delay == 0);

% > Long delay, small reward
p_delay_long_rwd_small = sum(delay_datatable.chosen_rwd == 0 & delay_datatable.chosen_delay == 10);
% > Long delay, large reward
p_delay_long_rwd_large = sum(delay_datatable.chosen_rwd == 10 & delay_datatable.chosen_delay == 10);

% Uncertain reward conditions ----------------------------------------------
if sum(delay_datatable.chosen_rwd == 5) > 0 | sum(delay_datatable.chosen_delay == 5) > 0
    % > Reward
    p_rwd_mid = sum(delay_datatable.chosen_rwd == 5);
    p_delay_mid= sum(delay_datatable.chosen_delay == 5);

    % > Short delay, mid reward
    p_delay_short_rwd_mid = sum(delay_datatable.chosen_rwd == 5 & delay_datatable.chosen_delay == 0);
    % > Mid delay, short reward
    p_delay_mid_rwd_small = sum(delay_datatable.chosen_rwd == 0 & delay_datatable.chosen_delay == 5);
    % > Mid delay, mid reward
    p_delay_mid_rwd_mid = sum(delay_datatable.chosen_rwd == 5 & delay_datatable.chosen_delay == 5);
    % > Mid delay, long reward
    p_delay_mid_rwd_large = sum(delay_datatable.chosen_rwd == 10 & delay_datatable.chosen_delay == 5);
    % > Long delay, mid reward
    p_delay_long_rwd_mid = sum(delay_datatable.chosen_rwd == 5 & delay_datatable.chosen_delay == 10);
else
    p_rwd_mid = NaN;
    p_delay_mid = NaN;
    p_delay_short_rwd_mid = NaN;
    p_delay_mid_rwd_small = NaN;
    p_delay_mid_rwd_mid = NaN;
    p_delay_mid_rwd_large = NaN;
    p_delay_long_rwd_mid = NaN;
end


cont_matrix = [p_delay_short_rwd_small, p_delay_mid_rwd_small, p_delay_long_rwd_small, p_rwd_small;...
    p_delay_short_rwd_mid, p_delay_mid_rwd_mid, p_delay_long_rwd_mid,  p_rwd_mid;...
    p_delay_short_rwd_large,  p_delay_mid_rwd_large, p_delay_long_rwd_large, p_rwd_large;...
    p_delay_short, p_delay_mid, p_delay_long, NaN]./size(delay_datatable,1);

%% Display contigency matrix
% Generate figure as a heatmap
% figure;
% h = heatmap(cont_matrix.*100);
% ax = gca;
% ax.XDisplayLabels= {'Short Delay','Uncertain Delay','Long Delay',''};
% ax.YDisplayLabels= {'Small Reward','Uncertain Reward','Large Reward',''};

%% Find matched trials
% Equal reward in both options

count = 0; % Start a counter

% For each trial
for trial_i = 1:size(delay_datatable,1)

    % If the reward was equal between offer 1 and offer 2
    if (delay_datatable.offer1_rwd(trial_i) == delay_datatable.offer2_rwd(trial_i))

        count = count + 1; % Increase the count

        p_matched_smalldelay(count,1) = ...
            delay_datatable.(['offer' int2str(delay_datatable.choice(trial_i)) '_delay'])(trial_i) == 0;
        % And denote a logical flag for whether the chosen option was
        % shorter (0)

    end
end

fprintf('The smaller delay was chosen on %i percent of trials in which the reward was matched between options. \n',...
    round(mean(p_matched_smalldelay)*100))

%%

delay_list = [0 5 10];
reward_list = [0 5 10];

out_test = [];
label = {};

count_a = 0;
for delay_i = 1:length(delay_list)
    for reward_i = 1:length(reward_list)
        count_a = count_a + 1;
        count_b = 0;
        label{count_a} = ['Reward: ' int2str(reward_list(reward_i)) ' | Delay: ' int2str(delay_list(delay_i))];
        for delay_j = 1:length(delay_list)
            for reward_j = 1:length(reward_list)

                count_b = count_b + 1;


                out_test(count_b, count_a) = ...
                    sum(delay_datatable.choice(...
                    delay_datatable.offer1_rwd == reward_list(reward_i) & delay_datatable.offer1_delay == delay_list(delay_i) &...
                    delay_datatable.offer2_rwd == reward_list(reward_j) & delay_datatable.offer2_delay == delay_list(delay_j))...
                    == 1)./sum(...
                    delay_datatable.offer1_rwd == reward_list(reward_i) & delay_datatable.offer1_delay == delay_list(delay_i) &...
                    delay_datatable.offer2_rwd == reward_list(reward_j) & delay_datatable.offer2_delay == delay_list(delay_j));

                out_test(count_b, count_a) = out_test(count_b, count_a) * 100;

            end
        end
    end
end


order = [7 4 1 8 5 2 9 6 3]; % for 3 (delay) x 3 (rwd) design
% order = [5 3 1 6 4 2]; % for 2 (delay) x 3 (rwd) design
% 
% % Figure
% figure('Renderer', 'painters', 'Position', [100 300 600 500]);
% subplot(1,1,1)
% h = heatmap(out_test(order,order));
% ax = gca;
% ax.XDisplayLabels= label(order);
% ax.YDisplayLabels= label(order);
% ax.XLabel = 'Offer one attribute';
% ax.YLabel = 'Offer two attribute';

count = 0;

p_array = [];

for delay_i = 1:length(delay_list)
    for reward_i = 1:length(reward_list)
        count = count + 1;

        % Find trials with options that meet the current loop criteria (rwd
        % and delay magnitude)
        trial_index = []; trial_index = ...
            find((delay_datatable.offer1_rwd == reward_list(reward_i) & delay_datatable.offer1_delay == delay_list(delay_i)) |...
            (delay_datatable.offer2_rwd == reward_list(reward_i) & delay_datatable.offer2_delay == delay_list(delay_i)));

        % Find the probability that the option with the loop attributes was
        % selected
        p_array(count) = ...
            mean(delay_datatable.chosen_rwd(trial_index) == reward_list(reward_i) &...
            delay_datatable.chosen_delay(trial_index)  == delay_list(delay_i));


    end
end

p_array =  p_array(order);

[p_attrib_1_chosen, sum_attrib_1_chosen, sum_attrib_1_offered] = ...
    get_probability_matrix(reward_list,delay_list,delay_datatable);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure
fig = figuren('Renderer', 'painters', 'Position', [100 300 1600 350]);
subplot(1,3,1)
h = heatmap(p_array([3 2 1; 6 5 4; 9 8 7])*100);
ax = gca;
ax.XDisplayLabels= {'Short','Uncertain','Long'};
ax.YDisplayLabels= {'Small','Uncertain','Large'};
ax.XLabel = 'Delay attribute';
ax.YLabel = 'Reward attribute';

subplot(1,3,2); hold on
plot(1:length(p_array),p_array,'*-','LineWidth',2)
xlim([0 length(p_array)+1]); ylim([0 1])
xticks([1:1:length(p_array)]); xticklabels(label(order))
xlabel('Offer attribute')
ylabel('P(trials) option selected')
axis square
axis on

subplot(1,3,3); hold on
imAlpha=ones(size(p_attrib_1_chosen));
imAlpha(isnan(p_attrib_1_chosen))=0;
imagesc(p_attrib_1_chosen-0.5,'AlphaData',imAlpha)
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

set(fig,'Units','Inches');
pos = get(fig,'Position');
set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(fig,[session_file '-' monkey '-choiceP.pdf'],'-dpdf','-r0')







%%
% 
% cont_matrix = [p_delay_short_rwd_small, p_delay_mid_rwd_small, p_delay_long_rwd_small, p_rwd_small;...
%     p_delay_short_rwd_mid, p_delay_mid_rwd_mid, p_delay_long_rwd_mid,  p_rwd_mid;...
%     p_delay_short_rwd_large,  p_delay_mid_rwd_large, p_delay_long_rwd_large, p_rwd_large;...
%     p_delay_short, p_delay_mid, p_delay_long, NaN]./size(delay_datatable,1);




% X axis
% Small reward long delay
% Small reward short delay
% Uncertain reward long delay
% Uncertain reward short delay
% Control medium long
% Control medium short
% Large long
% Large short
%
% Y axis
% Same Thing as x axis
% …. Data are % of x axis variable vs Y axis variable
% 
% p_array = ...
%     [p_delay_long_rwd_small, p_delay_mid_rwd_small, p_delay_short_rwd_small,...
%     p_delay_long_rwd_large, p_delay_mid_rwd_large, p_delay_short_rwd_large];
% 
% subplot(1,2,2); hold on
% plot(1:length(p_array),p_array,'*-','LineWidth',2)
% xlim([0 length(p_array)+1]); %ylim([0 1])
% xticks([1:1:length(p_array)]); xticklabels({'Small reward | long delay', 'Small reward | uncertain delay', 'Small reward | short delay', ...
%     'Large reward | long delay', 'Large reward | uncertain delay', 'Large reward | short delay'})
% xlabel('Offer attribute')
% ylabel('P(trials) option selected')
% 
% saveas(gcf,[session_file '-' monkey '-choiceP.png']);

%%  Plot eye position
% long_delay_trials = find(delay_datatable.chosen_delay == 10);
%
% trial_i = 5;
%
% figure; hold on
% plot(PDS.onlineEye{long_delay_trials(trial_i)}(:,4) - PDS.trialstarttime(long_delay_trials(trial_i)) + PDS.timefpon(long_delay_trials(trial_i)),...
%     PDS.onlineEye{long_delay_trials(trial_i)}(:,1));
% plot(PDS.onlineEye{long_delay_trials(trial_i)}(:,4) - PDS.trialstarttime(long_delay_trials(trial_i)) + PDS.timefpon(long_delay_trials(trial_i)),...
%     PDS.onlineEye{long_delay_trials(trial_i)}(:,2))
% vline(0, 'k')
% vline(PDS.timeChoice(long_delay_trials(trial_i)), 'k')
% vline(PDS.timeChoice(long_delay_trials(trial_i)) + 1, 'k')
% vline(PDS.timeChoice(long_delay_trials(trial_i)) + 1 + 8, 'k')
%
% figure; hold on
% plot(PDS.EyeJoy{long_delay_trials(trial_i)}(5,:),...
%     PDS.EyeJoy{long_delay_trials(trial_i)}(1,:));
% plot(PDS.EyeJoy{long_delay_trials(trial_i)}(5,:),...
%     PDS.EyeJoy{long_delay_trials(trial_i)}(2,:));
