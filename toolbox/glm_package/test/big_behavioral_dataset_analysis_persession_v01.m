% add path to include necessary files for Ethan's analysis code
% NOTE: not sure if this will work on your computer. I tried to write
% this line so if you are in the current directory (Dropbox/LASER/Ilya) 
% it should add the correct path whether you are on Mac or PC.
addpath(fullfile('.','ethan_dependencies')); 

do_load_and_calc = 1;
do_plot = 1;
do_save = 0;

if do_load_and_calc
    % load the big behavioral datasets and fit the subjective value model

    bbd = struct();
 %   bbd.datafile_dir = '/Users/Ilya/Dropbox/LASER/Ilya/';
  bbd.datafile_dir = ' '; %'C:\Users\Ilya Monosov\Dropbox\LASER\Ilya\';


    bbd.monk.name = {'slayer','sabbath','combined'};
    bbd.monk.n = numel(bbd.monk.name);
    bbd.monk.sva = cell(1,bbd.monk.n); % subjective value analysis
    
    bbd.monk.persession.sva = cell(1,bbd.monk.n);

    curtimer = tic;
    fprintf(' (%7d s) starting big behavioral dataset analysis persession!\n',round(toc(curtimer)));
    
    for mi = 1:bbd.monk.n
        monkname = bbd.monk.name{mi};
        bbd.monk.datafile_name{mi} = sprintf('%sChoiceOnly.mat',monkname);

        fprintf(' (%7d s) monk %2d, loading "%s"\n',round(toc(curtimer)),mi,bbd.monk.datafile_name{mi});
        rawbehav = load([bbd.monk.datafile_name{mi}]);
        
        fprintf(' (%7d s) monk %2d, fitting ALL behav data (n=%5d trials)\n',round(toc(curtimer)),mi,size(rawbehav.choices,1));
        bbd.monk.sva{mi} = aatradeoff_subjective_value_analysis_v01(rawbehav.choices);
        
        col_sess = 6;
        assert(size(rawbehav.choices,2) >= col_sess);
        tr_sessid = rawbehav.choices(:,col_sess);
        nsess = max(tr_sessid);
        bbd.monk.persession.sva{mi} = cell(1,nsess);
        for sessi = 1:nsess
            oksess = tr_sessid == sessi;
            assert(sum(oksess) > 10);
            fprintf(' (%7d s) monk %2d, fitting sess %3d/%3d (n=%5d trials)\n',round(toc(curtimer)),mi,sessi,nsess,sum(oksess));
            bbd.monk.persession.sva{mi}{sessi} = aatradeoff_subjective_value_analysis_v01(rawbehav.choices(oksess,1:5));
        end
    end
end

if do_save
    savefilename = [mfilename() '_' char(datetime('now','format','yyyy_MM_dd_HH_mm_ss')) '.mat'];
    save_in_preferred_format_if_possible(savefilename,'bbd');
end

