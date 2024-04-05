function outstruct = gen_online_beh(PDS)

% Dependencies: gen_PDS_datatable, get_p_array, get_probability_matrix,
% figuren, nsubplot
delay_datatable = gen_PDS_datatable(PDS);
delay_datatable = delay_datatable(100:end,:);

reward_list = [0 -5 5 10];
delay_list = [10 5 -5 0];

[p_array, p_array_label] = get_p_array(reward_list,delay_list,delay_datatable);

[p_attrib_1_chosen, ~, ~, label] = ...
    get_probability_matrix(reward_list, delay_list,delay_datatable);

% [~, p_array_order] = sort(p_array); % Sort low to high
% p_array_order = [2, 6, 14, 10, 3, 7, 15, 11, 1, 5, 13, 9, 4, 8, 16, 12]; % for 4 (delay) x 4 (rwd) design
% 
% p_array = p_array(p_array_order);
% p_array_label = p_array_label(p_array_order);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure
fig = figuren('Renderer', 'painters', 'Position', [100 300 1600 350]);
subplot(1,3,1)
h = heatmap(p_array([4 3 2 1; 8 7 6 5; 12 11 10 9; 16 15 14 13])*100);
ax = gca;
ax.XDisplayLabels= {'Short','Uncertain','Medium','Long'};
ax.YDisplayLabels= {'Small','Uncertain','Medium','Large'};
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
grid on

subplot(1,3,3); hold on
imAlpha=ones(size(p_attrib_1_chosen));
imAlpha(isnan(p_attrib_1_chosen))=0;
imagesc(p_attrib_1_chosen-0.5,'AlphaData',imAlpha)
xlim([0.5 length(p_array)+0.5]); ylim([0.5 length(p_array)+0.5]);
xticks([1:1:length(p_array)]); xticklabels(label)
yticks([1:1:length(p_array)]); yticklabels(label)
set(gca,'color',0*[1 1 1],'YDir','Reverse');
xlabel('Attribute 1')
ylabel('Attribute 2')

cmap = cbrewer2('RdBu');
colormap(flipud(cmap))
colorbar
axis square
axis on

outstruct.p_array = p_array;
outstruct.p_array_label = p_array;
outstruct.p_attrib_1_chosen = p_attrib_1_chosen;
outstruct.label = label;
outstruct.delay_datatable = delay_datatable;



