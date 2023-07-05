function plot_session_beh(choice_info,data,datafile)

feature_bar_data = dev_pchoice_feature(choice_info);
ev_bar_data = dev_pchoice_feature_ev(choice_info);
choice_trial_data = choice_ev_trial(choice_info);
cumul_outcome = trial_cumulative_rwdlaser(data.PDS);


%%
figure('Renderer', 'painters', 'Position', [100 100 1000 600]);

% Session information
dim = [0.05 0.75 0.3 0.2];
str = {[datafile]};
annotation('textbox',dim,'String',str,'FitBoxToText','on','FontSize',15,'EdgeColor','none', 'Interpreter', 'none');


% Ntrials
n_laser = sum(data.PDS.magnitude_punish > 0);
n_reward = sum(data.PDS.timereward > 0);

ntrial_bar_plot = subplot('Position',[0.5 0.6 0.2 0.2]); hold on
ntrial_bar = bar([size(choice_info,1), n_laser, n_reward]);
xticks([1:3]); xticklabels({'N_goodtrials','N_laser','N_reward'}); xtickangle( gca , 45 )
set(gca,'TickLabelInterpreter','none')
ntrial_bar.FaceColor = 'flat';

ntrial_bar.CData(1,:) = [1 1 1];
ntrial_bar.CData(2,:) = [246 0 0]./255;
ntrial_bar.CData(3,:) = [2 67 105]./255;


% Cumulative reward and laser
cumul_outcome_plot = subplot('Position',[0.75 0.6 0.2 0.2]); hold on
yyaxis left; plot(cumul_outcome.reward,'b-'); ylabel('Cumulative reward');
yyaxis right; plot(cumul_outcome.laser,'r-'); ylabel('Cumulative laser');
xlim([1 length(cumul_outcome.laser)]); xlabel('Trial')

% P(Choice) x option feature ------------------------------------------
pchoice_feature_plot = subplot('Position',[0.1 0.6 0.3 0.2]); hold on
feature_bar_plot = bar(feature_bar_data.x,feature_bar_data.y,'EdgeColor','none','BarWidth',0.75);
xticks([1:max(feature_bar_data.x)])
xticklabels({'Small Laser','Large Laser','0% Laser','50% Laser','100% Laser',...
    'Small Reward','Large Reward', '0% Reward','50% Reward','100% Reward' })
xtickangle( gca , 45 )

feature_bar_plot.FaceColor = 'flat';
feature_bar_plot.CData(6,:) = [70 106 128]./255; % Small Laster
feature_bar_plot.CData(7,:) = [1 24 38]./255; % Large Laser
feature_bar_plot.CData(8,:) = [124 204 253]./255; % 0% Laser Prob
feature_bar_plot.CData(9,:) = [4 150 239]./255; % 50% Laser Prob
feature_bar_plot.CData(10,:) = [2 67 105]./255; % 100% Laser Prob
feature_bar_plot.CData(1,:) = [200 0 0]./255; % Small Reward
feature_bar_plot.CData(2,:) = [100 0 0]./255; % Large Reward
feature_bar_plot.CData(3,:) = [255 167 167]./255; % 0% Reward Prob
feature_bar_plot.CData(4,:) = [255 79 79]./255; % 50% Reward Prob
feature_bar_plot.CData(5,:) = [246 0 0]./255; % 100% Reward Prob

box off
ylim([0 1])
xlabel('Option feature')
ylabel('P(Choosing option w/feature)')

% P(Choice) x option EV ------------------------------------------
pchoice_ev_plot = subplot('Position',[0.1 0.2 0.3 0.2]); hold on
ev_bar_plot = bar(ev_bar_data.x,ev_bar_data.y,'EdgeColor','none','BarWidth',0.75);
xticks([1:max(ev_bar_data.x)])
xticklabels(ev_bar_data.labels)
xtickangle( gca , 45 )
set(gca,'TickLabelInterpreter','none')

ev_bar_plot.FaceColor = 'flat';

for bar_i = 1:size(ev_bar_data.labels,1)
    ev_bar_plot.CData(bar_i,:) = ev_bar_data.color(bar_i,:);
end

box off; ylim([0 1]); xlabel('Option EV'); ylabel('P(Choosing option w/EV)')

% P(Choice) x time  ------------------------------------------
pchoice_time_plot = subplot('Position',[0.5 0.2 0.45 0.2]); hold on
plot(movmean(choice_trial_data.rwd_selectBigEV,15),'b-')
plot(movmean(choice_trial_data.punish_selectBigEV,15),'r-')
plot(movmean(choice_trial_data.diff_selectPosVal,15),'k-')
ylim([0 1]); xlabel('Trial Number'); ylabel('P(Choosing highest EV option)')
legend({'Reward','Punish','Overall'},'location','southeast')
