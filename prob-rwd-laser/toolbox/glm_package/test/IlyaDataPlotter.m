%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Ethan
%
% a few points: could you read them and address. it likely will take 30
% mins.

%i decidded to leave in the complex proportion plot of SV
% cells. could you actually test which squares are sig

%i have revised according to your comments, but i also want to show per SV
%cells that are R and P ( i put them on second row of bar plots)

%i want to show correlations at 2 diffrent thresholds in paper. it will add
%meat and be more convincing. i did this now

%i have added code to compare correlations for offer 1 vs 2; search for
%"CorrCompare" in this file; is my code too strict?????????



addpath('/Users/Ilya/Dropbox/HELPER/HELPER_GENERAL/');

LoadedAlready=1;

if LoadedAlready==2
    clear all; close all;
    load combinedneuronsOFC.mat; s=savedata;
else
    close all;
    %     try
    %          s=savedata;
    %     end
    savedata=s
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SDFplot=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PV=0.05;
PV1=0.05;
PV2=0.001;
% PV=0.001;
% PV1=0.001;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if SDFplot==1
    
    x=[savedata(:).ROC_reward_smallvsbigOF1]'
    p=find(x>0.5)
    n=find(x<0.5)
    
    x=[savedata(:).P_reward_smallvsbigOF1]'
    S=find(x<PV)
    
    %     p=intersect(p,S)
    %     n=intersect(n,S)
    
    SDF_LR1p=vertcat ( savedata(p).SDF_LR1 );
    SDF_SR1p=vertcat ( savedata(p).SDF_SR1 );
    SDF_LP1p=vertcat ( savedata(p).SDF_LP1 );
    SDF_SP1p=vertcat ( savedata(p).SDF_SP1 );
    
    SDF_LR2p=vertcat ( savedata(p).SDF_LR2 );
    SDF_SR2p=vertcat ( savedata(p).SDF_SR2 );
    SDF_LP2p=vertcat ( savedata(p).SDF_LP2 );
    SDF_SP2p=vertcat ( savedata(p).SDF_SP2 );
    %%
    %%
    SDF_LR1n=vertcat ( savedata(n).SDF_LR1 );
    SDF_SR1n=vertcat ( savedata(n).SDF_SR1 );
    SDF_LP1n=vertcat ( savedata(n).SDF_LP1 );
    SDF_SP1n=vertcat ( savedata(n).SDF_SP1 );
    
    SDF_LR2n=vertcat ( savedata(n).SDF_LR2 );
    SDF_SR2n=vertcat ( savedata(n).SDF_SR2 );
    SDF_LP2n=vertcat ( savedata(n).SDF_LP2 );
    SDF_SP2n=vertcat ( savedata(n).SDF_SP2 );
    %%
    %%
    wind=[100:600];
    
    figuren;
    
    nsubplot(2, 1, 1, 1); set(gca,'ticklength',2*get(gca,'ticklength'))
    s1=[SDF_SR1n; SDF_LR1p];
    s2=[SDF_LR1n; SDF_SR1p];
    plot(wind,nanmean(s1(:,wind)),'r','LineWidth',2);
    plot(wind,nanmean(s2(:,wind)),'b','LineWidth',2);
    
    
    nsubplot(2, 1, 2, 1); set(gca,'ticklength',2*get(gca,'ticklength'))
    s1=[SDF_SP1n; SDF_LP1p];
    s2=[SDF_LP1n; SDF_SP1p];
    plot(wind,nanmean(s1(:,wind)),'r','LineWidth',2);
    plot(wind,nanmean(s2(:,wind)),'b','LineWidth',2);
    
    x=[savedata(:).ROC_reward_smallvsbigOF2]'
    p=find(x>0.5)
    n=find(x<0.5)
    
    x=[savedata(:).P_reward_smallvsbigOF2]'
    S=find(x<PV)
    
    p=intersect(p,S)
    n=intersect(n,S)
    
    SDF_LR1p=vertcat ( savedata(p).SDF_LR1 );
    SDF_SR1p=vertcat ( savedata(p).SDF_SR1 );
    SDF_LP1p=vertcat ( savedata(p).SDF_LP1 );
    SDF_SP1p=vertcat ( savedata(p).SDF_SP1 );
    
    SDF_LR2p=vertcat ( savedata(p).SDF_LR2 );
    SDF_SR2p=vertcat ( savedata(p).SDF_SR2 );
    SDF_LP2p=vertcat ( savedata(p).SDF_LP2 );
    SDF_SP2p=vertcat ( savedata(p).SDF_SP2 );
    %%
    %%
    SDF_LR1n=vertcat ( savedata(n).SDF_LR1 );
    SDF_SR1n=vertcat ( savedata(n).SDF_SR1 );
    SDF_LP1n=vertcat ( savedata(n).SDF_LP1 );
    SDF_SP1n=vertcat ( savedata(n).SDF_SP1 );
    
    SDF_LR2n=vertcat ( savedata(n).SDF_LR2 );
    SDF_SR2n=vertcat ( savedata(n).SDF_SR2 );
    SDF_LP2n=vertcat ( savedata(n).SDF_LP2 );
    SDF_SP2n=vertcat ( savedata(n).SDF_SP2 );
    %%
    wind=[100:600];
    %%
    nsubplot(2, 1, 1, 1); set(gca,'ticklength',2*get(gca,'ticklength'))
    s1=[SDF_SR2n; SDF_LR2p];
    s2=[SDF_LR2n; SDF_SR2p];
    plot(wind+600,nanmean(s1(:,wind)),'r','LineWidth',2);
    plot(wind+600,nanmean(s2(:,wind)),'b','LineWidth',2);
    
    nsubplot(2, 1, 2, 1); set(gca,'ticklength',2*get(gca,'ticklength'))
    s1=[SDF_SP2n; SDF_LP2p];
    s2=[SDF_LP2n; SDF_SP2p];
    plot(wind+600,nanmean(s1(:,wind)),'b','LineWidth',2);
    plot(wind+600,nanmean(s2(:,wind)),'r','LineWidth',2);
    xlabel('Time (milliseconds)')
