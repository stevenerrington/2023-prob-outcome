% add path to include necessary files for Ethan's analysis code
% NOTE: not sure if this will work on your computer. I tried to write
% this line so if you are in the current directory (Dropbox/LASER/Ilya) 
% it should add the correct path whether you are on Mac or PC.
addpath(fullfile('.','ethan_dependencies')); 

do_load_and_calc = 1;
do_save = 1;
do_plot = 1;

if do_load_and_calc
    % load the big behavioral datasets and fit the subjective value model

    bbd = struct();
    %bbd.datafile_dir = '/Users/Ilya/Dropbox/LASER/Ilya/';
    bbd.datafile_dir = 'C:\Users\Ilya Monosov\Dropbox\LASER\Ilya\';

    % output file where we save the results
    bbd.output_filename = [mfilename() '.mat'];

    bbd.monk.name = {'slayer','sabbath'};
    bbd.monk.input_savedatafilename = {'savedata_slayerchoice.mat','savedata_sabbathchoice.mat'};
    bbd.monk.n = numel(bbd.monk.name);
    bbd.monk.choices = cell(1,bbd.monk.n); % raw choice data used for analysis
    bbd.monk.sva = cell(1,bbd.monk.n); % subjective value analysis
    

    for mi = 1:bbd.monk.n
        monkname = bbd.monk.name{mi};
        
        fprintf('loading "%s"\n',bbd.monk.input_savedatafilename{mi});
        load(bbd.monk.input_savedatafilename{mi});
        
        % get basic stats of per-unit behavioral data
        nunits = numel(savedata);
        unit_sess = nan*ones(nunits,1);
        unit_ntrials = nan*ones(nunits,1);
        unit_noktrials = nan*ones(nunits,1);
        for ui = 1:numel(savedata)
            curchoices = savedata(ui).choices;
            
            cursess = curchoices(:,6);
            cursess = unique(cursess);
            assert(numel(cursess)==1);
            
            unit_sess(ui) = cursess;
            unit_ntrials(ui) = size(curchoices,1);
            % only use 'ok' trials (e.g. ones without NaNs)
            oktr = ~any(isnan(curchoices),2);
            unit_noktrials(ui) = sum(oktr);
        end
        
        % as discussed with Ilya, use a simple hack for now - for each
        % session, only use behav data from the cell with the highest
        % number of trials. In future, we should just use all behav data
        % from the session.
        nsess = max(unit_sess);
        unit_to_use_for_each_sess = nan*ones(nsess,1);
        for sessi = 1:nsess
            if ~any(unit_sess == sessi)
                error('did not find any units for session %d',sessi);
            end
            oksess = unit_sess == sessi;
            unit_to_use_for_each_sess(sessi) = find(oksess & unit_noktrials == max(unit_noktrials(oksess)),1);
        end
        
        % make big choice matrix with all the choice data from those cells
        choices = [];
        for sessi = 1:nsess
            ui = unit_to_use_for_each_sess(sessi);
            curchoices = savedata(ui).choices;
            oktr = ~any(isnan(curchoices),2);
            choices = [choices ; savedata(ui).choices(oktr,:)];
        end
        bbd.monk.choices{mi} = choices;
        
        % do subjective value analysis on it
        % (only pass in the part of the choice matrix with behavioral data,
        % since other columns might otherwise be treated as e.g. neural
        % data)
        sva = aatradeoff_subjective_value_analysis_v03(choices(:,1:5));
        bbd.monk.sva{mi} = sva;
    end
end

if do_save
    fprintf('saving "%s"\n',bbd.output_filename);
    save(bbd.output_filename,'bbd');
end

if do_plot
    
    figuren;
    h = [];
    for mi = 1:bbd.monk.n
        modan = bbd.monk.sva{mi}.model;
        
        for modi = 1:modan.n
            bfit = modan.analysis{modi}.behav_full_fit;
            
            h(mi,modi)=nsubplot(bbd.monk.n,modan.n,mi,modi);
            title(sprintf('Animal "%s"\nmodel "%s"',bbd.monk.name{mi},modan.name{modi}));
            
            eglm_plot_fit(bfit,'axes',h(mi,modi));
        end
    end
end




% set(gcf,'Position',[1 41 2560 1484],'Paperposition',[0 0 26.6667 15.4583], 'Paperpositionmode','auto','Papersize',[26.6667 15.4583]);  % sets the size of the figure and orientation
% 
%  print('-dpdf', [GLMmonkeys '.pdf']);








