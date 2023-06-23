function sva = aatradeoff_subjective_value_analysis_v01(choice_and_neural,varargin)
% appetitive-aversive tradeoff subjective value analysis
% original version by ESBM 2021-10-04
%
% Required input: 
%  choice_and_neural = matrix of choices and neural data, in the following format:
%
%   Col 1 - offer 1 reward size
%   Col 2 - offer 1 punishment size
%   Col 3 - offer 2 reward size
%   Col 4 - offer 2 punishment size
%   Col 5 - choice (1, 2, or NaN)
%
%  (the following columns are optional; if not included, only does neural analysis)
%   Col 6 - firing rate response to offer 1
%   Col 7 - firing rate response to offer 2
%
%  (the following columns are optional, and are not used by this function)
%   Col 8 - "loop number" ~ neuron number
%   Col 9 - session number
%   Col 10 - trial number in session
%
% Optional inputs (using variable argument list):
%  'plot',0 = (default) do not create a plot of the results
%  'plot',1 = create simple data plots of the results


do_plot = 0;

vi = 1;
while vi <= numel(varargin)
    if ischar(varargin{vi}) && strcmp(varargin{vi},'plot')
        assert(numel(varargin) >= vi+1,'expected argument to "plot" saying whether or not to do plotting!');
        do_plot = varargin{vi+1};
        vi = vi + 2;
    else
        error('unknown variable arguments!');
    end
end

% pad with NaNs if missing neuronal/other parts of the data
% so that e.g. if there is ONLY behavioral data, we can still fit the
% behavioral model, while skipping the neuronal model
expected_max_ncols = 10;
if size(choice_and_neural,2) < expected_max_ncols
    choice_and_neural(:,(size(choice_and_neural,2)+1):expected_max_ncols) = NaN;
end

choices = choice_and_neural(:,1:5);
neural_offer_response = choice_and_neural(:,6:7);

% remove trials with NaN choice
oktr = ~isnan(choices(:,5));
choices = choices(oktr,:);
neural_offer_response = neural_offer_response(oktr,:);
assert(~any(isnan(choices(:))));

% off1 = offer 1 rew, pun
% off2 = offer 2 rew, pun
% cho = choice
off1 = choices(:,[1 2]);
off2 = choices(:,[3 4]);
off = cat(3,off1,off2);
cho = choices(:,5);
assert(all(ismember(cho,[1 2])),'expected all choices to be of offer 1 or 2');

% unique rew, pun settings
urew = unique([off1(:,1) ; off2(:,1)]);
upun = unique([off1(:,2) ; off2(:,2)]);

% list of all unique combos = combinations of (rew,pun)
combo_all_rew_pun = []; % matrix holding rew,pun amounts for each unique combo
combo_all_rew_pun_index = []; % matrix holding INDEXES of unique rew,pun amounts (e.g. rew index of 1 = lowest possible reward)
% which combo is present in each offer in the data?
off_combo_index = nans(size(off,1),2);
for uri = 1:numel(urew)
    for upi = 1:numel(upun)
        combo_all_rew_pun(end+1,:) = [urew(uri) upun(upi)];
        combo_all_rew_pun_index(end+1,:) = [uri upi];
        
        % for each offer, get which rew,pun combo it is
        cur_combo_index = size(combo_all_rew_pun,1);
        off_combo_index(all(off(:,:,1)==combo_all_rew_pun(end,:),2),1) = cur_combo_index;
        off_combo_index(all(off(:,:,2)==combo_all_rew_pun(end,:),2),2) = cur_combo_index;
    end
end

combo_n = zeros(size(combo_all_rew_pun,1),2);
for ci = 1:size(combo_all_rew_pun,1)
    for oi = 1:2
        combo_n(ci,oi) = sum(all(off(:,:,oi) == combo_all_rew_pun(ci,:),2));
    end
end
%assert(all(combo_n(:) > 0),'did not detect at least one instance of each possible offer (rew,pun) combo for both offer1 and offer2. This is not strictly necessary for analysis, though, so maybe you can continue despite this.');


% for plotting
color_rew = 'r';
color_pun = 'b';
color_bias = [1 1 1]*.2;

