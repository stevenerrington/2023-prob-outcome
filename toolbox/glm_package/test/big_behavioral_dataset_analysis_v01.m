% add path to include necessary files for Ethan's analysis code
% NOTE: not sure if this will work on your computer. I tried to write
% this line so if you are in the current directory (Dropbox/LASER/Ilya) 
% it should add the correct path whether you are on Mac or PC.
addpath(fullfile('.','ethan_dependencies')); 

do_load_and_calc = 1;
do_plot = 1;

if do_load_and_calc
    % load the big behavioral datasets and fit the subjective value model

    bbd = struct();
 %   bbd.datafile_dir = '/Users/Ilya/Dropbox/LASER/Ilya/';
  bbd.datafile_dir = ' '; %'C:\Users\Ilya Monosov\Dropbox\LASER\Ilya\';


    bbd.monk.name = {'slayer','sabbath','combined'};
    bbd.monk.n = numel(bbd.monk.name);
    bbd.monk.sva = cell(1,bbd.monk.n); % subjective value analysis

    for mi = 1:bbd.monk.n
        monkname = bbd.monk.name{mi};
        bbd.monk.datafile_name{mi} = sprintf('%sChoiceOnly.mat',monkname);

        rawbehav = load([bbd.monk.datafile_name{mi}]);
        bbd.monk.sva{mi} = aatradeoff_subjective_value_analysis_v01(rawbehav.choices);
    end
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
