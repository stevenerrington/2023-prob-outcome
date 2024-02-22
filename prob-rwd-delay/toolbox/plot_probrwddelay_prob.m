function plot_probrwddelay_prob (outstruct, p_array, p_attrib_1_chosen)

p_array = nanmean(p_array);
p_attrib_1_chosen = squeeze(nanmean(p_attrib_1_chosen,1));

p_array_label = outstruct.p_array_label;
label = outstruct.label;

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




end