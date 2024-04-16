rt_trials = data_table.offer1_att_order == 1 & data_table.offer2_att_order == 1;
tr_trials = data_table.offer1_att_order == 2 & data_table.offer2_att_order == 2;

rt_trials_med_uncert = rt_trials &  ((data_table.offer1_rwd == -5 & data_table.offer2_rwd == 5) |...
    (data_table.offer1_rwd == 5 & data_table.offer2_rwd == -5));

tr_trials_med_uncert = tr_trials &  ((data_table.offer1_rwd == -5 & data_table.offer2_rwd == 5) |...
    (data_table.offer1_rwd == 5 & data_table.offer2_rwd == -5));

a = nanmean(data_table.chosen_rwd(rt_trials_med_uncert) == -5 );
b = nanmean(data_table.chosen_rwd(rt_trials_med_uncert) == 5 );

c = nanmean(data_table.chosen_rwd(tr_trials_med_uncert) == -5 );
d = nanmean(data_table.chosen_rwd(tr_trials_med_uncert) == 5 );

reward_list = [0 -5 5 10];
delay_list = [10 5 -5 0];

[p_attrib_1_chosen_rt, ~, ~, ~] = ...
    get_probability_matrix(reward_list,delay_list,data_table(rt_trials,:));

[p_attrib_1_chosen_tr, ~, ~, ~] = ...
    get_probability_matrix(reward_list,delay_list,data_table(tr_trials,:));

p_array_label = outstruct.p_array_label;
label = outstruct.label;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure
fig = figuren('Renderer', 'painters', 'Position', [100 300 1600 350]);
nsubplot(1,3,1); hold on
imAlpha=ones(size(p_attrib_1_chosen_rt));
imAlpha(isnan(p_attrib_1_chosen_rt))=0;
imagesc(p_attrib_1_chosen_rt-0.5,'AlphaData',imAlpha)
xlim([0.5 length(p_attrib_1_chosen_rt)+0.5]); ylim([0.5 length(p_attrib_1_chosen_rt)+0.5]);
xticks([1:1:length(p_attrib_1_chosen_rt)]); xticklabels(label)
yticks([1:1:length(p_attrib_1_chosen_rt)]); yticklabels(label)
set(gca,'color',0*[1 1 1],'YDir','Reverse');
xlabel('Attribute 1')
ylabel('Attribute 2')
title('Reward > Delay')

cmap = cbrewer2('RdBu');
colormap(flipud(cmap))
colorbar
axis square
axis on

nsubplot(1,3,2); hold on
imAlpha=ones(size(p_attrib_1_chosen_tr));
imAlpha(isnan(p_attrib_1_chosen_tr))=0;
imagesc(p_attrib_1_chosen_tr-0.5,'AlphaData',imAlpha)
xlim([0.5 length(p_attrib_1_chosen_tr)+0.5]); ylim([0.5 length(p_attrib_1_chosen_tr)+0.5]);
xticks([1:1:length(p_attrib_1_chosen_tr)]); xticklabels(label)
yticks([1:1:length(p_attrib_1_chosen_tr)]); yticklabels(label)
set(gca,'color',0*[1 1 1],'YDir','Reverse');
xlabel('Attribute 1')
ylabel('Attribute 2')
title('Delay > Reward')

cmap = cbrewer2('RdBu');
colormap(flipud(cmap))
colorbar
axis square
axis on

nsubplot(1,3,3); hold on
bar([a b c d])
xticklabels({'','R-D: 50% Large','R-D: 100% Medium','D-R: 50% Large','D-R: 100% Medium',''})