% for analysis

% create output data structure
sva = struct();

% raw data
sva.dat.choice_and_neural = choice_and_neural;

% which trials we selected as 'ok' to use for analysis
sva.dat.oktr = oktr;

% the offer/choice data, and neural data, from those trials
sva.dat.choices = choices;
sva.dat.neural_offer_response = neural_offer_response;

% unique rew and pun levels
sva.dat.urew = urew;
sva.dat.upun = upun;
% list of all possible unique (rew,pun) combos
sva.dat.combo_all_rew_pun = combo_all_rew_pun;
sva.dat.combo_all_rew_pun_index = combo_all_rew_pun_index;
% which offer is which (rew,pun) combo
sva.dat.off_combo_index = off_combo_index;
% how many times each (rew,pun) combo occurs in the data (separately for offer1 and offer2)
sva.dat.combo_n = combo_n;

sva.param.n_crossvalidation_folds = 10;
sva.param.do_behavioral_analysis = true;
sva.param.do_neural_analysis = NaN;

% models to fit to the behavioral data
sva.model.name = {'linear indep','nonlinear indep','nonlinear joint'};
sva.model.n = numel(sva.model.name);
sva.model.analysis = cell(1,sva.model.n);


xval_args = {'crossvalidation',sva.param.n_crossvalidation_folds};

