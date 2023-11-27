
%%%% searcgh for PLACE HERE in this file and you will see where the struct
%%%% "c" is being saved. that is the single neurons choice and firing rate
%%%% data. after that I will make a SDF plot for the cell. i am not sure if
%%%% we should show it

clear all; close all;

do_load_and_calc = 1;
do_plot = 1;

if do_load_and_calc
    %clear all; close all; clc; 

    addpath('/Users/Ilya/Dropbox/HELPER/HELPER_GENERAL/');



    % example neuron
    load('LemmyKim-07292021-004_LaserTest_cl4_PDS.mat')
    
    % other neurons from same recording
    %load('LemmyKim-07292021-004_LaserTest_cl1_PDS.mat')
    %load('LemmyKim-07292021-004_LaserTest_cl5_PDS.mat')
    %load('LemmyKim-07292021-004_LaserTest_cl6_PDS.mat')
    %load('LemmyKim-07292021-004_LaserTest_cl17_PDS.mat')


    choices=[PDS.RewardRange1' PDS.PunishmentRange1' PDS.RewardRange2' PDS.PunishmentRange2' PDS.chosenwindow'];
    %choices=choices(find(choices(:,5)>-1),:);
    if ~isempty(find(choices(:,5)==0))==1
        choices(:,5)=choices(:,5)+1
    end



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%% Recording data Acquisition
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    s.CENTER = 8000;
    s.gauswindow_ms = 100;
    s.eventfieldname = ...
      {'timefpon',...
        'timetargeton',...
        'timetargeton2',...
        'timeChoice',...
        'timeLaser',...
        'timereward'};

    % s.Background_window_min = -300;
    % s.Background_window_max = 0;
    % s.TrialsStart_window_min = 50;
    % s.TrialsStart_window_max = 350;
    % s.TargetON_window_min = 50;
    % s.TargetON_window_max = 350;
    % s.GoON_window_min = 0;
    % s.GoON_window_max = 300;
    % s.presac_window_min = -200;
    % s.presac_window_max = 100;
    % s.postsac_window_min = 100;
    % s.postsac_window_max = 400;
    % s.ITIevent_window_min = 100;
    % s.ITIevent_window_max = 400;
    % 
    % s.Outcome_window_min = 100;
    % s.Outcome_window_max = 600;

    s.Pval_threshold = 0.05;


        s.ii = 0;
        s.iii = 0;


    eventfieldname = s.eventfieldname;
    timefpon_N = find(contains(eventfieldname, 'timefpon'));
    timetargeton_N = find(contains(eventfieldname, 'timetargeton'), 1 );
    timetargeton2_N = find(contains(eventfieldname, 'timetargeton2'));
    timeChoice_N = find(contains(eventfieldname, 'timeChoice'));
    timeLaser_N = find(contains(eventfieldname, 'timeLaser'));
    timereward_N = find(contains(eventfieldname, 'timereward'));

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
    temp_S =  SDFcs_n{timetargeton_N}(goodtrial, CENTER: CENTER + 8000); % using SDF of Target Acquisition time
    mean_S = mean(temp_S(:));
    SD_S = std(temp_S(:));

    for z = 1 : nn
        zscoredSDFcs_n{z} = (SDFcs_n{z} - mean_S)./SD_S;
    end


    % Combinations of Reward and Punish

    rewdiff = PDS.RewardRange1 - PDS.RewardRange2; % Reward difference between 1 and 2
    pundiff = PDS.PunishmentRange1 - PDS.PunishmentRange2; % Punishment difference between 1 and 2

    ChoseFirst = find(PDS.chosenwindow==0);
    ChoseSecond = find(PDS.chosenwindow==1);



    wind=[8000+100:8350]; 
   % wind=[8000+(150:450)]; 
    Offer1Rasters=Rasters{2};
    Offer1Rate=(nansum(Offer1Rasters(: , wind)') ./ length(wind))*1000;
    Offer1Rew=unique(PDS.RewardRange1);
    Offer1Punish=unique(PDS.PunishmentRange1);

    wind=[8000+150:8400]; 
    %wind=[8000+(150:450)]; 
    Offer2Rasters=Rasters{3};
    Offer2Rate=(nansum(Offer2Rasters(: , wind)') ./ length(wind))*1000;
    Offer2Rew=unique(PDS.RewardRange2);
    Offer2Punish=unique(PDS.PunishmentRange2);

    c=[choices Offer1Rate' Offer2Rate'];
    c=c(find(~isnan(c(:,5))==1),:);
    %%%PLACE HERE TO RUN CODE on c


    % subjective value analysis using values from fit only to this data
    sva = aatradeoff_subjective_value_analysis_v04(c);
    
    % subjective value analysis using values derived from fit to
    % existing big behavioral dataset
    load('big_behavioral_dataset_analysis_for_neural_sva_v02.mat');
    monkeyname ='sabbath';
    monkeyindex = find(strcmp(monkeyname,bbd.monk.name));
    assert(numel(monkeyindex)==1,'did not find unique monkey named "%s" in big behavioral dataset analysis structure',monkeyname);
    bigbehav_sva = bbd.monk.sva{monkeyindex};
    sva_bbv = aatradeoff_subjective_value_analysis_v04(c,'use_values_from_existing_sva',bigbehav_sva);
    
end

if do_plot

    %make SDFs

    off1SDF= SDFcs_n{2};
    off2SDF=SDFcs_n{3};
    off1Rast= Rasters{2};
    off2Rast=Rasters{3};
    off1SDF=off1SDF(:,8000:8500);
    off2SDF=off2SDF(:,8000:8500);
    off1Rast=off1Rast(:,8000:8500);
    off2Rast=off2Rast(:,8000:8500);

     % 
    LargeReward1 = find(PDS.RewardRange1 == 8);
    MediumReward1 = find(PDS.RewardRange1 == 6);
    SmallReward1 = find(PDS.RewardRange1 == 4);

    LargePunishment1 = find(PDS.PunishmentRange1 == 6);
    MediumPunishment1 = find(PDS.PunishmentRange1 == 4);
    SmallPunishment1 = find(PDS.PunishmentRange1 == 2);
    % 
     % 
    LargeReward2 = find(PDS.RewardRange2 == 8);
    MediumReward2 = find(PDS.RewardRange2 == 6);
    SmallReward2 = find(PDS.RewardRange2 == 4);

    LargePunishment2 = find(PDS.PunishmentRange2 == 6);
    MediumPunishment2 = find(PDS.PunishmentRange2 == 4);
    SmallPunishment2 = find(PDS.PunishmentRange2 == 2);


    figuren; 

    nsubplot(2, 1, 1, 1);

    plt1=off1SDF(intersect(LargeReward1,SmallPunishment1),:);
    plt2=off1SDF(intersect(LargeReward1,LargePunishment1),:);
    plt3=off1SDF(intersect(SmallReward1,SmallPunishment1),:);
    plt4=off1SDF(intersect(SmallReward1,LargePunishment1),:);

    shadedErrorBar([1:501], plt1, {@nanmean, @(x) nanstd(x)./sqrt(size(plt1,1))}, {'r', 'LineWidth', 2.5}, 0); hold on
    shadedErrorBar([1:501], plt2, {@nanmean, @(x) nanstd(x)./sqrt(size(plt2,1))}, {'g', 'LineWidth', 2.5}, 0); hold on
    shadedErrorBar([1:501], plt3, {@nanmean, @(x) nanstd(x)./sqrt(size(plt3,1))}, {'m', 'LineWidth', 2.5}, 0); hold on
    shadedErrorBar([1:501], plt4, {@nanmean, @(x) nanstd(x)./sqrt(size(plt4,1))}, {'b', 'LineWidth', 2.5}, 0); hold on

    xlabel('OFFER 1')

    nsubplot(2, 1, 1, 2);

    plt1=off2SDF(intersect(LargeReward2,SmallPunishment2),:);
    plt2=off2SDF(intersect(LargeReward2,LargePunishment2),:);
    plt3=off2SDF(intersect(SmallReward2,SmallPunishment2),:);
    plt4=off2SDF(intersect(SmallReward2,LargePunishment2),:);

    shadedErrorBar([1:501], plt1, {@nanmean, @(x) nanstd(x)./sqrt(size(plt1,1))}, {'r', 'LineWidth', 2.5}, 0); hold on
    shadedErrorBar([1:501], plt2, {@nanmean, @(x) nanstd(x)./sqrt(size(plt2,1))}, {'g', 'LineWidth', 2.5}, 0); hold on
    shadedErrorBar([1:501], plt3, {@nanmean, @(x) nanstd(x)./sqrt(size(plt3,1))}, {'m', 'LineWidth', 2.5}, 0); hold on
    shadedErrorBar([1:501], plt4, {@nanmean, @(x) nanstd(x)./sqrt(size(plt4,1))}, {'b', 'LineWidth', 2.5}, 0); hold on

    xlabel('OFFER 2 ')

    
    set(gcf,'Position',[1 41 2560 1484],'Paperposition',[0 0 26.6667 15.4583], 'Paperpositionmode','auto','Papersize',[26.6667 15.4583]);  % sets the size of the figure and orientation
print('-dpdf', 'suaEx1' ); 



    
    % Ethan plots
    
    % use values from fit to just this data
    sva_cur = sva;
    % use values from fit to big behav dataset
    %sva_cur = sva_bbv;
    
    figuren;
    modi = 2; % use model 2
    
    noff = 2;
    valuetype = {'rewvalue','punvalue','value'};
    nvt = numel(valuetype);
    
    
    rawdat.name = {};
    rawdat.xy = {};
    rawdat.rho = [];
    rawdat.p = [];
    rawdat.se = [];
    
    h = [];
    for oi = 1:noff
        for vti = 1:nvt
            vtn = valuetype{vti};
            fiti = find(strcmp(vtn,sva_cur.model.analysis{modi}.neural_value_fit.name));
            assert(numel(fiti)==1);
% 
%             fitb = sva_bbv.model.analysis{modi}.behav_full_fit;
%             fitn = sva_bbv.model.analysis{modi}.neural_value_fit.fit{fiti,oi};
%                     
%             nsubplot(noff,nvt,oi,vti);
%             title(sprintf('offer %d %s',oi,vtn));
%             x = fitb.peroffer.(vtn)(:,oi);
%             %y = fitn.y(:,1);
%             y = sva_bbv.dat.neural_offer_response(:,oi);
%             plot(x,y,'o');
%             [rho,p] = corr(x,y,'type','Spearman');
%             etextn('lt',sprintf('rho %.4f\np %.5f',rho,p));

            fit = sva_cur.model.analysis{modi}.neural_value_fit.fit{fiti,oi};
                    
            h(oi,vti)=nsubplot(noff,nvt+1,oi,vti);
            title(sprintf('offer %d %s',oi,vtn));
            x = fit.x(:,1);
            y = fit.y(:,1);
            %plot(x,y,'o','color',[1 1 1]*.5);
            [rho,p] = corr(x,y,'type','Spearman');
            etextn('lt',sprintf('rho %.4f\np %.5f',rho,p));
            
            % bootstrapping to get error bars of rank correlation
            nboot = 200;
            rho_boot = bootstrp(nboot,@(z) corr(z(:,1),z(:,2),'type','Spearman'),[x y]);
            rho_se = std(rho_boot);
            
            rawdat.name{end+1} = sprintf('off%d %s',oi,vtn);
            rawdat.xy{end+1} = [x y];
            rawdat.rho(end+1) = rho;
            rawdat.p(end+1) = p;
            rawdat.se(end+1) = rho_se;
            
            
            b = regress(y,[ones(size(x)) x]);
            linexy([0 1],[0 1].*b(2) + b(1),'k','linewidth',2);
            
            [unique_x,~,unique_i] = unique(x);
            
            ux = nans(numel(unique_x),1);
            uy = nans(numel(unique_x),1);
            uyse = nans(numel(unique_x),1);
            for i = 1:numel(unique_x)
                ally = y(unique_i == i);
                
                ux(i) = unique_x(i);
                uy(i) = mean(ally);
                uyse(i) = sem(ally);
            end
            plot_errorbar(ux,uy,uyse,{'ko','linewidth',2,'markerfacecolor','k'},{'k-','linewidth',2});
            setlim(gca,'xlim','tight',.05);
%             [slope,yint] = type_2_regression(x,y);
%             linexy([0 1],[0 1].*slope + yint,'k');
        end
    end
    
    for oi = 1:size(h,1)
        setlim(h(oi,:),'ylim','tight',.1);
    end
    
    nsubplot(noff,nvt+1,1,nvt+1);
    liney(0,'k');
    x = 1:numel(rawdat.rho);
    y = rawdat.rho;
    yse = rawdat.se;
    plot_errorbar(x,y,yse,{'bar',[1 1 1]*.8,'edgecolor','k'},{'k','linewidth',2});
    for i = 1:numel(x)
        etext('ct',x(i),y(i)-yse(i),sprintf('%.4f',rawdat.p(i)));
    end
    set(gca,'xtick',x,'xticklabel',rawdat.name);
    xtickangle(30);
    ylabel('Rho (activity vs value)');
end

if 0
    % old code?
    saefs



    numerator = 4;
    prop = 10;
    fr_max = 130;
    fr_min = 0;
    fr_step = 10;
    range = fr_max/prop*numerator;
    %
    figuren;
    % offer1 onset
    nsubplot(2, 4, 1, 1);
    hold on
    z = timetargeton_N;
    min_time = -100;
    max_time = 500;

    plot([0 0], [fr_min fr_max], '-k')
    plot([min_time max_time], [0 0], '-k')
    % Rasters of chosenfirst trials
    Rasterlength = range/(numel(ChoseFirst) + numel(ChoseSecond));
    [trialn, epoch] = find(Rasters{z}(ChoseFirst, min_time + CENTER : CENTER + max_time)); % check if trial number of Rasters is right order
    plot([(epoch + min_time)' ; (epoch + min_time)'],...
        [(fr_max-Rasterlength*(trialn-1))' ;...
        (fr_max-Rasterlength*trialn)'], 'k-', 'LineWidth', 2)
    % Rasters of chosensecound trials
    [trialn, epoch] = find(Rasters{z}(ChoseSecond, min_time + CENTER : CENTER + max_time)); % check if trial number of Rasters is right order
    plot([(epoch + min_time)' ; (epoch + min_time)'],...
        [(fr_max-Rasterlength*(numel(ChoseFirst) + trialn-1))' ;...
        (fr_max-Rasterlength*(numel(ChoseFirst) + trialn))'], 'r-', 'LineWidth', 2)
    % SDFs
    a = mean(SDFcs_n{z}(ChoseFirst, min_time + CENTER : CENTER + max_time),1);
    b = mean(SDFcs_n{z}(ChoseSecond, min_time + CENTER : CENTER + max_time),1);
    plot(min_time:max_time, a,'Color', 'k', 'LineWidth', 1.7)
    plot(min_time:max_time, b,'Color', 'r', 'LineWidth', 1.7)

    hold off
    axis([min_time max_time fr_min fr_max])
    ylabel(' firing rate', 'fontsize', 10)
    set(gca, 'tickdir', 'out', 'ticklength', [0.03 0.025], 'xtick', -200:200:1000, 'ytick', 0:fr_step:500,'FontName', 'Arial', 'fontsize', 10)
    title('Offer1', 'fontsize', 10)

    % offer2 onset
    nsubplot(2, 4, 1, 2);
    hold on
    z = timetargeton2_N;
    min_time = -100;
    max_time = 500;

    plot([0 0], [fr_min fr_max], '-k')
    plot([min_time max_time], [0 0], '-k')
    % Rasters
    Rasterlength = range/(numel(ChoseFirst) + numel(ChoseSecond));
    [trialn, epoch] = find(Rasters{z}(ChoseFirst, min_time + CENTER : CENTER + max_time)); % check if trial number of Rasters is right order
    plot([(epoch + min_time)' ; (epoch + min_time)'],...
        [(fr_max-Rasterlength*(trialn-1))' ;...
        (fr_max-Rasterlength*trialn)'], 'k-', 'LineWidth', 2)
    [trialn, epoch] = find(Rasters{z}(ChoseSecond, min_time + CENTER : CENTER + max_time)); % check if trial number of Rasters is right order
    plot([(epoch + min_time)' ; (epoch + min_time)'],...
        [(fr_max-Rasterlength*(numel(ChoseFirst) + trialn-1))' ;...
        (fr_max-Rasterlength*(numel(ChoseFirst) + trialn))'], 'r-', 'LineWidth', 2)
    clear a b
    a = mean(SDFcs_n{z}(ChoseFirst, min_time + CENTER : CENTER + max_time),1);
    b = mean(SDFcs_n{z}(ChoseSecond, min_time + CENTER : CENTER + max_time),1);
    plot(min_time:max_time, a,'Color', 'k', 'LineWidth', 1.7)
    plot(min_time:max_time, b,'Color', 'r', 'LineWidth', 1.7)

    hold off
    axis([min_time max_time fr_min fr_max])
    ylabel(' firing rate', 'fontsize', 10)
    set(gca, 'tickdir', 'out', 'ticklength', [0.03 0.025], 'xtick', -200:200:1000, 'ytick', 0:fr_step:500,'FontName', 'Arial', 'fontsize', 10)
    title('Offer2', 'fontsize', 10)

    % laser onset
    nsubplot(2, 4, 1, 3);
    hold on
    z = timeLaser_N;
    min_time = -100;
    max_time = 500;

    plot([0 0], [fr_min fr_max], '-k')
    plot([min_time max_time], [0 0], '-k')
    % Rasters
    Rasterlength = range/(numel(ChoseFirst) + numel(ChoseSecond));
    [trialn, epoch] = find(Rasters{z}(ChoseFirst, min_time + CENTER : CENTER + max_time)); % check if trial number of Rasters is right order
    plot([(epoch + min_time)' ; (epoch + min_time)'],...
        [(fr_max-Rasterlength*(trialn-1))' ;...
        (fr_max-Rasterlength*trialn)'], 'k-', 'LineWidth', 2)
    [trialn, epoch] = find(Rasters{z}(ChoseSecond, min_time + CENTER : CENTER + max_time)); % check if trial number of Rasters is right order
    plot([(epoch + min_time)' ; (epoch + min_time)'],...
        [(fr_max-Rasterlength*(numel(ChoseFirst) + trialn-1))' ;...
        (fr_max-Rasterlength*(numel(ChoseFirst) + trialn))'], 'r-', 'LineWidth', 2)
    clear a b
    a = mean(SDFcs_n{z}(ChoseFirst, min_time + CENTER : CENTER + max_time),1);
    b = mean(SDFcs_n{z}(ChoseSecond, min_time + CENTER : CENTER + max_time),1);
    plot(min_time:max_time, a,'Color', 'k', 'LineWidth', 1.7)
    plot(min_time:max_time, b,'Color', 'r', 'LineWidth', 1.7)

    hold off
    axis([min_time max_time fr_min fr_max])
    ylabel(' firing rate', 'fontsize', 10)
    set(gca, 'tickdir', 'out', 'ticklength', [0.03 0.025], 'xtick', -200:200:1000, 'ytick', 0:fr_step:500,'FontName', 'Arial', 'fontsize', 10)
    title('Laser On', 'fontsize', 10)

    % reward onset
    nsubplot(2, 4, 1, 4);
    hold on
    z = timereward_N;
    min_time = -100;
    max_time = 500;

    plot([0 0], [fr_min fr_max], '-k')
    plot([min_time max_time], [0 0], '-k')
    % Rasters
    Rasterlength = range/(numel(ChoseFirst) + numel(ChoseSecond));
    [trialn, epoch] = find(Rasters{z}(ChoseFirst, min_time + CENTER : CENTER + max_time)); % check if trial number of Rasters is right order
    plot([(epoch + min_time)' ; (epoch + min_time)'],...
        [(fr_max-Rasterlength*(trialn-1))' ;...
        (fr_max-Rasterlength*trialn)'], 'k-', 'LineWidth', 2)
    [trialn, epoch] = find(Rasters{z}(ChoseSecond, min_time + CENTER : CENTER + max_time)); % check if trial number of Rasters is right order
    plot([(epoch + min_time)' ; (epoch + min_time)'],...
        [(fr_max-Rasterlength*(numel(ChoseFirst) + trialn-1))' ;...
        (fr_max-Rasterlength*(numel(ChoseFirst) + trialn))'], 'r-', 'LineWidth', 2)
    clear a b
    a = mean(SDFcs_n{z}(ChoseFirst, min_time + CENTER : CENTER + max_time),1);
    b = mean(SDFcs_n{z}(ChoseSecond, min_time + CENTER : CENTER + max_time),1);
    plot(min_time:max_time, a,'Color', 'k', 'LineWidth', 1.7)
    plot(min_time:max_time, b,'Color', 'r', 'LineWidth', 1.7)

    hold off
    axis([min_time max_time fr_min fr_max])
    ylabel(' firing rate', 'fontsize', 10)
    set(gca, 'tickdir', 'out', 'ticklength', [0.03 0.025], 'xtick', -200:200:1000, 'ytick', 0:fr_step:500,'FontName', 'Arial', 'fontsize', 10)
    title('Reward On', 'fontsize', 10)

end

    
    set(gcf,'Position',[1 41 2560 1484],'Paperposition',[0 0 26.6667 15.4583], 'Paperpositionmode','auto','Papersize',[26.6667 15.4583]);  % sets the size of the figure and orientation
print('-dpdf', 'suaEx2' ); 
