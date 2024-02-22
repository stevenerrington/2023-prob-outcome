% clear all; clc

%% Setup data
% Load in PDS data
%load('/Users/stevenerrington/Desktop/ProbRwdDelay Data/Zepp/ProbRwdDelay_13_02_2024_11_00.mat','PDS')

% Generate datatable
d = gen_PDS_datatable(PDS);


%% Setup GLM
% Define approach type
approach = 'raw'; 

% Input variables
switch approach
    case 'conceptual'
        xreg = {};
        xreg{end+1} = struct('name','R','terms',{{ abs([ d{:,'offer1_rwd'} d{:,'offer2_rwd'} ]) }}); % Reward
        xreg{end+1} = struct('name','T','terms',{{ abs([ d{:,'offer1_delay'} d{:,'offer2_delay'} ]) }}); % Time
        xreg{end+1} = struct('name','RU','terms',{{'flag', sign([ d{:,'offer1_rwd'} d{:,'offer2_rwd'} ])==-1 }}); % Reward Uncertainty
        xreg{end+1} = struct('name','TU','terms',{{'flag', sign([ d{:,'offer1_delay'} d{:,'offer2_delay'} ])==-1 }}); % Time Uncertainty
        xreg{end+1} = struct('name','Offer2','terms',{{'flag', repmat([0 1],size(d,1),1) }}); % Offer 2 flag

    case 'raw_with_order'
        curord = d{:,3}; % order (shared for both offers)
        cur1 = d{:,[4 5]}; % Offer 1 attributes
        cur2 = d{:,[6 7]}; % Offer 2 attributes

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
        xreg{end+1} = struct('name','offer2','terms',{{'flag', repmat([0 1],size(d,1),1) }});

    case 'raw'
        cur1 = d{:,[4 5]}; % Offer 1 attributes
        cur2 = d{:,[6 7]}; % Offer 2 attributes

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
        xreg{end+1} = struct('name','offer2','terms',{{'flag', repmat([0 1],size(d,1),1) }});
end

% Trial curation
trial_flag = d{:,'goodtrial'}==1; % Logical - only include trials meeting criteria

% Output/predicted variable
yreg = d{:,'choice'}==2; % Logical - whether offer 2 was chosen

%% Run GLM
f = eglm_fit(xreg,yreg,'binary choices','oktrials',trial_flag,'calculate predictions',true);

%% Plot GLM
% plot results
figuren; 
ax = subplot(1,1,1);
eglm_plot_fit(f);

%% Run statistics (in dev)
% 
% %% Stats example
% % example: test if beta1 is sig diff from beta13
% hyp = zeros(1,f.nx);
% hyp(1) = +1;
% hyp(13) = -1;
% p = linhyptest(f.b, f.stats.covb, 0, hyp, f.stats.dfe )