for modi = 1:sva.model.n
    modname = sva.model.name{modi};

    yreg = struct('name','chose off2','value',cho==2);
    
    assert(sva.param.do_behavioral_analysis);
    
    switch modname
        case 'linear indep'
            % fit model that assumes rew and pun have independent, additive effects
            % on value. Then estimate SV of one unit of pun in equivalent units of rew
            rew_amount = squeeze(off(:,1,:)); % Ntrials x Noffers matrix of reward amounts
            pun_amount = squeeze(off(:,2,:)); % Ntrials x Noffers matrix of punishment amounts
            
            rew_regressor = rew_amount;
            pun_regressor = pun_amount;

            % create 'x' regressors for the fit
            % IMPORTANT: here I set them as 'flag' variables so they are used directly
            % unchanged by the fit. Otherwise they would be automatically z-scored,
            % which we don't want here (since we are doing any normalization ourselves,
            % with the code above)
            xreg = {};
            xreg{end+1} = struct('name','R','terms',{{'flag',rew_regressor}},'color',color_rew); % effect of reward
            xreg{end+1} = struct('name','P','terms',{{'flag',pun_regressor}},'color',color_pun); % effect of punishment

            % bias term for choice bias toward offer 2 (relative to offer 1)
            xreg{end+1} = struct('name','const','terms',{{'flag',[zeros(size(off,1),1) ones(size(off,1),1)]}},'color',color_bias); 
            % NOTE: ideally should also add location-bias term(s) here as well, to 
            % improve the signal-to-noise of estimating the rew/pun-related terms

            % for calculating per-offer subjective values, considering:
            % 'all' - ALL regressors
            % 'value' - just "value"-related regressors
            % 'rewvalue' - just reward ones
            % 'punvalue' - just pun-related ones
            % 'bias' - just "bias"-related regressors
            xnames = cellfun(@(z) z.name,xreg,'uniform',0);
            xnames_value = setdiff(xnames,'const');
            xnames_bias = {'const'};
            peroffer_effects_to_calculate = struct('all','*','value',{xnames_value},'rewvalue',{{'R'}},'punvalue',{{'P'}},'bias',{xnames_bias});
            peroffer_args = {'calculate per-offer effects',peroffer_effects_to_calculate};

            % do the fit, then rescale all weights based on the fitted effect of reward
            %fit_rescaled = eglm_fit(xreg,yreg,'binary choices',xval_args{:},'rescale betas',struct('name','Effect relative to 1 unit of R','xreg_name','R','xreg_change',1),peroffer_args{:});
            
        case 'nonlinear indep'
            % separate weights for each possible reward magnitude and
            % punishment magnitude (EXCEPT the smallest, since these are
            % all modeled as values RELATIVE to each other, one has to be
            % arbitrarily set to 0 to be the reference/baseline for all the
            % others)
            xreg = {};
            for uri = 1:numel(urew)
                if uri > 1
                    xreg{end+1} = struct('name',sprintf('R%d',uri),'terms',{{'flag',squeeze(off(:,1,:))==urew(uri)}}, ...
                        'color',interpcolor(color_rew,'w',1 - uri/numel(urew)));
                end
            end
            for upi = 1:numel(upun)
                if upi > 1
                    xreg{end+1} = struct('name',sprintf('P%d',upi),'terms',{{'flag',squeeze(off(:,2,:))==upun(upi)}}, ...
                        'color',interpcolor(color_pun,'w',1 - upi/numel(upun)));
                end
            end

            % bias term for choice bias toward offer 2 (relative to offer 1)
            xreg{end+1} = struct('name','const','terms',{{'flag',[zeros(size(off,1),1) ones(size(off,1),1)]}},'color',color_bias); 
            % NOTE: ideally should also add location-bias term(s) here as well, to 
            % improve the signal-to-noise of estimating the rew/pun-related terms

            % for calculating per-offer subjective values, considering:
            % 'all' - ALL regressors
            % 'value' - just "value"-related regressors
            % 'rewvalue' - just reward value-related regressors
            % 'punvalue' - just punishment value-related regressors
            % 'bias' - just "bias"-related regressors
            xnames = cellfun(@(z) z.name,xreg,'uniform',0);
            xnames_value = setdiff(xnames,'const');
            xnames_rewvalue = xnames_value(cellfun(@(z) z(1) == 'R',xnames_value)); % only use reward-related regressors
            xnames_punvalue = xnames_value(cellfun(@(z) z(1) == 'P',xnames_value)); % only use punishment-related regressors
            xnames_bias = {'const'};
            peroffer_effects_to_calculate = struct('all','*','value',{xnames_value},'bias',{xnames_bias},'rewvalue',{xnames_rewvalue},'punvalue',{xnames_punvalue});
            peroffer_args = {'calculate per-offer effects',peroffer_effects_to_calculate};

        case 'nonlinear joint'
            % add separate binary flag regressor for each possible (rew,pun) combo
            % (EXCEPT the first one; since they are all modeled as values RELATIVE to
            % each other, one of them has to be arbitrarily set to 0 to be the
            % 'reference/baseline' for all of the others)

            xreg = {};
            for ci = 1:size(combo_all_rew_pun,1)
                if ci > 1
                    xreg{end+1} = struct( ...
                        'name',sprintf('%d,%d',combo_all_rew_pun_index(ci,1),combo_all_rew_pun_index(ci,2)), ...
                        'terms',{{'flag',off_combo_index==ci}}, ...
                        'color', ...
                            0.5*(interpcolor(color_rew,'w',1 - (combo_all_rew_pun_index(ci,1))/numel(urew)) ...
                                 + interpcolor(color_pun,'w',1 - (combo_all_rew_pun_index(ci,2))/numel(upun))) ...
                            );
                end
            end

            % bias term for choice bias toward offer 2 (relative to offer 1)
            xreg{end+1} = struct('name','const','terms',{{'flag',[zeros(size(off,1),1) ones(size(off,1),1)]}},'color',color_bias); 
            % NOTE: ideally should also add location-bias term(s) here as well, to 
            % improve the signal-to-noise of estimating the rew/pun-related terms

            % for calculating per-offer subjective values. We do NOT
            % include separate 'rewvalue' and 'punvalue' terms here,
            % because in this joint model, rew and pun do not have
            % independent effects on value
            xnames = cellfun(@(z) z.name,xreg,'uniform',0);
            xnames_value = setdiff(xnames,'const');
            xnames_bias = {'const'};
            peroffer_effects_to_calculate = struct('all','*','value',{xnames_value},'bias',{xnames_bias});
            peroffer_args = {'calculate per-offer effects',peroffer_effects_to_calculate};

            
        otherwise
            error('unknown model');
    end
    
    % fit behavior
    name_args = {'name',sprintf('behav full fit model %d (%s)',modi,modname)};
    behav_full_fit = eglm_fit(xreg,yreg,'binary choices',name_args{:},xval_args{:},peroffer_args{:});
    
    % analysis of neural offer responses
    % (1) correlate neural offer responses with offer rew value, punishment value, total value
    % (2) fit neural offer responses with diff weights of rew value, punishment value
    % (3) fit neural offer responses as function of offer total value
    
    % save model-based analysis
    modan = struct();
    
    % - behavioral fit
    modan.behav_full_fit = behav_full_fit;
    
    % if have not decided whether to do neural analysis, decide now.
    % do neural analysis if there is any real (non-NaN) neural activity
    if isnan(sva.param.do_neural_analysis)
        sva.param.do_neural_analysis = ~all(isnan(neural_offer_response(:)));
    end
    if sva.param.do_neural_analysis

        % - correlation between neural rates and subjective values
        cur = struct();
        cur.name = {'rewvalue','punvalue','value'}';
        cur.n = numel(cur.name);
        cur.r = nans(cur.n,2);
        cur.rp = nans(cur.n,2);
        cur.rho = nans(cur.n,2);
        cur.rhop = nans(cur.n,2);
        for svi = 1:cur.n
            svname = cur.name{svi};
            if isfield(behav_full_fit.peroffer,svname) % skip if this type of value was not computed for this model
                for oi = 1:2
                    sv = behav_full_fit.peroffer.(svname)(:,oi);
                    [cur.r(svi,oi),cur.rp(svi,oi)] = corr(sv,neural_offer_response(:,oi),'type','Pearson');
                    [cur.rho(svi,oi),cur.rhop(svi,oi)] = corr(sv,neural_offer_response(:,oi),'type','Spearman');
                end
            end
        end
        modan.neural_corr_with_sv = cur;

        % - fit neural activity with the same full model used to fit behavior
        modan.neural_full_fit = cell(1,2);
        for oi = 1:2
            nxreg = xreg;
            for xi = 1:numel(nxreg)
                if strcmp(nxreg{xi}.name,'const')
                    % replace constant factor with a single vector of 1s
                    % representing the mean firing rate in the analysis
                    % window
                    assert(isequaln(nxreg{xi}.terms{1},'flag'));
                    nxreg{xi}.terms{2} = ones(size(nxreg{xi}.terms{2},1),1);
                else
                    % trim down all other terms so they only include the
                    % properties of the currently considered offer
                    for ti = 1:numel(nxreg{xi}.terms)
                        if ~ischar(nxreg{xi}.terms{ti})
                            nxreg{xi}.terms{ti} = nxreg{xi}.terms{ti}(:,oi);
                        end
                    end
                end
            end
            nyreg = struct('name',sprintf('offer %d response',oi),'value',neural_offer_response(:,oi));
            
            name_args = {'name',sprintf('neural full fit model %d (%s), offer %d',modi,modname,oi)};
            modan.neural_full_fit{oi} = eglm_fit(nxreg,nyreg,'normal',name_args{:},xval_args{:},peroffer_args{:});
        end
        
        % - fit neural rates with simple model as a function only of subjective values
        cur = struct();
        cur.name = {'rewandpunvalues','value'}'; % separate weights for rew and pun values? Or just one weight of total value?
        cur.termnames = {{'rewvalue','punvalue'},{'value'}};
        cur.n = numel(cur.name);
        cur.fit = cell(cur.n,2);
        for svi = 1:cur.n
            svname = cur.name{svi};
            termnames = cur.termnames{svi};
            if ~all(isfield(behav_full_fit.peroffer,termnames)) % skip if a necessary type of value was not computed for this model
                continue;
            end
            for oi = 1:2
                nyreg = struct('name',sprintf('offer %d response',oi),'value',neural_offer_response(:,oi));

                nxreg = {};
                for ti = 1:numel(termnames)
                    nxreg{end+1} = struct('name',termnames{ti},'terms',{{behav_full_fit.peroffer.(termnames{ti})(:,oi)}},'normalization','none');
                end
                % constant factor
                nxreg{end+1} = struct('name','const','terms',{{'flag',ones(size(cho,1),1)}},'normalization','none');

                name_args = {'name',sprintf('neural %s fit model %d (%s), offer %d',svname,modi,modname,oi)};
                cur.fit{svi,oi} = eglm_fit(nxreg,nyreg,'normal',name_args{:},xval_args{:});
            end
        end
        modan.neural_value_fit = cur;
    end

    sva.model.analysis{modi} = modan;
    
