function gen_online_beh(PDS)

% Dependencies: gen_PDS_datatable, get_p_array, get_probability_matrix,
% figuren, nsubplot
delay_datatable = gen_PDS_datatable(PDS);

reward_list = [0 5 10];
delay_list = [10 5 0];

[p_array, p_array_label] = get_p_array(reward_list,delay_list,delay_datatable);

[p_attrib_1_chosen, sum_attrib_1_chosen, sum_attrib_1_offered, label] = ...
    get_probability_matrix(reward_list, delay_list,delay_datatable);

% [~, p_array_order] = sort(p_array); % Sort low to high
p_array_order = [1 4 7 2 5 8 3 6 9]; % for 3 (delay) x 3 (rwd) design

p_array = p_array(p_array_order);
p_array_label = p_array_label(p_array_order);

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
xticks([1:1:length(p_array)]); xticklabels(p_array_label)
xlabel('Offer attribute')
ylabel('P(trials) option selected')
axis square
axis on

subplot(1,3,3); hold on
imAlpha=ones(size(p_attrib_1_chosen([3 2 1 6 5 4 9 8 7],[3 2 1 6 5 4 9 8 7])));
imAlpha(isnan(p_attrib_1_chosen([3 2 1 6 5 4 9 8 7],[3 2 1 6 5 4 9 8 7])))=0;
imagesc(p_attrib_1_chosen([3 2 1 6 5 4 9 8 7],[3 2 1 6 5 4 9 8 7])-0.5,'AlphaData',imAlpha)
xlim([0.5 length(p_array_order)+0.5]); ylim([0.5 length(p_array_order)+0.5]);
xticks([1:1:length(p_array_order)]); xticklabels(label([3 2 1 6 5 4 9 8 7]))
yticks([1:1:length(p_array_order)]); yticklabels(label([3 2 1 6 5 4 9 8 7]))
set(gca,'color',0*[1 1 1],'YDir','Reverse');
xlabel('Attribute 1')
ylabel('Attribute 2')

%cmap = cbrewer2('RdBu');
%colormap(flipud(cmap))
colorbar
axis square
axis on