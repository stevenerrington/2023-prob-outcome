function plot_probrwddelay_glm_raw(glm_out)

figuren('Renderer', 'painters', 'Position', [100 300 700 750]);

count = 0;
for rwd_val = [0, 5, 10, -5]
    count = count + 1;
    nsubplot(4,4,1,count);
    eglm_plot_fit(glm_out,'params',...
        { ['1,' int2str(rwd_val) ',0'],['1,' int2str(rwd_val) ',5'],...
        ['1,' int2str(rwd_val) ',-5'],['1,' int2str(rwd_val) ',10']});

 nsubplot(4,4,2,count);
    eglm_plot_fit(glm_out,'params',...
        { ['2,' int2str(rwd_val) ',0'],['2,' int2str(rwd_val) ',5'],...
        ['2,' int2str(rwd_val) ',-5'],['2,' int2str(rwd_val) ',10']});
    
end

count = 0;
for delay_val = [0, 5, 10, -5]
    count = count + 1;
    nsubplot(4,4,3,count);
    eglm_plot_fit(glm_out,'params',...
        { ['1,0,' int2str(delay_val)],['1,5,' int2str(delay_val)],...
       ['1,-5,' int2str(delay_val)],['1,10,' int2str(delay_val)]});

 nsubplot(4,4,4,count);
    eglm_plot_fit(glm_out,'params',...
        { ['2,0,' int2str(delay_val)],['2,5,' int2str(delay_val)],...
       ['2,-5,' int2str(delay_val)],['2,10,' int2str(delay_val)]});
    
end

%% Labels
for subplot = 1:16
    nsubplot(4,4,1,subplot);
    ylabel(''); ylim([- 1 1.5])
end

for subplot = [1:3,5:7]
    nsubplot(4,4,1,subplot);
    xticklabels({'Short','Medium','Uncertain','Long'})
end

nsubplot(4,4,1,4);
xticklabels({'Short','Medium','Long'})
nsubplot(4,4,2,4);
xticklabels({'Short','Medium','Long'})

for subplot = [9:12,14:16]
    nsubplot(4,4,1,subplot);
    xticklabels({'Small','Medium','Uncertain','Large'})
end

nsubplot(4,4,3,4);
xticklabels({'Small','Medium','Large'})
nsubplot(4,4,4,4);
xticklabels({'Small','Medium','Large'})
%% Titles
nsubplot(4,4,1,1); title('Small Reward')
nsubplot(4,4,1,2); title('Medium Reward')
nsubplot(4,4,1,3); title('Large Reward')
nsubplot(4,4,1,4); title('Uncertain Reward')

nsubplot(4,4,1,9); title('Short Delay')
nsubplot(4,4,1,10); title('Medium Delay')
nsubplot(4,4,1,11); title('Large Delay')
nsubplot(4,4,1,12); title('Uncertain Delay')

nsubplot(4,4,1,1); ylabel('Reward -> Delay')
nsubplot(4,4,2,1); ylabel('Delay -> Reward')
nsubplot(4,4,3,1); ylabel('Reward -> Delay')
nsubplot(4,4,4,1); ylabel('Delay -> Reward')

end