end
    

if do_plot
    figuren;
    nrow = sva.model.n;
    if sva.param.do_neural_analysis
        ncol = 1 + 2 + 2*numel(sva.model.analysis{1}.neural_value_fit.name) + 1;
    else
        ncol = 1;
    end
    for modi = 1:sva.model.n
        
        hrow = [];
        
        % behav fit
        hrow(1)=nsubplot(nrow,ncol,modi,1);
        title(sprintf('Behav full fit\n'));
        eglm_plot_fit(sva.model.analysis{modi}.behav_full_fit);
        
        ylab = get(gca,'ylabel');
        newlabel = sprintf('Model "%s"\n%s',sva.model.name{modi},ylab.String);
        ylab.String = newlabel;
        set(gca,'ylabel',ylab);
        
        setlim(hrow(1),'ylim','tight',.15,0);
        
        if sva.param.do_neural_analysis
        
            for oi = 1:2
                % neural full fit
                hrow(1+oi)=nsubplot(nrow,ncol,modi,1 + oi);
                title(sprintf('Neural full fit\n(off %d)',oi));
                fit = sva.model.analysis{modi}.neural_full_fit{oi};
                regs_to_plot = fit.xname(~strcmp(fit.xname,'const'));
                eglm_plot_fit(fit,'params',regs_to_plot);

                % neural rewpunvalue fit
                nvf = sva.model.analysis{modi}.neural_value_fit;
                for svi = 1:nvf.n
                    hrow(3+((svi-1)*2) + oi)=nsubplot(nrow,ncol,modi,3+((svi-1)*2) + oi);
                    title(sprintf('Neural %s fit\n(off %d)',nvf.name{svi},oi));
                    fit = sva.model.analysis{modi}.neural_value_fit.fit{svi,oi};
                    if ~isempty(fit)
                        regs_to_plot = fit.xname(~strcmp(fit.xname,'const'));
                        eglm_plot_fit(fit,'params',regs_to_plot);
                    end
                end
            end
        
            % set all plots of each type to have same y-axis limits
            curi = 2;
            while curi+1 <= numel(hrow)
                setlim(hrow(curi:(curi+1)),'ylim','tight',.15,0);
                curi = curi + 2;
            end

            % neural corr with SVs
            hrow(end+1)=nsubplot(nrow,ncol,modi,ncol);
            liney(0,'k');
            xlab = sva.model.analysis{modi}.neural_corr_with_sv.name;
            xlab = [ ...
                cellfun(@(z) sprintf('%s (off%d)',z,1),xlab,'uniform',0) ...
                cellfun(@(z) sprintf('%s (off%d)',z,2),xlab,'uniform',0) ...
                ];
            x = 1:numel(xlab);
            y = sva.model.analysis{modi}.neural_corr_with_sv.r(:);
            p = sva.model.analysis{modi}.neural_corr_with_sv.rp(:);
            plot_bar(x,y,'barstart',0);
            set(gca,'xtick',x,'xticklabel',xlab);
            xtickangle(45);
            ylabel('Correlation');

            for bi = 1:numel(x)
                pvaltextsize = 16;
                if p(bi) < 0.001
                    pvaltext = '***';
                elseif p(bi) < 0.01
                    pvaltext = '**';
                elseif p(bi) < 0.05
                    pvaltext = '*';
                elseif p(bi) < 0.2
                    pvaltext = sprintf('.2f',p(bi));
                    pvaltextsize = 8;
                end
                if y(bi) < 0
                    textpos = 'ct';
                else
                    textpos = 'cb';
                end
                etext('ct',x(bi),y(bi),pvaltext,'fontsize',pvaltextsize);
            end
            setlim(gca,'ylim','tight',.15,0);
        end
    end
end
