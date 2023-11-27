%load combinedneuronsOFC350.mat

% 132 cells have sig Rew coding by combined_pvalues over off1+off2
% (using rewandpunvalues model)


anai = 2; % use analysis type 2: nonlinear independent model

offi = 2; % use response to offer 2

% models to compare: 
%  model 1: rewandpunvalues
%  model 2: value
%  model 3: rewvalue
%  model 4: punvalue
modelids = [1 2];
%modelids = [3 4];
%modelids = [1 4];

% note: model 1 has 1 more param, we need to correct for this
% we don't have shuffles or cross-validation.
%
% But foolishly, for the bigbehavvalues version of the structure, I didn't
% do cross-validation...so I need to do this with just 'sva'
svatype = 'sva';
%svatype = 'sva_bigbehavvalues';

res = struct();
res.loglik = nans(numel(savedata),numel(modelids));
res.aic = nans(numel(savedata),numel(modelids));
res.bic = nans(numel(savedata),numel(modelids));
res.xval.loglik = nans(numel(savedata),numel(modelids));
res.xval.aic = nans(numel(savedata),numel(modelids));
res.xval.bic = nans(numel(savedata),numel(modelids));

assert(numel(offi)==1);
for ui = 1:numel(savedata)
    curfits = savedata(ui).(svatype).model.analysis{anai}.neural_value_fit;
    
    fit = curfits.fit(modelids,offi);
    modelnames = curfits.name(modelids);
    
    for fi = 1:numel(fit)
        res.loglik(ui,fi) = fit{fi}.loglik;
        res.aic(ui,fi) = fit{fi}.aic;
        res.bic(ui,fi) = fit{fi}.bic;
        res.xval.loglik(ui,fi) = fit{fi}.crossval.loglik;
        res.xval.aic(ui,fi) = fit{fi}.crossval.aic;
        res.xval.bic(ui,fi) = fit{fi}.crossval.bic;
    end
end


% loglik: positive is better.
%  So value model is favored if diff in ll is positive
% aic/bic: negative is better
%  So value model is favored if diff in ll is negative

figuren;

oku = ~any(isnan(res.loglik) | isnan(res.xval.loglik),2);

varinfo = {};
varinfo{end+1} = struct('name','loglik','text',sprintf('positive = favor "%s"\nover "%s"',modelnames{2},modelnames{1}));
varinfo{end+1} = struct('name','aic','text',sprintf('negative = favor "%s"\nover "%s"',modelnames{2},modelnames{1}));
varinfo{end+1} = struct('name','bic','text',sprintf('negative = favor "%s"\nover "%s"',modelnames{2},modelnames{1}));

h = [];
for vari = 1:numel(varinfo)
    vn = varinfo{vari}.name;
    
    for rowi = 1:2
        switch rowi
            case 1
                xraw = res.(vn);
                curname = vn;
            case 2
                xraw = res.xval.(vn);
                curname = ['Cross-validated ' vn];
        end
        
        x = diff(xraw(oku,:),[],2);
        xedge = -15:1:15;
        
        h(rowi,vari)=nsubplot(2,numel(varinfo),rowi,vari);
        title(sprintf('%s difference\n(%s)',curname,varinfo{vari}.text));
        
        plot_hist(x,xedge,[1 1 1]*.5,'outline','k','edgecolor','none');
        linex(0,'k');
        xlim(xedge([1 end]));
        ylabel('# neurons');
    end
end
