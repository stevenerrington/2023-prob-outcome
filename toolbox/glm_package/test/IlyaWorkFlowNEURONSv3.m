clear all;
close all;
beep off;
warning off;
addpath('C:\Users\Ilya Monosov\Dropbox\HELPER\HELPER_GENERAL');

% add path to include necessary files for Ethan's analysis code
% NOTE: not sure if this will work on your computer. I tried to write
% this line so if you are in the current directory (Dropbox/LASER/Ilya)
% it should add the correct path whether you are on Mac or PC.
addpath(fullfile('.','ethan_dependencies'));

% generate subjective value analysis from big behavioral datasets from each
% animal. We will use these to fit behavioral models from which we can
% derive values for each offer used in the neuronal data, used in the
% neural analysis below.
fprintf('re-generating big behavioral dataset analysis for use in neural subjective value analysis\n');
big_behavioral_dataset_analysis_for_neural_sva_v02;
fprintf('...done\n');
clear all;
close all;
% load the resulting 'bbd' data structure
load('big_behavioral_dataset_analysis_for_neural_sva_v02.mat');

for monkeytype=1:2
    
    if monkeytype==1
        pathname = 'Y:\MONKEYDATA\Sabbath\LaserTest\PLEXON\PDS\';
        addpath(pathname);% Sabbath
        monkeyname='sabbath';
        
        DDD = dir([pathname '*.mat']);
        clear d
        for X=1:length(DDD)
            d(X).t=DDD(X).name(1:21);
            clear X
        end
        UniqueSessions=unique(struct2cell(d));
        for X=1:length(DDD)
            DDD(X).Session=find(strcmp(UniqueSessions, DDD(X).name(1:21)));
            clear X
        end
        
    elseif monkeytype==2
        
        pathname = 'Y:\MONKEYDATA\Slayer2\Laser test\PLEXON\PDS\';
        addpath(pathname);
        monkeyname='slayer';
        
        DDD = dir([pathname '*.mat']);
        clear d
        for X=1:length(DDD)
            d(X).t=DDD(X).name(1:21);
            clear X
        end
        UniqueSessions=unique(struct2cell(d));
        for X=1:length(DDD)
            DDD(X).Session=find(strcmp(UniqueSessions, DDD(X).name(1:21)));
            clear X
        end
        
    else
        pathname = 'Y:\MONKEYDATA\Slayer2\Laser test\PLEXON\PDS\LHB\';
        addpath(pathname);
        monkeyname='slayer';
        
        DDD = dir([pathname '*.mat']);
        clear d
        for X=1:length(DDD)
            d(X).t=DDD(X).name(1:21);
            clear X
        end
        UniqueSessions=unique(struct2cell(d));
        for X=1:length(DDD)
            DDD(X).Session=find(strcmp(UniqueSessions, DDD(X).name(1:21)));
            clear X
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%  Definition of parameters
    
    s.CENTER = 8000;
    s.gauswindow_ms = 100;
    s.eventfieldname = ...
        {'timefpon',...
        'timetargeton',...
        'timetargeton2',...
        'timeChoice',...
        'timeLaser',...
        'timereward'};
    
    eventfieldname = s.eventfieldname;
    timefpon_N = find(contains(eventfieldname, 'timefpon'));
    timetargeton_N = find(contains(eventfieldname, 'timetargeton'), 1 );
    timetargeton2_N = find(contains(eventfieldname, 'timetargeton2'));
    timeChoice_N = find(contains(eventfieldname, 'timeChoice'));
    timeLaser_N = find(contains(eventfieldname, 'timeLaser'));
    timereward_N = find(contains(eventfieldname, 'timereward'));
    
    choices=[];
    L=[];
    
    
    for x_file = 1 :size(DDD, 1)
        
        savedata(x_file).exclude=0;
        
        % clearvars -except savestruct s DDD x_file pathname offer1_LR1_offer1_SR1_diff offer1_LP1_offer1_SP1_diff offer2_LR2_offer2_SR2_diff offer2_LP2_offer2_SP2_diff
        %
        % load PDS from each directory using recording list
        specificfilename = DDD(x_file).name;
        pathoffile = which(specificfilename);
        load(pathoffile, 'PDS');
        
        
        savedata(x_file).pathoffile=pathoffile;
        savedata(x_file).filename=DDD(x_file).name;
        savedata(x_file).loopnum=x_file;
        savedata(x_file).monkeyname=monkeyname;
        
        
        
        
        choices_=[PDS.RewardRange1' PDS.PunishmentRange1' PDS.RewardRange2' PDS.PunishmentRange2' PDS.chosenwindow'];
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%% Recording data acquisition
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %get timing of each event
        nn = numel(eventfieldname);
        eventtime = cell(1, nn);
        SDFcs_n = cell(1, nn);
        zscoredSDFcs_n = cell(1, nn);
        Rasters = cell(1, nn);
        CENTER = s.CENTER;
        
        
        for z = 1 : nn
            
            eventtime{z} = getfield(PDS,eventfieldname{z});
            
            for x = 1 : length(PDS.trialnumber) % run while trial number
                spike_times = PDS.sptimes{x};
                spk= spike_times - eventtime{z}(x);
                spk= (spk*1000) + CENTER - 1;
                spk= fix(spk);
                spk= spk(spk <= CENTER*2);
                temp(1:CENTER*2) = 0;
                try % one problem ... if error, this trial is trear as no spike trial, should be fixed
                    temp(spk)=1;
                    %                     catch
                    %                         miss_trial(:, end+1) = x;
                end
                Rasters{z} = vertcat(Rasters{z}, temp);
                clear spike_times spk temp
            end
            %% Making SDF
            SDFcs_n{z} = plot_mean_psth({Rasters{z}},s.gauswindow_ms,1,size(Rasters{z},2),1);
        end
        
        goodtrial = find(~isnan(PDS.chosenwindow));
        %% Z scoring SDFs
        temp_S =  SDFcs_n{timetargeton_N}(goodtrial, CENTER-500: CENTER + 1400); % using SDF of Target Acquisition time
        mean_S = mean(temp_S(:));
        SD_S = std(temp_S(:));
        for z = 1 : nn
            zscoredSDFcs_n{z} = (SDFcs_n{z} - mean_S)./SD_S;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        wind = CENTER+100:CENTER+350; 
        z = timetargeton_N;
        OF1=( sum(Rasters{z}(:,wind),2,'omitnan') ./ (length(wind) )) *1000;
         savedata(x_file).wind1= wind;
        
        wind = CENTER+150:CENTER+400; 
        z = timetargeton2_N;
        OF2=( sum(Rasters{z}(:,wind),2,'omitnan') ./ (length(wind) )) *1000;
            savedata(x_file).wind2= wind;
        
        wind = CENTER:CENTER+500;
        z = timefpon_N;
        FP=( sum(Rasters{z}(:,wind),2,'omitnan') ./ (length(wind) )) *1000;
        
        wind = CENTER-500:CENTER;
        z = timefpon_N;
        BL=( sum(Rasters{z}(:,wind),2,'omitnan') ./ (length(wind) )) *1000;
        
        wind = CENTER:CENTER+500;
        z = timeLaser_N;
        Ls=( sum(Rasters{z}(:,wind),2,'omitnan') ./ (length(wind) )) *1000;
        
        wind = CENTER-3400:CENTER;
        z = timeLaser_N;
        PostCh=( sum(Rasters{z}(:,wind),2,'omitnan') ./ (length(wind) )) *1000;
        
        wind = CENTER:CENTER+500;
        z = timereward_N;
        Rs=( sum(Rasters{z}(:,wind),2,'omitnan') ./ (length(wind) )) *1000;
        
        wind = CENTER-750:CENTER;
        z = timeChoice_N;
        CHs=( sum(Rasters{z}(:,wind),2,'omitnan') ./ (length(wind) )) *1000;
        
        
        
        
        
        id=find(PDS.timereward>0)
        savedata(x_file).goodtrialslength=length(id);
        
        try
            d1=[OF1' ; OF2'; FP'; Ls'; Rs']';
            d1=d1(id,:);
            d2=[];
            for B=1:length(d1)
                d2=[d2; [1:5]];
            end
            
            savedata(x_file).variance=kruskalwallis(d1(:),d2(:),'off')
        catch
            savedata(x_file).variance= NaN;
        end
        
        
        try
            d1=[OF1' ; OF2'; FP'; Ls'; Rs']';
            d1=d1(id,:);
            clear d2
            d1=nanmean(d1');
            clear d2;
            d2(1:length(d1))=1:length(d1);
            [rho,p]=corr(d1',d2');
            savedata(x_file).drift= [rho p];
            
            d1=[ FP';]';
            d1=d1(id,:);
            clear d2;
            d2(1:length(d1))=1:length(d1);
            [rho,p]=corr(d1,d2');
            savedata(x_file).driftFP= [rho p];
            
            
        catch
            savedata(x_file).drift= [NaN NaN];
            savedata(x_file).driftFP= [NaN NaN];
        end
        
        
        try
            d1=findseq(d1)
            d1=max(d1(find(d1(:,1)==0),4));
            if isempty(d1)==1
                d1=0
            end
            savedata(x_file).seq= d1;
        catch
            savedata(x_file).seq= [NaN];
            
        end
        
        clear d1 d2 B Rs Ls BL FP clear rho p
        
        FRmean=nanmean(nanmean([OF1'; OF2'; PostCh'; CHs';]));
        FRstd=nanstd(nanmean([OF1'; OF2'; PostCh'; CHs';]));
        OF1=(OF1-FRmean)./ FRstd;
        OF2=(OF2-FRmean)./ FRstd;
        PostCh=(PostCh-FRmean)./ FRstd;
        CHs=(CHs-FRmean)./ FRstd;
        
        
        LoopNumber(1:length(OF1))=x_file;
        SessionID(1:length(OF1))=DDD(x_file).Session;
        savedata(x_file).Session=DDD(x_file).Session;
        
        TrialID(1:length(OF1))=(1:length(OF1));
        
        choices_=[choices_ OF1 OF2 LoopNumber' SessionID'  TrialID' PostCh CHs];
        
        numbertoremovenonchoice=-1;
        choices_=choices_(find(choices_(:,5)>numbertoremovenonchoice),:);
        
        %     l1=length(find(choices_(:,1) == max([PDS.RewardRange1 PDS.RewardRange2])))
        %     l2=length(find(choices_(:,3) == max([PDS.RewardRange1 PDS.RewardRange2])))
        %     L=[L; l1 l2 DDD(x_file).Session];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        savedata(x_file).uniquechoicewindows=unique(choices_(:,5))';
        savedata(x_file).numbertoremovenonchoice=numbertoremovenonchoice;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        trialtypeid(1:length(choices_))=NaN;
        
        trialtypeid( find(choices_(:,1)==4 & choices_(:,2)==2) ) = 1;
        trialtypeid( find(choices_(:,1)==4 & choices_(:,2)==4)) = 2;
        trialtypeid( find(choices_(:,1)==4 & choices_(:,2)==6)) = 3;
        
        trialtypeid(  find(choices_(:,1)==6 & choices_(:,2)==2)) = 4;
        trialtypeid( find(choices_(:,1)==6 & choices_(:,2)==4)) = 5;
        trialtypeid( find(choices_(:,1)==6 & choices_(:,2)==6)) = 6;
        
        
        trialtypeid(  find(choices_(:,1)==8 & choices_(:,2)==2)) = 7;
        trialtypeid(  find(choices_(:,1)==8 & choices_(:,2)==4)) = 8;
        trialtypeid( find(choices_(:,1)==8 & choices_(:,2)==6)) = 9;
        
        try
            trialtypeid=[trialtypeid' choices_(:,6)];
            trialtypeid= trialtypeid(find(trialtypeid(:,1))>0,:);
            
            savedata(x_file).offer1variance=kruskalwallis(trialtypeid(:,2),trialtypeid(:,1),'off');
        catch
            savedata(x_file).offer1variance=NaN;
            savedata(x_file).exclude=1;
        end
        
        clear trialtypeid
        
        try
            trialtypeid(1:length(choices_))=NaN;
            
            trialtypeid( find(choices_(:,3)==4 & choices_(:,4)==2) ) = 1;
            trialtypeid( find(choices_(:,3)==4 & choices_(:,4)==4)) = 2;
            trialtypeid( find(choices_(:,3)==4 & choices_(:,4)==6)) = 3;
            
            trialtypeid(  find(choices_(:,3)==6 & choices_(:,4)==2)) = 4;
            trialtypeid( find(choices_(:,3)==6 & choices_(:,4)==4)) = 5;
            trialtypeid( find(choices_(:,3)==6 & choices_(:,4)==6)) = 6;
            
            
            trialtypeid(  find(choices_(:,3)==8 & choices_(:,4)==2)) = 7;
            trialtypeid(  find(choices_(:,3)==8 & choices_(:,4)==4)) = 8;
            trialtypeid( find(choices_(:,3)==8 & choices_(:,4)==6)) = 9;
            
            trialtypeid=[trialtypeid' choices_(:,7)];
            trialtypeid= trialtypeid(find(trialtypeid(:,1))>0,:);
            
            savedata(x_file).offer2variance=kruskalwallis(trialtypeid(:,2),trialtypeid(:,1),'off');
        catch
            savedata(x_file).offer2variance=NaN;
            savedata(x_file).exclude=1;
        end
        clear trialtypeid
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        LargeReward1 = find(choices_(:,1) == max([PDS.RewardRange1 PDS.RewardRange2]));
        SmallReward1 = find(choices_(:,1) == min([PDS.RewardRange1 PDS.RewardRange2]));
        
        LargePunish1 = find(choices_(:,2) == max([PDS.PunishmentRange1 PDS.PunishmentRange2]));
        SmallPunish1 = find(choices_(:,2) == min([PDS.PunishmentRange1 PDS.PunishmentRange2]));
        
        evenIndices = rem(choices_(:,10), 2) == 0;
        eventrials=find(evenIndices==1);
        oddtrials=find(evenIndices==0);
        
        %
        %         LR=intersect(LargeReward1,SmallPunish1) ;
        %         SR=intersect(SmallReward1,SmallPunish1) ;
        %
        %         LP=intersect(LargePunish1,SmallReward1) ;
        %         SP=intersect(SmallPunish1,SmallReward1) ;
        %
        LR=LargeReward1 ;
        SR=SmallReward1 ;
        
        LP=LargePunish1 ;
        SP=SmallPunish1 ;
        
        
        
        
        wind = CENTER-100:CENTER+1400;
        z = timetargeton_N;
        OFsdf=zscoredSDFcs_n{z}(:,wind);
        
        savedata(x_file).SDF_LR1=nanmean(OFsdf(LR,:));
        savedata(x_file).SDF_SR1=nanmean(OFsdf(SR,:));
        savedata(x_file).SDF_LP1=nanmean(OFsdf(LP,:));
        savedata(x_file).SDF_SP1=nanmean(OFsdf(SP,:));
        
        savedata(x_file).OF1_LR1=nanmean(OF1(LR));
        savedata(x_file).OF1_SR1=nanmean(OF1(SR));
        savedata(x_file).OF1_LP1=nanmean(OF1(LP));
        savedata(x_file).OF1_SP1=nanmean(OF1(SP));
        
        
        
%                 figuren;
%                 plot( nanmean(OFsdf(LR,:)) ,'r')
%                 plot( nanmean(OFsdf(SR,:)) ,'m')
%                 plot( nanmean(OFsdf(LP,:)) ,'b')
%                 plot( nanmean(OFsdf(SP,:)) ,'g')
%         
%                 close all;
        %
        clear z OFsdf wind
        
        
        
        
        %%
        %%
        SRs=choices_(intersect(SR,eventrials),6);
        LRs=choices_(intersect(LR,eventrials),6);
        SPs=choices_(intersect(SP,oddtrials),6);
        LPs= choices_(intersect(LP,oddtrials),6);
        %%
        %%
        
        
        
        
        [roc,p]=rocarea3( SRs ,  LRs );
        savedata(x_file).ROC_reward_smallvsbigOF1=[roc];
        savedata(x_file).P_reward_smallvsbigOF1=[p];
        
        [roc,p]=rocarea3( SPs , LPs );
        savedata(x_file).ROC_punish_smallvsbigOF1=[roc];
        savedata(x_file).P_punish_smallvsbigOF1=[p]
        %%
        %%
        
        LargeReward1 = find(choices_(:,3) == max([PDS.RewardRange1 PDS.RewardRange2]));
        SmallReward1 = find(choices_(:,3) == min([PDS.RewardRange1 PDS.RewardRange2]));
        
        LargePunish1 = find(choices_(:,4) == max([PDS.PunishmentRange1 PDS.PunishmentRange2]));
        SmallPunish1 = find(choices_(:,4) == min([PDS.PunishmentRange1 PDS.PunishmentRange2]));
        
        evenIndices = rem(choices_(:,10), 2) == 0;
        eventrials=find(evenIndices==1);
        oddtrials=find(evenIndices==0);
        
        %         LR=intersect(LargeReward1,SmallPunish1);
        %         SR=intersect(SmallReward1,SmallPunish1);
        %
        %         LP=intersect(LargePunish1,SmallReward1);
        %         SP=intersect(SmallPunish1,SmallReward1);
        
        LR=LargeReward1 ;
        SR=SmallReward1 ;
        
        LP=LargePunish1 ;
        SP=SmallPunish1 ;
        
        wind = CENTER-100:CENTER+1400;
        z = timetargeton2_N;
        OFsdf=zscoredSDFcs_n{z}(:,wind);
        
        savedata(x_file).SDF_LR2=nanmean(OFsdf(LR,:));
        savedata(x_file).SDF_SR2=nanmean(OFsdf(SR,:));
        savedata(x_file).SDF_LP2=nanmean(OFsdf(LP,:));
        savedata(x_file).SDF_SP2=nanmean(OFsdf(SP,:));
        
        savedata(x_file).OF2_LR1=nanmean(OF2(LR));
        savedata(x_file).OF2_SR1=nanmean(OF2(SR));
        savedata(x_file).OF2_LP1=nanmean(OF2(LP));
        savedata(x_file).OF2_SP1=nanmean(OF2(SP));
        
        
        clear z OFsdf wind
        
        
        
        SRs2=choices_(intersect(SR,eventrials),7);
        LRs2=choices_(intersect(LR,eventrials),7);
        SPs2=choices_(intersect(SP,oddtrials),7);
        LPs2= choices_(intersect(LP,oddtrials),7);
        
        [roc,p]=rocarea3( SRs2 ,  LRs2 );
        savedata(x_file).ROC_reward_smallvsbigOF2=[roc];
        savedata(x_file).P_reward_smallvsbigOF2=[p];
        
        [roc,p]=rocarea3( SPs2 , LPs2 );
        savedata(x_file).ROC_punish_smallvsbigOF2=[roc];
        savedata(x_file).P_punish_smallvsbigOF2=[p];
        
        
        savedata(x_file).ROC_reward_smallvsbigOFb=nanmean([savedata(x_file).ROC_reward_smallvsbigOF2 savedata(x_file).ROC_reward_smallvsbigOF1]);
        savedata(x_file).P_reward_smallvsbigOFb= combine_pvalues([ savedata(x_file).P_reward_smallvsbigOF2 savedata(x_file).P_reward_smallvsbigOF1])
        savedata(x_file).ROC_punish_smallvsbigOFb=nanmean([savedata(x_file).ROC_punish_smallvsbigOF2 savedata(x_file).ROC_punish_smallvsbigOF1]);
        savedata(x_file).P_punish_smallvsbigOFb= combine_pvalues([ savedata(x_file).P_punish_smallvsbigOF2 savedata(x_file).P_punish_smallvsbigOF1])
        %         %%
        try
            chosen=[];
            for xb=1:size(choices_,1)
                if choices_(xb,5)==0
                    chosen=[chosen; choices_(xb,1) choices_(xb,2)];
                elseif choices_(xb,5)==1
                    chosen=[chosen; choices_(xb,3) choices_(xb,4)];
                else
                    chosen=[chosen; NaN NaN];
                end
            end
            
            
            LargeReward1 = find(chosen(:,1) == max([PDS.RewardRange1 PDS.RewardRange2]));
            SmallReward1 = find(chosen(:,1) == min([PDS.RewardRange1 PDS.RewardRange2]));
            
            LargePunish1 = find(chosen(:,2) == max([PDS.PunishmentRange1 PDS.PunishmentRange2]));
            SmallPunish1 = find(chosen(:,2) == min([PDS.PunishmentRange1 PDS.PunishmentRange2]));
            
            evenIndices = rem(choices_(:,10), 2) == 0;
            eventrials=find(evenIndices==1);
            oddtrials=find(evenIndices==0);
            
            LR=LargeReward1 ;
            SR=SmallReward1 ;
            
            LP=LargePunish1 ;
            SP=SmallPunish1 ;
            
            SRs2=choices_(intersect(SR,eventrials),11);
            LRs2=choices_(intersect(LR,eventrials),11);
            SPs2=choices_(intersect(SP,oddtrials),11);
            LPs2= choices_(intersect(LP,oddtrials),11);
            
            [roc,p]=rocarea3( SRs2 ,  LRs2 );
            savedata(x_file).ROC_reward_smallvsbigP=[roc];
            savedata(x_file).P_reward_smallvsbigP=[p];
            
            [roc,p]=rocarea3( SPs2 , LPs2 );
            savedata(x_file).ROC_punish_smallvsbigP=[roc];
            savedata(x_file).P_punish_smallvsbigP=[p];
            
            
            SRs2=choices_(intersect(SR,eventrials),7);
            LRs2=choices_(intersect(LR,eventrials),7);
            SPs2=choices_(intersect(SP,oddtrials),7);
            LPs2= choices_(intersect(LP,oddtrials),7);
            
            [roc,p]=rocarea3( SRs2 ,  LRs2 );
            savedata(x_file).ROC_reward_smallvsbigOF2_cv=[roc];
            savedata(x_file).P_reward_smallvsbigOF2_cv=[p];
            
            [roc,p]=rocarea3( SPs2 , LPs2 );
            savedata(x_file).ROC_punish_smallvsbigOF2_cv=[roc];
            savedata(x_file).P_punish_smallvsbigOF2_cv=[p];
            
            
            SRs2=choices_(intersect(SR,eventrials),12);
            LRs2=choices_(intersect(LR,eventrials),12);
            SPs2=choices_(intersect(SP,oddtrials),12);
            LPs2= choices_(intersect(LP,oddtrials),12);
            
            [roc,p]=rocarea3( SRs2 ,  LRs2 );
            savedata(x_file).ROC_reward_smallvsbigCHs_cv=[roc];
            savedata(x_file).P_reward_smallvsbigCHs_cv=[p];
            
            [roc,p]=rocarea3( SPs2 , LPs2 );
            savedata(x_file).ROC_punish_smallvsbigCHs_cv=[roc];
            savedata(x_file).P_punish_smallvsbigCHs_cv=[p];
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Ethan subjective value analysis
        
        % sva = subjective value analysis
        %
        % fits the data with 3 different models of subjective value:
        %  1. linear, independent effects of rew and pun magnitude
        %  2. arbitrarily nonlinear, independent effecs
        %  3. arbitrarily nonlinear, joint (interacting) effects
        %
        % for each model, does the following analyses:
        % - fit behavioral data
        % - fit neural data
        % - fit neural data using only the model-derived reward-related and
        %   punishment-related subjective values of each offer
        % - fit neural data using only the model-derived total subjective value
        %   of each offer
        % - correlation between neural firing rate and each component of its
        %   subjective value (rew value only, pun value only, and total value)
        %
        % Important notes:
        %
        % - you can have this function automatically generate simple plots of
        %   the results, by passing in these two extra arguments: 'plot', 1
        %
        % - the key results are stored in sva.model.analysis{modelindex} for
        %   each model. Each fit has a 'name' field that explains what type of
        %   fit it was (e.g. behavioral or neural, which model, which offer
        %   response), to further help you figure out which is which.
        %
        % - if you see any warning messages from the fits (e.g. if there is not
        %   enough data to fit a complex model), you can find which fit they
        %   came from by checking each fit data structure's "warning" field.
        %   Each fit's warning.detected field will say if a warning was
        %   detected during that fit, and the other fields will say what the
        %   warning was.
        
        
        choices_(:,5)=choices_(:,5)+1;
        savedata(x_file).choices=choices_;
        
        try
            % subjective value analysis using only behavioral+neural data
            % from recording of this neuron
            sva = aatradeoff_subjective_value_analysis_v04(choices_);
            
            % subjective value analysis using values derived from fit to
            % existing big behavioral dataset
            monkeyindex = find(strcmp(monkeyname,bbd.monk.name));
            assert(numel(monkeyindex)==1,'did not find unique monkey named "%s" in big behavioral dataset analysis structure',monkeyname);
            bigbehav_sva = bbd.monk.sva{monkeyindex};
            sva_bigbehavvalues = aatradeoff_subjective_value_analysis_v04(choices_,'use_values_from_existing_sva',bigbehav_sva);
            
            % save the results
            savedata(x_file).sva = sva;
            % BUGFIX BY ETHAN so it should now save properly
            %savedata(x_file).sva_bigbehavvalues = sva;
            savedata(x_file).sva_bigbehavvalues = sva_bigbehavvalues;
            fprintf('ACCEPTING sva from monkeytype %d file %d/%d\n',monkeytype,x_file,size(DDD,1));
        catch
            savedata(x_file).sva = NaN;
            savedata(x_file).sva_bigbehavvalues = NaN;
            savedata(x_file).exclude=1;
            fprintf('EXCLUDING sva from monkeytype %d file %d/%d\n',monkeytype,x_file,size(DDD,1));
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        savedata(x_file).choices=choices_;
        
        clear choices_ OF1 OF2 LoopNumber nn eventtime Rasters SessionID LoopNumber TrialID roc p LP SP LR SR eventIndices
        
        
        
    end
    
    
    
    
    filename = ['savedata_' monkeyname '__' mat2str(monkeytype) '.mat']
    save(filename, 'savedata', '-v7.3')
    
    
    clear savedata filename choices_ choices
end

%NeuralVisualization;