if do_plot
    % NEW plot of per-session results
    if 1
        % R2, R3, R4 (R5 for slayer)
        % P2, P3 (P4 for sabbath)
        
        figuren;
        h = [];
        
        
        nrow = bbd.monk.n;
        ncol = 4;
        
        for mi = 1:bbd.monk.n
            
            if 0
                % model 1: linear weight of rew and pun
                modi = 1;
                h(mi,1) = nsubplot(nrow,ncol,mi,1);
                title(sprintf('monk %d (%s)',mi,bbd.monk.name{mi}));

                cursva = bbd.monk.persession.sva{mi};
                nsess = numel(cursva);

                % fitted weights of rew and pun
                brp_mu = nans(nsess,2);
                brp_se = nans(nsess,2); 
                brp_p = nans(nsess,2);
                for sessi = 1:nsess
                    fit = cursva{sessi}.model.analysis{modi}.behav_full_fit;
                    brp_mu(sessi,:) = fit.stats.beta(1:2);
                    brp_se(sessi,:) = fit.stats.se(1:2);
                    brp_p(sessi,:)  = fit.stats.p(1:2);
                end

                linex(0,'k');
                liney(0,'k');
                xlim([-0.5 +3]);
                ylim([-.6 +.2]);
                xlabel('R (log odds)');
                ylabel('P (log odds)');
                axis square;
                plot_scatter_sig(brp_mu(:,1),brp_mu(:,2),brp_p(:,1)<0.05,brp_p(:,2)<0.05,'auto','errorbar',{brp_mu(:,1)+[-1 1].*brp_se(:,1),brp_mu(:,2)+[-1 1].*brp_se(:,2)});
                
                col_offset = 1;
            end
            col_offset = 0;
            
            
            % model 2: nonlinear weight of rew and pun
            modi = 2;
            comps = { ...
                {'R2','R3'}, ...
                {'P2','P3'}, ...
                };
            for compi = 1:numel(comps)

                coli = col_offset + compi;
                
                h(mi,coli) = nsubplot(nrow,ncol,mi,coli);
                title(sprintf('monk %d (%s)',mi,bbd.monk.name{mi}));

                cursva = bbd.monk.persession.sva{mi};
                nsess = numel(cursva);

                % fitted weights of rew and pun
                
                brp_mu = nans(nsess,2);
                brp_se = nans(nsess,2); 
                brp_p = nans(nsess,2);
                brp_dif = nans(nsess,1);
                brp_dif_p = nans(nsess,1);
                for sessi = 1:nsess
                    fit = cursva{sessi}.model.analysis{modi}.behav_full_fit;
                    
                    xi1 = find(strcmp(fit.xname,comps{compi}{1}));
                    xi2 = find(strcmp(fit.xname,comps{compi}{2}));
                    assert(numel(xi1) == 1 && numel(xi2) == 1);
                    xi = [xi1 xi2];
                    
                    brp_mu(sessi,:) = fit.stats.beta(xi);
                    brp_se(sessi,:) = fit.stats.se(xi);
                    brp_p(sessi,:)  = fit.stats.p(xi);
                    
                    brp_dif(sessi) = brp_mu(sessi,2) - brp_mu(sessi,1);
                    hypoth = zeros(fit.nx,1);
                    hypoth(xi2) = +1;
                    hypoth(xi1) = -1;
                    brp_dif_p(sessi) = linhyptest(fit.stats.beta,fit.stats.covb,0,hypoth',fit.stats.dfe);
                end
                
                % remove the few sessions that have extremely noisy fits
                badsess = any(brp_se > 5,2);
                fprintf(' comparison %d, removing %d "bad" sessions (e.g. noisy param estimates)\n',compi,sum(badsess));
                brp_mu = brp_mu(~badsess,:);
                brp_se = brp_se(~badsess,:);
                brp_p  = brp_p(~badsess,:);
                brp_dif = brp_dif(~badsess,:);
                brp_dif_p = brp_dif_p(~badsess,:);
                
                
                % same as above, but in pooled fit to full behav dataset
                fit = bbd.monk.sva{mi}.model.analysis{modi}.behav_full_fit;

                xi1 = find(strcmp(fit.xname,comps{compi}{1}));
                xi2 = find(strcmp(fit.xname,comps{compi}{2}));
                assert(numel(xi1) == 1 && numel(xi2) == 1);
                xi = [xi1 xi2];

                brp_pool_mu = fit.stats.beta(xi);
                brp_pool_se = fit.stats.se(xi);
                brp_pool_p  = fit.stats.p(xi);

                brp_pool_dif = brp_pool_mu(2) - brp_pool_mu(1);
                hypoth = zeros(fit.nx,1);
                hypoth(xi2) = +1;
                hypoth(xi1) = -1;
                brp_pool_dif_p = linhyptest(fit.stats.beta,fit.stats.covb,0,hypoth',fit.stats.dfe);

                

                linex(0,'k');
                liney(0,'k');
                linexy('k');
                xlabel(sprintf('%s (log odds)',comps{compi}{1}));
                ylabel(sprintf('%s (log odds)',comps{compi}{2}));
                axis square;
                
                plot_scatter_sig(brp_mu(:,1),brp_mu(:,2),brp_p(:,1)<0.05,brp_p(:,2)<0.05,'auto','errorbar',{brp_mu(:,1)+[-1 1].*brp_se(:,1),brp_mu(:,2)+[-1 1].*brp_se(:,2)});
                setlim(gca,'xlim','tight',.1);
                setlim(gca,'ylim','tight',.1);
                curlim = [min([min(xlim) min(ylim)]) max([max(xlim) max(ylim)])];
                axis([curlim curlim]);
                
                h(mi,coli + 2) = nsubplot(nrow,ncol,mi,coli + 2);
                title(sprintf('monk %d (%s)',mi,bbd.monk.name{mi}));
                
                switch compi
                    case 1
                        xedge = -5:0.5:5;
                    case 2
                        xedge = -2.5:0.25:2.5;
                    otherwise
                        error('unknown comp');
                end
                sig = brp_dif_p < 0.05;
                plot_hist(brp_dif,xedge,[1 1 1]*.8,'outline',[1 1 1]*.4,'edgecolor','none');
                if any(sig)
                    plot_hist(brp_dif(sig),xedge,'k','outline','k','edgecolor','none');
                end
                linex(0,'k','linewidth',2);
                
                brp_dif_pop_mean = mean(brp_dif);
                brp_dif_pop_se = sem(brp_dif);
                brp_dif_pop_p = signrank(brp_dif);
                
                %etextn('lt',sprintf('mean %.2f\nse %.2f\np %.4f',brp_dif_pop_mean,brp_dif_pop_se,brp_dif_pop_p));
                etextn('lt',sprintf('PER-SESSION FITS (n=%d "good"/%d total):\nmean %.2f\nse %.2f\np %.4f\nPOOLED FIT:\nmean %.2f\np %.4f', ...
                    size(brp_dif,1),nsess,brp_dif_pop_mean,brp_dif_pop_se,brp_dif_pop_p, ...
                    brp_pool_dif,brp_pool_dif_p));
                
                setlim(gca,'ymin',0);
                setlim(gca,'ymax','tight',.1);
                xlim(xedge([1 end]));
                
                xlabel(sprintf('%s - %s (log odds)',comps{compi}{2},comps{compi}{1}));
            end
            setlim(h(mi,end-1:end),'ymax','tight',.1);
        end
        
        drawnow;
        scale(gcf,'hvscale',[2.5 2.5]);
    end
    
    % OLD plot of overall results
    if 0
        
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
end
