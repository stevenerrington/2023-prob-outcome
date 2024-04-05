function plot_probrwddelay_glm_raw_uncorr(glm_out)

figuren('Renderer', 'painters', 'Position', [100 300 700 750]);


count = 0;
for delay_val = [0, 5, 10, -5]
    count = count + 1;
    nsubplot(4,4,1,count);
    eglm_plot_fit(glm_out,'params',...
        { ['1,1,0,' int2str(delay_val)],['1,1,5,' int2str(delay_val)],...
       ['1,1,-5,' int2str(delay_val)],['1,1,10,' int2str(delay_val)]});

    nsubplot(4,4,2,count);
    eglm_plot_fit(glm_out,'params',...
        { ['2,1,0,' int2str(delay_val)],['2,1,5,' int2str(delay_val)],...
       ['2,1,-5,' int2str(delay_val)],['2,1,10,' int2str(delay_val)]});

    nsubplot(4,4,3,count);
    eglm_plot_fit(glm_out,'params',...
        { ['1,2,0,' int2str(delay_val)],['1,2,5,' int2str(delay_val)],...
       ['1,2,-5,' int2str(delay_val)],['1,2,10,' int2str(delay_val)]});

    nsubplot(4,4,4,count);
    eglm_plot_fit(glm_out,'params',...
        { ['2,2,0,' int2str(delay_val)],['2,2,5,' int2str(delay_val)],...
       ['2,2,-5,' int2str(delay_val)],['2,2,10,' int2str(delay_val)]});    
end

%% Labels
for subplot = 1:16
    nsubplot(4,4,1,subplot);
    ylabel(''); ylim([- 1 2.0])
end

for subplot = [1:3,5:7,9:11,13:15]
    nsubplot(4,4,1,subplot);
    xticklabels({'Small','Medium','Uncertain','Large'})
end

nsubplot(4,4,1,4);
xticklabels({'Short','Medium','Long'})
nsubplot(4,4,2,4);
xticklabels({'Short','Medium','Long'})

%% Titles
nsubplot(4,4,1,1); title('Short Delay')
nsubplot(4,4,1,2); title('Medium Delay')
nsubplot(4,4,1,3); title('Large Delay')
nsubplot(4,4,1,4); title('Uncertain Delay')

nsubplot(4,4,1,1); ylabel({'Offer 1: Reward - Delay';'Offer 2: Reward - Delay'})
nsubplot(4,4,2,1); ylabel({'Offer 1: Delay - Reward';'Offer 2: Reward - Delay'})
nsubplot(4,4,3,1); ylabel({'Offer 1: Reward - Delay';'Offer 2: Delay - Reward'})
nsubplot(4,4,4,1); ylabel({'Offer 1: Delay - Reward';'Offer 2: Delay - Reward'})

end