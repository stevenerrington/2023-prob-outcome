function f = probrwddelay_glm(datatable, approach)

%% Setup GLM

% Define variables based on approach
switch approach
    case 'conceptual'
        xreg = {};
        xreg{end+1} = struct('name','R','terms',{{ abs([ datatable{:,'offer1_rwd'} datatable{:,'offer2_rwd'} ]) }}); % Reward
        xreg{end+1} = struct('name','T','terms',{{ abs([ datatable{:,'offer1_delay'} datatable{:,'offer2_delay'} ]) }}); % Time
        xreg{end+1} = struct('name','RU','terms',{{'flag', sign([ datatable{:,'offer1_rwd'} datatable{:,'offer2_rwd'} ])==-1 }}); % Reward Uncertainty
        xreg{end+1} = struct('name','TU','terms',{{'flag', sign([ datatable{:,'offer1_delay'} datatable{:,'offer2_delay'} ])==-1 }}); % Time Uncertainty
        
        % SE added

        xreg{end+1} = struct('name','R-x-T','terms',{{ abs([ datatable{:,'offer1_delay'} datatable{:,'offer2_delay'} ]), abs([ datatable{:,'offer1_delay'} datatable{:,'offer2_delay'} ]) }}); % Time
        
        xreg{end+1} = struct('name','AttOrder','terms',{{'flag', [ datatable{:,'offer1_att_order'}==1 datatable{:,'offer2_att_order'}==1 ]}}); % Time Uncertainty
        
        xreg{end+1} = struct('name','R-x-AttOrder','terms',{{abs([ datatable{:,'offer1_rwd'} datatable{:,'offer2_rwd'} ]), 'flag', [ datatable{:,'offer1_att_order'}==1 datatable{:,'offer2_att_order'}==1 ]}}); % Time Uncertainty
        xreg{end+1} = struct('name','T-x-AttOrder','terms',{{abs([ datatable{:,'offer1_delay'} datatable{:,'offer2_delay'} ]), 'flag', [ datatable{:,'offer1_att_order'}==1 datatable{:,'offer2_att_order'}==1 ]}}); % Time Uncertainty

        xreg{end+1} = struct('name','RU-x-AttOrder','terms',{{'flag', sign([ datatable{:,'offer1_rwd'} datatable{:,'offer2_rwd'} ])==-1, [ datatable{:,'offer1_att_order'}==1 datatable{:,'offer2_att_order'}==1 ]}}); % Time Uncertainty
        xreg{end+1} = struct('name','TU-x-AttOrder','terms',{{'flag', sign([ datatable{:,'offer1_delay'} datatable{:,'offer2_delay'} ])==-1, [ datatable{:,'offer1_att_order'}==1 datatable{:,'offer2_att_order'}==1 ]}}); % Time Uncertainty


        xreg{end+1} = struct('name','Offer2','terms',{{'flag', repmat([0 1],size(datatable,1),1) }}); % Offer 2 flag

    case 'raw_with_corr_order'
        curord = datatable{:,3}; % order (shared for both offers)
        cur1 = datatable{:,[4 5]}; % Offer 1 attributes
        cur2 = datatable{:,[6 7]}; % Offer 2 attributes

        % Find all unique combinations of attributes
        [urows,~,all_uoffid] = unique([[curord cur1]; [curord cur2]],'rows');
        uoffid = [all_uoffid(1:size(cur1,1)) all_uoffid((size(cur1,1)+1):end)];

        xreg = {}; % Clear array

        % For all combinations of attribute pairs, loop through and insert
        % as regressors
        urows_to_use = 1:size(urows,1);
        urows_to_use = setdiff(urows_to_use,[1 17]);
        for uri = 1:numel(urows_to_use)
            ui = urows_to_use(uri);
            xreg{end+1} = struct('name',sprintf('%d,%d,%d',urows(ui,1),urows(ui,2),urows(ui,3)),'terms',{{ uoffid == ui }});
        end

        % Add in a bias term
        xreg{end+1} = struct('name','offer2','terms',{{'flag', repmat([0 1],size(datatable,1),1) }});

    case 'raw_with_uncorr_order'
        curord = datatable{:,[3 4]}; % order (shared for both offers)
        cur1 = datatable{:,[5 6]}; % Offer 1 attributes
        cur2 = datatable{:,[7 8]}; % Offer 2 attributes

        % Find all unique combinations of attributes
        [urows,~,all_uoffid] = unique([[curord cur1]; [curord cur2]],'rows');
        uoffid = [all_uoffid(1:size(cur1,1)) all_uoffid((size(cur1,1)+1):end)];

        xreg = {}; % Clear array

        % For all combinations of attribute pairs, loop through and insert
        % as regressors
        urows_to_use = 1:size(urows,1);
        urows_to_use = setdiff(urows_to_use,[1 17]);
        for uri = 1:numel(urows_to_use)
            ui = urows_to_use(uri);
            xreg{end+1} = struct('name',sprintf('%d,%d,%d,%d',urows(ui,1),urows(ui,2),urows(ui,3),urows(ui,4)),'terms',{{ uoffid == ui }});
        end

        % Add in a bias term
        xreg{end+1} = struct('name','offer2','terms',{{'flag', repmat([0 1],size(datatable,1),1) }});


    case 'raw'
        cur1 = datatable{:,[4 5]}; % Offer 1 attributes
        cur2 = datatable{:,[6 7]}; % Offer 2 attributes

        % Find all unique combinations of attributes
        [urows,~,all_uoffid] = unique([cur1; cur2],'rows');
        uoffid = [all_uoffid(1:size(cur1,1)) all_uoffid((size(cur1,1)+1):end)];

        xreg = {}; % Clear array

        % For all combinations of attribute pairs, loop through and insert
        % as regressors
        for ui = 2:size(urows,1)
            xreg{end+1} = struct('name',sprintf('%d,%d',urows(ui,1),urows(ui,2)),'terms',{{ uoffid == ui }});
        end

        % Add in a bias term
        xreg{end+1} = struct('name','offer2','terms',{{'flag', repmat([0 1],size(datatable,1),1) }});
end

% Trial curation
trial_flag = datatable{:,'goodtrial'}==1; % Logical - only include trials meeting criteria

% Output/predicted variable
yreg = datatable{:,'choice'}==2; % Logical - whether offer 2 was chosen

% per-offer 'effects' to estimate.
% here we want the 'value' but NOT using the 'bias' terms
% so that this is an estimate of the PART of total offer value
% explained by the offer type (4 Rew x 4 Delay x 2 Order = 32 offer types)
xnames = cellfun(@(z) z.name,xreg,'uniform',0);
xnames_nobias = setdiff(xnames,{'Offer2'});
effectinfo = struct('value',{xnames},'value_nobias',{xnames_nobias});

%% Run GLM
f = eglm_fit(xreg,yreg,'binary choices','oktrials',trial_flag,'calculate predictions',true, 'calculate per-offer effects', effectinfo);

end