
load('savedata_slayer.mat')
%load('savedata_slayerLhB.mat')
%load('savedata_sabbath.mat')

%  index = find ( [savedata(:).offer1variance] < 0.025 | [savedata(:).offer2variance] < 0.025)
%    savedata=        savedata  (index)

close all;

figuren;

nsubplot(4, 4, 1, 1); set(gca,'ticklength',2*get(gca,'ticklength'))

x=[savedata(:).ROC_reward_smallvsbigOF1]'
y=[savedata(:).ROC_punish_smallvsbigOF1]'
Px=[savedata(:).P_reward_smallvsbigOF1]'
Py=[savedata(:).P_punish_smallvsbigOF1]'
Perm=20000;
[p,rho] = permutation_pair_test_fast(x , y ,Perm,'rankcorr')
scatter(x,y,10,'k','o','filled')
axis([0 1 0 1])
text(0.7,1, ['rho=' mat2str(rho) ])
text(0.7,0.9, ['p=' mat2str(p) ])
text(0.7,0.8, ['Perm=' mat2str(Perm) ])
text(0.7,0.7, ['Offer1'])
text(0.7,0.6, ['n=' mat2str(length(x)) ])

plot([0.5 0.5],[0 1],'k-.')
plot([0 1],[0.5 0.5],'k-.')
lsline
axis square;



nsubplot(4, 4, 2, 1); set(gca,'ticklength',2*get(gca,'ticklength'))

x=[savedata(:).ROC_reward_smallvsbigOF2]'
y=[savedata(:).ROC_punish_smallvsbigOF2]'
Px=[savedata(:).P_reward_smallvsbigOF2]'
Py=[savedata(:).P_punish_smallvsbigOF2]'
Perm=20000;
[p,rho] = permutation_pair_test_fast(x , y ,Perm,'rankcorr')
scatter(x,y,10,'k','o','filled')
axis([0 1 0 1])
text(0.7,1, ['rho=' mat2str(rho) ])
text(0.7,0.9, ['p=' mat2str(p) ])
text(0.7,0.8, ['Perm=' mat2str(Perm) ])
text(0.7,0.7, ['Offer2'])
plot([0.5 0.5],[0 1],'k-.')
plot([0 1],[0.5 0.5],'k-.')
lsline
axis square;



nsubplot(4, 4, 3, 1); set(gca,'ticklength',2*get(gca,'ticklength'))

x=[savedata(:).ROC_reward_smallvsbigOFb]'
y=[savedata(:).ROC_punish_smallvsbigOFb]'
Px=[savedata(:).P_reward_smallvsbigOFb]'
Py=[savedata(:).P_punish_smallvsbigOFb]'
Perm=20000;
[p,rho] = permutation_pair_test_fast(x , y ,Perm,'rankcorr')
scatter(x,y,10,'k','o','filled')
axis([0 1 0 1])
text(0.7,1, ['rho=' mat2str(rho) ])
text(0.7,0.9, ['p=' mat2str(p) ])
text(0.7,0.8, ['Perm=' mat2str(Perm) ])
text(0.7,0.7, ['BothOffers'])
plot([0.5 0.5],[0 1],'k-.')
plot([0 1],[0.5 0.5],'k-.')
lsline
axis square;