end



set(gcf,'Position',[1 41 2560 1484],'Paperposition',[0 0 26.6667 15.4583], 'Paperpositionmode','auto','Papersize',[26.6667 15.4583]);  % sets the size of the figure and orientation
print('-dpdf', 'popEx1' );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CorOf1=[];
CorOf2=[];
CorAve=[];
Weights=[];
PWeights=[];
PWeightsOF1=[];
PWeightsOF2=[];
model=2;

for neuron = 1 : length(savedata)
    neuron
    temp=savedata(neuron).sva_bigbehavvalues.model.analysis{ model }.neural_corr_with_sv.rho(: , 1 )';
    CorOf1=[CorOf1; temp]; clear temp;
    
    temp=savedata(neuron).sva_bigbehavvalues.model.analysis{ model }.neural_corr_with_sv.rho(: , 2 )';
    CorOf2=[CorOf2; temp]; clear temp;
    
    temp=[savedata(neuron).sva_bigbehavvalues.model.analysis{ model }.neural_corr_with_sv.rho(: , 2 )';
        savedata(neuron).sva_bigbehavvalues.model.analysis{ model }.neural_corr_with_sv.rho(: , 1 )';]
    CorAve=[CorAve; nanmean(temp)]; clear temp;
    
    %     temp=[savedata(neuron).sva_bigbehavvalues.model.analysis{ model }.neural_corr_with_sv.rho(: , 2 )';
    %         savedata(neuron).sva_bigbehavvalues.model.analysis{ model }.neural_corr_with_sv.rho(: , 1 )';]
    %     CorAve=[CorAve; nanmean(temp.^2)]; clear temp;
    
    %     temp=[savedata(neuron).sva_bigbehavvalues.model.analysis{ model }.neural_corr_with_sv.r(: , 2 )';
    %         savedata(neuron).sva_bigbehavvalues.model.analysis{ model }.neural_corr_with_sv.r(: , 1 )';]
    %     CorAve=[CorAve; nanmean(temp.^2)]; clear temp;
    
    offer =1
    rew= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{1,offer}.stats.beta(1);
    pun= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{1,offer}.stats.beta(2);
    tot= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{2,offer}.stats.beta(1);
    
    offer =2
    rew1= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{1,offer}.stats.beta(1);
    pun1= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{1,offer}.stats.beta(2);
    tot1= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{2,offer}.stats.beta(1);
    
    rew=nanmean([rew rew1]);
    pun=nanmean([pun pun1]);
    tot=nanmean([tot tot1]);
    
    Weights=[Weights; rew pun tot]; clear rew pun tot;
    
    offer =1
    rew= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{1,offer}.stats.p(1);
    pun= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{1,offer}.stats.p(2);
    tot= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{2,offer}.stats.p(1);
    
    offer =2
    rew1= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{1,offer}.stats.p(1);
    pun1= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{1,offer}.stats.p(2);
    tot1= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{2,offer}.stats.p(1);
    
    PWeightsOF1=[PWeightsOF1; rew pun tot];
    PWeightsOF2=[PWeightsOF2; rew1 pun1 tot1];
    
    rew=combine_pvalues([rew rew1]);
    pun=combine_pvalues([pun pun1]);
    tot=combine_pvalues([tot tot1]);
    
    PWeights=[PWeights; rew pun tot];
    
    clear rew pun tot offer rew1 pun1 tot1;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% figuren;
%
% nsubplot(2, 1, 1, 1); set(gca,'ticklength',2*get(gca,'ticklength'))
%
% data=CorAve;
% %data=CorOf1;
% Rew=data(:,1);
% Pun=data(:,2);
% Value=data(:,3);
%
% % Rew(find(Value<-1))=Rew(find(Value<-1))*-1
% % Pun(find(Value<-1))=Pun(find(Value<-1))*-1
% % Value(find(Value<-1))=Value(find(Value<-1))*-1
%
% % Value(find(Rew<-1))=Value(find(Rew<-1))*-1
% % Rew(find(Rew<-1))=Rew(find(Rew<-1))*-1
% % Pun(find(Rew<-1))=Pun(find(Rew<-1))*-1
%
% h1=histogram(Value-Rew, 'EdgeColor','k','FaceColor','w');
% h1.BinWidth = 0.005;
% signrank(Value-Rew)
% title(mat2str(nanmedian(Value-Rew)))
% text(0,10,mat2str(signrank(Value-Rew)))
% plot([0 0],[0 120],'k-.','LineWidth',2)
% scatter(mean(Value-Rew),120,'v','o','filled')
% xlabel('Subjective value versus reward value (rho diff)')
%
% nsubplot(2, 1, 2, 1); set(gca,'ticklength',2*get(gca,'ticklength'))
%
% data=Weights;
% Rew=data(:,1);
% Pun=data(:,2);
% Value=data(:,3);
%
% h1=histogram(Value-Rew, 'EdgeColor','k','FaceColor','w');
% h1.BinWidth = 0.005;
% signrank(Value-Rew)
% title(mat2str(nanmedian(Value-Rew)))
% text(0,10,mat2str(signrank(Value-Rew)))
% plot([0 0],[0 120],'k-.','LineWidth',2)
% scatter(mean(Value-Rew),120,'v','o','filled')
% xlabel('Subjective value versus reward value (weights diff)')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figuren;

nsubplot(4, 1, 1, 1); set(gca,'ticklength',2*get(gca,'ticklength'))

Perc=100*(sum(PWeights<PV1) ./  size(PWeights,1))
Tots=(sum(PWeights<PV1))


loc=1;
T = (Tots(1));
nTotalChosen = size(PWeights,1);
bar(1, [T/nTotalChosen], 'FaceColor', 'w')
[phat pci_nov] = binofit(T, nTotalChosen); % errorbars are 95% conf interval for binomial distribution
err_low = [T/nTotalChosen - pci_nov(1)];
err_hi = [pci_nov(2) - T/nTotalChosen ];
errorbar(1, [T/nTotalChosen],...
    err_low, err_hi, 'LineStyle', 'none')
prt=[mat2str(T) ' / ' mat2str(nTotalChosen)];
text(loc-0.25, T/nTotalChosen+0.05, prt);
%
p=myBinomTest(T,nTotalChosen,PV1,'Greater');
text(loc-0.25, T/nTotalChosen+0.13, ['p= ' mat2str(p)]);

%%
%%

loc=3;
T = (Tots(2));
nTotalChosen = size(PWeights,1);
bar(loc, [T/nTotalChosen], 'FaceColor', 'w')
[phat pci_nov] = binofit(T, nTotalChosen); % errorbars are 95% conf interval for binomial distribution
err_low = [T/nTotalChosen - pci_nov(1)];
err_hi = [pci_nov(2) - T/nTotalChosen ];
errorbar(loc, [T/nTotalChosen],...
    err_low, err_hi, 'LineStyle', 'none')
prt=[mat2str(T) ' / ' mat2str(nTotalChosen)];
text(loc-0.25, T/nTotalChosen+0.05, prt);
%
p=myBinomTest(T,nTotalChosen,PV1,'Greater');

text(loc-0.25, T/nTotalChosen+0.13, ['p= ' mat2str(p)]);

%%
%%

loc=5;
T = (Tots(3));
nTotalChosen = size(PWeights,1);
bar(loc, [T/nTotalChosen], 'FaceColor', 'w')
[phat pci_nov] = binofit(T, nTotalChosen); % errorbars are 95% conf interval for binomial distribution
err_low = [T/nTotalChosen - pci_nov(1)];
err_hi = [pci_nov(2) - T/nTotalChosen ];
errorbar(loc, [T/nTotalChosen],...
    err_low, err_hi, 'LineStyle', 'none')
prt=[mat2str(T) ' / ' mat2str(nTotalChosen)];
text(loc-0.25, T/nTotalChosen+0.05, prt);

%
p=myBinomTest(T,nTotalChosen,PV1,'Greater');

text(loc-0.25, T/nTotalChosen+0.13, ['p= ' mat2str(p)]);

%%
%%


R=find(PWeights(:,1)<PV1);
P=find(PWeights(:,2)<PV1);
SV=find(PWeights(:,3)<PV1);
RinSV=length(intersect(R,SV))./length(R)*100;
PinSV=length(intersect(P,SV))./length(P)*100;

RinP=length(intersect(R,P))./length(R)*100;
PinR=length(intersect(P,R))./length(P)*100;
%
p=myBinomTest(T,nTotalChosen,PV1,'Greater');

text(loc-0.25, T/nTotalChosen+0.13, ['p= ' mat2str(p)]);

%%
%%

loc=8;
T = length(intersect(R,P));
nTotalChosen = length(R);
bar(loc, [T/nTotalChosen], 'FaceColor', 'w')
[phat pci_nov] = binofit(T, nTotalChosen); % errorbars are 95% conf interval for binomial distribution
err_low = [T/nTotalChosen - pci_nov(1)];
err_hi = [pci_nov(2) - T/nTotalChosen ];
errorbar(loc, [T/nTotalChosen],...
    err_low, err_hi, 'LineStyle', 'none')
prt=[mat2str(T) ' / ' mat2str(nTotalChosen)];
text(loc-0.25, T/nTotalChosen+0.05, prt);
%
p=myBinomTest(T,nTotalChosen,PV1,'Greater');

text(loc-0.25, T/nTotalChosen+0.13, ['p= ' mat2str(p)]);

%%
%%

loc=9;
T = length(intersect(P,R));
nTotalChosen = length(P);
bar(loc, [T/nTotalChosen], 'FaceColor', 'w')
[phat pci_nov] = binofit(T, nTotalChosen); % errorbars are 95% conf interval for binomial distribution
err_low = [T/nTotalChosen - pci_nov(1)];
err_hi = [pci_nov(2) - T/nTotalChosen ];
errorbar(loc, [T/nTotalChosen],...
    err_low, err_hi, 'LineStyle', 'none')
prt=[mat2str(T) ' / ' mat2str(nTotalChosen)];
text(loc-0.25, T/nTotalChosen+0.05, prt);
%
p=myBinomTest(T,nTotalChosen,PV1,'Greater');

text(loc-0.25, T/nTotalChosen+0.13, ['p= ' mat2str(p)]);

%%
%%

%line([0 10],[0.05 0.05],'Color',[0 0 0],'LineWidth',1);
xlim([0 10]);

xticks([ 1 3 5 8 9 ])
set(gca,'XTickLabel',{'% reward (R)'; '% punishment (P)'; '% subjective value (SV)'; '% R that are also P'; '% P that are also R';});
xtickangle(45)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nsubplot(4, 1, 2, 1); set(gca,'ticklength',2*get(gca,'ticklength'))

% Perc=100*(sum(PWeightsOF1<PV1) ./  size(PWeightsOF1,1))
% Tots=(sum(PWeightsOF1<PV1))
%
% loc=1;
% bar(loc,Perc(1),'w');
% prt=[mat2str(Tots(1)) ' / ' mat2str(size(PWeightsOF1,1))];
% text(loc-0.25, Perc(1)+5, prt);
%
% loc=2;
% bar(loc,Perc(2),'w');
% prt=[mat2str(Tots(2)) ' / ' mat2str(size(PWeightsOF1,1))];
% text(loc-0.25, Perc(2)+5, prt);
%
% loc=3;
% bar(loc,Perc(3),'w');
% prt=[mat2str(Tots(3)) ' / ' mat2str(size(PWeightsOF1,1))];
% text(loc-0.25, Perc(3)+5, prt);

R=find(PWeights(:,1)<PV1);
P=find(PWeights(:,2)<PV1);
SV=find(PWeights(:,3)<PV1);
RinSV=length(intersect(R,SV))./length(R)*100;
PinSV=length(intersect(P,SV))./length(P)*100;

loc=6;
T = length(intersect(R,SV));
nTotalChosen = length(SV);
bar(loc, [T/nTotalChosen], 'FaceColor', 'w')
[phat pci_nov] = binofit(T, nTotalChosen); % errorbars are 95% conf interval for binomial distribution
err_low = [T/nTotalChosen - pci_nov(1)];
err_hi = [pci_nov(2) - T/nTotalChosen ];
errorbar(loc, [T/nTotalChosen],...
    err_low, err_hi, 'LineStyle', 'none')
prt=[mat2str(T) ' / ' mat2str(nTotalChosen)];
text(loc-0.25, T/nTotalChosen+0.05, prt);
%
p=myBinomTest(T,nTotalChosen,PV1,'Greater');

text(loc-0.25, T/nTotalChosen+0.13, ['p= ' mat2str(p)]);

%%
loc=7;
T = length(intersect(P,SV));
nTotalChosen = length(SV);
bar(loc, [T/nTotalChosen], 'FaceColor', 'w')
[phat pci_nov] = binofit(T, nTotalChosen); % errorbars are 95% conf interval for binomial distribution
err_low = [T/nTotalChosen - pci_nov(1)];
err_hi = [pci_nov(2) - T/nTotalChosen ];
errorbar(loc, [T/nTotalChosen],...
    err_low, err_hi, 'LineStyle', 'none')
prt=[mat2str(T) ' / ' mat2str(nTotalChosen)];
text(loc-0.25, T/nTotalChosen+0.05, prt);
%
p=myBinomTest(T,nTotalChosen,PV1,'Greater');

text(loc-0.25, T/nTotalChosen+0.13, ['p= ' mat2str(p)]);

%%
%%
%line([0 8],[0.05 0.05],'Color',[0 0 0],'LineWidth',1);
xlim([0 8]);
xticks([ 6 7 ])
set(gca,'XTickLabel',{ '% R that are also SV'; '% P that are also SV';});
xtickangle(45)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% nsubplot(4, 1, 3, 1); set(gca,'ticklength',2*get(gca,'ticklength'))
%
% Perc=100*(sum(PWeightsOF2<PV1) ./  size(PWeightsOF2,1))
% Tots=(sum(PWeightsOF2<PV1))
%
% loc=1;
% bar(loc,Perc(1),'w');
% prt=[mat2str(Tots(1)) ' / ' mat2str(size(PWeightsOF2,1))];
% text(loc-0.25, Perc(1)+5, prt);
%
% loc=2;
% bar(loc,Perc(2),'w');
% prt=[mat2str(Tots(2)) ' / ' mat2str(size(PWeightsOF2,1))];
% text(loc-0.25, Perc(2)+5, prt);
%
% loc=3;
% bar(loc,Perc(3),'w');
% prt=[mat2str(Tots(3)) ' / ' mat2str(size(PWeightsOF2,1))];
% text(loc-0.25, Perc(3)+5, prt);
%
%
% R=find(PWeightsOF2(:,1)<PV1);
% P=find(PWeightsOF2(:,2)<PV1);
% SV=find(PWeightsOF2(:,3)<PV1);
% RinSV=length(intersect(R,SV))./length(R)*100;
% PinSV=length(intersect(P,SV))./length(P)*100;
%
% loc=6;
% bar(loc,RinSV,'w');
% prt=[mat2str(length(intersect(R,SV))) ' / ' mat2str(length(R))];
% text(loc-0.25, RinSV+5, prt);
%
% loc=7;
% bar(loc,PinSV,'w');
% prt=[mat2str(length(intersect(P,SV))) ' / ' mat2str(length(P))];
% text(loc-0.25, PinSV+5, prt);
%
% line([0 8],[5 5],'Color',[0 0 0],'LineWidth',1);
% xlim([0 8]);
%
% xticks([ 1 2 3 6 7 ])
% set(gca,'XTickLabel',{'% reward (R)'; '% punishment (P)'; '% subjective value (SV)'; '% R that are also SV'; '% P that are also SV';});
% xtickangle(45)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nsubplot(4, 1, 4, 1); set(gca,'ticklength',2*get(gca,'ticklength'))

PWeights_=PWeights(find(PWeights(:,3)<PV1),:)

R=find(PWeights_(:,1)<PV1);
P=find(PWeights_(:,2)<PV1);
SV=find(PWeights_(:,3)<PV1);

NR=find(PWeights_(:,1)>=PV1);
NP=find(PWeights_(:,2)>=PV1);
NSV=find(PWeights_(:,3)>=PV1);

cl1=[
    length(intersect(R,P))
    length(intersect(R,NP))
    ];

cl2=[
    length(intersect(P,NR))
    length(intersect(NP,NR))
    ];

matrix=([cl1 cl2 ]./size(PWeights_,1))*100

heatmaptext(flipud(round(matrix)))
caxis([0 87])
colormap('bone')
axis square
axis on

xticks([ 1 2  ])
set(gca,'XTickLabel',{'reward (R)'; 'not R';});
xtickangle(45)

yticks([ 1 2  ])
set(gca,'YTickLabel',{ 'not P'; 'Punishment (P)';});
ytickangle(45)

text (1,3,['subjective value neurons =' mat2str(size(PWeights_,1))])

set(gcf,'Position',[1 41 2560 1484],'Paperposition',[0 0 26.6667 15.4583], 'Paperpositionmode','auto','Papersize',[26.6667 15.4583]);  % sets the size of the figure and orientation
print('-dpdf', 'popEx2' );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

savedata_=savedata(find(PWeights(:,2)<PV))
x=[savedata_(:).ROC_reward_smallvsbigOF2]'-0.5
y=[savedata_(:).ROC_punish_smallvsbigOF2]'-0.5
x(find(y>0))=x(find(y>0))*-1

savedata_=savedata(find(PWeights(:,1)<PV))
x=[savedata_(:).ROC_reward_smallvsbigOF2]'-0.5
y=[savedata_(:).ROC_punish_smallvsbigOF2]'-0.5
mean(y(find(x>0)))
signrank(y(find(x>0)))
mean(y(find(x<0)))
signrank(y(find(x<0)))

savedata_=savedata(find(PWeights(:,1)<PV & PWeights(:,2)<PV))
x=[savedata_(:).ROC_reward_smallvsbigOF2]'-0.5
y=[savedata_(:).ROC_punish_smallvsbigOF2]'-0.5
y(find(x<0))=y(find(x<0))*-1

% % % CorOf1=[]; CorOf2=[]; CorAve=[];
% % % for neuron = 1 : length(savedata_)
% % %     temp=savedata_(neuron).sva_bigbehavvalues.model.analysis{ model }.neural_corr_with_sv.rho(: , 1 )';
% % %     CorOf1=[CorOf1; temp]; clear temp;
% % %
% % %     temp=savedata_(neuron).sva_bigbehavvalues.model.analysis{ model }.neural_corr_with_sv.rho(: , 2 )';
% % %     CorOf2=[CorOf2; temp]; clear temp;
% % %
% % %     temp=[savedata_(neuron).sva_bigbehavvalues.model.analysis{ model }.neural_corr_with_sv.rho(: , 2 )';
% % %         savedata_(neuron).sva_bigbehavvalues.model.analysis{ model }.neural_corr_with_sv.rho(: , 1 )';]
% % %     CorAve=[CorAve; nanmean(temp)]; clear temp;
% % %
% % % end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

savedata_=savedata(find(PWeights(:,1)<PV))

figuren;

nsubplot(4, 1, 1, 1); set(gca,'ticklength',2*get(gca,'ticklength'))

x=[savedata_(:).ROC_reward_smallvsbigOF2]'
y=[savedata_(:).ROC_punish_smallvsbigOF2]'
Perm=20000;
[p,rho] = permutation_pair_test_fast(x , y ,Perm,'rankcorr')
scatter(x,y,10,'k','o','filled')
axis([0 1 0 1])
text(0.7,1, ['rho=' mat2str(rho) ])
text(0.7,0.9, ['p=' mat2str(p) ])
text(0.7,0.8, ['Perm=' mat2str(Perm) ])
text(0.7,0.7, ['Offer2'])
text(0.7,0.6, ['n=' mat2str(length(x)) ])
plot([0.5 0.5],[0 1],'k-.')
plot([0 1],[0.5 0.5],'k-.')
lsline
axis square

a=x;
b=y;

nsubplot(4, 1, 2, 1); set(gca,'ticklength',2*get(gca,'ticklength'))

x=[savedata_(:).ROC_reward_smallvsbigOF1]'
y=[savedata_(:).ROC_punish_smallvsbigOF1]'
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
axis square

c=x;
d=y;

%%
CorrCompare %%this uses inputs a,b for cor1, and c,d for cor2. the file is in the directory
text(1,0, ['compare cor of1 and of 2. p=' mat2str(pvalue)])
%%


nsubplot(4, 1, 3, 1); set(gca,'ticklength',2*get(gca,'ticklength'))

x=[savedata_(:).ROC_reward_smallvsbigOFb]'
y=[savedata_(:).ROC_punish_smallvsbigOFb]'
Px=[savedata_(:).P_reward_smallvsbigOFb]'
Py=[savedata_(:).P_punish_smallvsbigOFb]'
Perm=20000;
[p,rho] = permutation_pair_test_fast(x , y ,Perm,'rankcorr')
scatter(x,y,10,'k','o','filled')
axis([0 1 0 1])
text(0.7,1, ['rho=' mat2str(rho) ])
text(0.7,0.9, ['p=' mat2str(p) ])
text(0.7,0.8, ['Perm=' mat2str(Perm) ])
text(0.7,0.7, ['BothOffers'])
text(0.7,0.6, ['n=' mat2str(length(x)) ])

plot([0.5 0.5],[0 1],'k-.')
plot([0 1],[0.5 0.5],'k-.')
lsline
axis square

set(gcf,'Position',[1 41 2560 1484],'Paperposition',[0 0 26.6667 15.4583], 'Paperpositionmode','auto','Papersize',[26.6667 15.4583]);  % sets the size of the figure and orientation
print('-dpdf', 'popEx4' );



savedata_=savedata(find(PWeights(:,1)<PV2))

figuren;

nsubplot(4, 1, 1, 1); set(gca,'ticklength',2*get(gca,'ticklength'))

x=[savedata_(:).ROC_reward_smallvsbigOF2]'
y=[savedata_(:).ROC_punish_smallvsbigOF2]'
Perm=20000;
[p,rho] = permutation_pair_test_fast(x , y ,Perm,'rankcorr')
scatter(x,y,10,'k','o','filled')
axis([0 1 0 1])
text(0.7,1, ['rho=' mat2str(rho) ])
text(0.7,0.9, ['p=' mat2str(p) ])
text(0.7,0.8, ['Perm=' mat2str(Perm) ])
text(0.7,0.7, ['Offer2'])
text(0.7,0.6, ['n=' mat2str(length(x)) ])
plot([0.5 0.5],[0 1],'k-.')
plot([0 1],[0.5 0.5],'k-.')
lsline
axis square
a=x;
b=y;

nsubplot(4, 1, 2, 1); set(gca,'ticklength',2*get(gca,'ticklength'))

x=[savedata_(:).ROC_reward_smallvsbigOF1]'
y=[savedata_(:).ROC_punish_smallvsbigOF1]'
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
axis square
c=x;
d=y;

%%
CorrCompare
text(1,0, ['compare cor of1 and of 2. p=' mat2str(pvalue)])
%%

nsubplot(4, 1, 3, 1); set(gca,'ticklength',2*get(gca,'ticklength'))

x=[savedata_(:).ROC_reward_smallvsbigOFb]'
y=[savedata_(:).ROC_punish_smallvsbigOFb]'
Px=[savedata_(:).P_reward_smallvsbigOFb]'
Py=[savedata_(:).P_punish_smallvsbigOFb]'
Perm=20000;
[p,rho] = permutation_pair_test_fast(x , y ,Perm,'rankcorr')
scatter(x,y,10,'k','o','filled')
axis([0 1 0 1])
text(0.7,1, ['rho=' mat2str(rho) ])
text(0.7,0.9, ['p=' mat2str(p) ])
text(0.7,0.8, ['Perm=' mat2str(Perm) ])
text(0.7,0.7, ['BothOffers'])
text(0.7,0.6, ['n=' mat2str(length(x)) ])

plot([0.5 0.5],[0 1],'k-.')
plot([0 1],[0.5 0.5],'k-.')
lsline
axis square


set(gcf,'Position',[1 41 2560 1484],'Paperposition',[0 0 26.6667 15.4583], 'Paperpositionmode','auto','Papersize',[26.6667 15.4583]);  % sets the size of the figure and orientation
print('-dpdf', 'popEx3' );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%









asdfdsa
CorOf1=[];
CorOf2=[];
CorAve=[];
Weights=[];
PWeights=[];
model=2;

for neuron = 1 : length(savedata)
    neuron
    temp=savedata(neuron).sva_bigbehavvalues.model.analysis{ model }.neural_corr_with_sv.rho(: , 1 )';
    CorOf1=[CorOf1; temp]; clear temp;
    
    temp=savedata(neuron).sva_bigbehavvalues.model.analysis{ model }.neural_corr_with_sv.rho(: , 2 )';
    CorOf2=[CorOf2; temp]; clear temp;
    
    temp=[savedata(neuron).sva_bigbehavvalues.model.analysis{ model }.neural_corr_with_sv.rho(: , 2 )';
        savedata(neuron).sva_bigbehavvalues.model.analysis{ model }.neural_corr_with_sv.rho(: , 1 )';]
    CorAve=[CorAve; nanmean(temp)]; clear temp;
    
    offer =1
    rew= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{1,offer}.stats.beta(1);
    pun= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{1,offer}.stats.beta(2);
    tot= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{2,offer}.stats.beta(1);
    
    offer =2
    rew1= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{1,offer}.stats.beta(1);
    pun1= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{1,offer}.stats.beta(2);
    tot1= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{2,offer}.stats.beta(1);
    
    rew=nanmean([rew rew1]);
    pun=nanmean([pun pun1]);
    tot=nanmean([tot tot1]);
    
    Weights=[Weights; rew pun tot]; clear rew pun tot;
    
    offer =1
    rew= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{1,offer}.stats.p(1);
    pun= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{1,offer}.stats.p(2);
    tot= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{2,offer}.stats.p(1);
    
    offer =2
    rew1= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{1,offer}.stats.p(1);
    pun1= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{1,offer}.stats.p(2);
    tot1= savedata(neuron).sva_bigbehavvalues.model.analysis{model}.neural_value_fit.fit{2,offer}.stats.p(1);
    
    rew=combine_pvalues([rew rew1]);
    pun=combine_pvalues([pun pun1]);
    tot=combine_pvalues([tot tot1]);
    
    PWeights=[PWeights; rew pun tot]; clear rew pun tot;
    
    
    clear offer
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% figuren;
%
% nsubplot(2, 1, 1, 1); set(gca,'ticklength',2*get(gca,'ticklength'))
%
% data=CorAve;
% %data=CorOf2;
% Rew=data(:,1);
% Pun=data(:,2);
% Value=data(:,3);
%
% h1=histogram(Value-Rew, 'EdgeColor','k','FaceColor','w');
% h1.BinWidth = 0.01;
% signrank(Value-Rew)
% title(mat2str(median(Value-Rew)))
% text(0,10,mat2str(signrank(Value-Rew)))
% plot([0 0],[0 120],'k-.','LineWidth',2)
% scatter(mean(Value-Rew),120,'v','o','filled')
% xlabel('Subjective value versus reward value (rho diff)')
%
% nsubplot(2, 1, 2, 1); set(gca,'ticklength',2*get(gca,'ticklength'))
%
% data=Weights;
% Rew=data(:,1);
% Pun=data(:,2);
% Value=data(:,3);
%
% h1=histogram(Value-Rew, 'EdgeColor','k','FaceColor','w');
% h1.BinWidth = 0.005;
% signrank(Value-Rew)
% title(mat2str(nanmedian(Value-Rew)))
% text(0,10,mat2str(signrank(Value-Rew)))
% plot([0 0],[0 120],'k-.','LineWidth',2)
% scatter(mean(Value-Rew),120,'v','o','filled')
% xlabel('Subjective value versus reward value (weights diff)')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if SDFplot==1
    
    x=[savedata(:).ROC_reward_smallvsbigOF1]'
    p=find(x>0.5)
    n=find(x<0.5)
    
    x=[savedata(:).P_reward_smallvsbigOF1]'
    S=find(x<PV1)
    
    %     p=intersect(p,S)
    %     n=intersect(n,S)
    
    SDF_LR1p=vertcat ( savedata(p).SDF_LR1 );
    SDF_SR1p=vertcat ( savedata(p).SDF_SR1 );
    SDF_LP1p=vertcat ( savedata(p).SDF_LP1 );
    SDF_SP1p=vertcat ( savedata(p).SDF_SP1 );
    
    SDF_LR2p=vertcat ( savedata(p).SDF_LR2 );
    SDF_SR2p=vertcat ( savedata(p).SDF_SR2 );
    SDF_LP2p=vertcat ( savedata(p).SDF_LP2 );
    SDF_SP2p=vertcat ( savedata(p).SDF_SP2 );
    %%
    %%
    SDF_LR1n=vertcat ( savedata(n).SDF_LR1 );
    SDF_SR1n=vertcat ( savedata(n).SDF_SR1 );
    SDF_LP1n=vertcat ( savedata(n).SDF_LP1 );
    SDF_SP1n=vertcat ( savedata(n).SDF_SP1 );
    
    SDF_LR2n=vertcat ( savedata(n).SDF_LR2 );
    SDF_SR2n=vertcat ( savedata(n).SDF_SR2 );
    SDF_LP2n=vertcat ( savedata(n).SDF_LP2 );
    SDF_SP2n=vertcat ( savedata(n).SDF_SP2 );
    %%
    %%
    wind=[100:600];
    %%
    %%
    figuren;
    
    nsubplot(2, 1, 1, 1); set(gca,'ticklength',2*get(gca,'ticklength'))
    s1=[SDF_SR1n; SDF_LR1p];
    s2=[SDF_LR1n; SDF_SR1p];
    plot(wind,nanmean(s1(:,wind)),'r','LineWidth',2);
    plot(wind,nanmean(s2(:,wind)),'b','LineWidth',2);
    % s1=[ SDF_SR2n];
    % s2=[ SDF_LR2n];
    % plot(wind+600,nanmean(s1(:,wind)),'b','LineWidth',2);
    % plot(wind+600,nanmean(s2(:,wind)),'r','LineWidth',2);
    % ylabel('Zscored activity')
    
    nsubplot(2, 1, 2, 1); set(gca,'ticklength',2*get(gca,'ticklength'))
    s1=[SDF_SP1n; SDF_LP1p];
    s2=[SDF_LP1n; SDF_SP1p];
    plot(wind,nanmean(s1(:,wind)),'r','LineWidth',2);
    plot(wind,nanmean(s2(:,wind)),'b','LineWidth',2);
    % s1=[ SDF_SP2n];
    % s2=[ SDF_LP2n];
    % plot(wind+600,nanmean(s1(:,wind)),'r','LineWidth',2);
    % plot(wind+600,nanmean(s2(:,wind)),'b','LineWidth',2);
    % xlabel('Time (milliseconds)')
    
    x=[savedata(:).ROC_reward_smallvsbigOF2]'
    p=find(x>0.5)
    n=find(x<0.5)
    
    x=[savedata(:).P_reward_smallvsbigOF1]'
    S=find(x<PV1)
    
    p=intersect(p,S)
    n=intersect(n,S)
    
    SDF_LR1p=vertcat ( savedata(p).SDF_LR1 );
    SDF_SR1p=vertcat ( savedata(p).SDF_SR1 );
    SDF_LP1p=vertcat ( savedata(p).SDF_LP1 );
    SDF_SP1p=vertcat ( savedata(p).SDF_SP1 );
    
    SDF_LR2p=vertcat ( savedata(p).SDF_LR2 );
    SDF_SR2p=vertcat ( savedata(p).SDF_SR2 );
    SDF_LP2p=vertcat ( savedata(p).SDF_LP2 );
    SDF_SP2p=vertcat ( savedata(p).SDF_SP2 );
    %%
    %%
    SDF_LR1n=vertcat ( savedata(n).SDF_LR1 );
    SDF_SR1n=vertcat ( savedata(n).SDF_SR1 );
    SDF_LP1n=vertcat ( savedata(n).SDF_LP1 );
    SDF_SP1n=vertcat ( savedata(n).SDF_SP1 );
    
    SDF_LR2n=vertcat ( savedata(n).SDF_LR2 );
    SDF_SR2n=vertcat ( savedata(n).SDF_SR2 );
    SDF_LP2n=vertcat ( savedata(n).SDF_LP2 );
    SDF_SP2n=vertcat ( savedata(n).SDF_SP2 );
    %%
    %%
    wind=[100:600];
    %%
    %%
    
    nsubplot(2, 1, 1, 1); set(gca,'ticklength',2*get(gca,'ticklength'))
    
    s1=[SDF_SR2n; SDF_LR2p];
    s2=[SDF_LR2n; SDF_SR2p];
    plot(wind+600,nanmean(s1(:,wind)),'r','LineWidth',2);
    plot(wind+600,nanmean(s2(:,wind)),'b','LineWidth',2);
    % ylabel('Zscored activity')
    
    nsubplot(2, 1, 2, 1); set(gca,'ticklength',2*get(gca,'ticklength'))
    s1=[SDF_SP2n; SDF_LP2p];
    s2=[SDF_LP2n; SDF_SP2p];
    plot(wind+600,nanmean(s1(:,wind)),'b','LineWidth',2);
    plot(wind+600,nanmean(s2(:,wind)),'r','LineWidth',2);
    xlabel('Time (milliseconds)')
end


asfd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ASDF
% figuren;
% nsubplot(2, 1, 1, 1); set(gca,'ticklength',2*get(gca,'ticklength'))
% s1=[ SDF_SR1p];
% s2=[ SDF_LR1p];
% plot(wind,nanmean(s2(:,wind)),'r','LineWidth',2);
% plot(wind,nanmean(s1(:,wind)),'b','LineWidth',2);
% s1=[ SDF_SR2p];
% s2=[ SDF_LR2p];
% plot(wind+600,nanmean(s2(:,wind)),'r','LineWidth',2);
% plot(wind+600,nanmean(s1(:,wind)),'b','LineWidth',2);
% ylabel('Zscored activity')
%
% nsubplot(2, 1, 2, 1); set(gca,'ticklength',2*get(gca,'ticklength'))
% s1=[SDF_SP1p];
% s2=[; SDF_LP1p];
% plot(wind,nanmean(s1(:,wind)),'r','LineWidth',2);
% plot(wind,nanmean(s2(:,wind)),'b','LineWidth',2);
% s1=[ SDF_SP2p];
% s2=[ SDF_LP2p];
% plot(wind+600,nanmean(s1(:,wind)),'r','LineWidth',2);
% plot(wind+600,nanmean(s2(:,wind)),'b','LineWidth',2);
% xlabel('Time (milliseconds)')
%

%
%
%
% asdfadfs
%
% % for each unit, get loglik
%
% %sva_struct_name = 'sva'; % behav model fit to each single unit's behavioral data
% sva_struct_name = 'sva_bigbehavvalues'; % behav model fit to big behavioral dataset
% ssn = sva_struct_name;
%
% % behavioral model types: 1 = linear indep, 2 = nonlinear indep, 3 = nonlinear joint
% bmodi = 2; % use model type 2 (nonlinear indep)
%
% % subjective value models fit to neural activity:
% % 1 = rewandpunvalues (2 params + constant)
% % 2 = value (1 param + constant)
% % 3 = rewvalue (1 param + constant)
% % 4 = punvalue (1 param + constant)
% nsvmodels = 4;
%
% % get loglik for each unit, each value model, and each offer response
% noffers = 4;
%
% emptymat = nan*ones(numel(savedata),nsvmodels,noffers);
%
% unit_stats = struct();
% unit_stats.loglik = emptymat;
% unit_stats.r2 = emptymat;
% unit_stats.b = emptymat;
% unit_stats.se = emptymat;
% unit_stats.p = emptymat;
%
% unit_stats.ok = true(size(emptymat)); % which units/responses/etc are OK to use for analysis?
% unit_stats.svmodname = {};
%
% for u = 1:numel(savedata)
%
%     if ~isstruct(savedata(u).(sva_struct_name))
%         unit_stats.ok(u,:,:) = false;
%         continue;
%     end
%
%     nvf = savedata(u).(sva_struct_name).model.analysis{bmodi}.neural_value_fit;
%     assert(numel(nvf.name) == nsvmodels);
%
%     unit_stats.svmodname = nvf.name;
%     for svmodi = 1:nsvmodels
%         for offi = 1:noffers
%             unit_stats.loglik(u,svmodi,offi) = nvf.fit{svmodi,offi}.loglik;
%             unit_stats.r2(u,svmodi,offi) = nvf.fit{svmodi,offi}.r2;
%             % get fitted weight/se/p of value-related regressor
%             % (for models that have only a single weight other than the
%             %  constant factor)
%             if nvf.fit{svmodi,offi}.nx == 2
%                 unit_stats.b(u,svmodi,offi) = nvf.fit{svmodi,offi}.stats.beta(1);
%                 unit_stats.se(u,svmodi,offi) = nvf.fit{svmodi,offi}.stats.se(1);
%                 unit_stats.p(u,svmodi,offi) = nvf.fit{svmodi,offi}.stats.p(1);
%             end
%         end
%     end
% end
%
%
% unit_total_ll = sum(unit_stats.loglik,3); % sum LL over the two offer responses
%
% unit_total_ll = sum(unit_stats.loglik(:,:,1:2),3); % sum LL over the two offer responses
%
%
% %unit_total_ll = unit_stats.loglik(:,:,4); % sum LL over the two offer responses
%
%
% % only take 'ok' units
% unit_stats.oku = all(all(unit_stats.ok,3),2);
% unit_total_ll = unit_total_ll(unit_stats.oku,:);
%
%
% value_vs_rewvalue = unit_total_ll(:,2) - unit_total_ll(:,3)
% value_vs_punvalue = unit_total_ll(:,2) - unit_total_ll(:,4)
%
% clc;
% disp('rew')
% mean(value_vs_rewvalue)
% median(value_vs_rewvalue)
% signrank(value_vs_rewvalue)
%
% disp('pun')
% mean(value_vs_punvalue)
% median(value_vs_punvalue)
% signrank(value_vs_punvalue)
%
% disp('lengths')
% length(savedata)
%
%
%
%
%