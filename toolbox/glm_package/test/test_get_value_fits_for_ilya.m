% clear all;
close all;
% clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%bmodi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DRFcor=0.5;
% TrialsLim=220;
% 
% load('savedata_slayer__2.mat');
% 
% id=(find([savedata(:).goodtrialslength]>TrialsLim))
% savedata=savedata(id);
% 
% % drift=[];
% % for x=1:length(savedata)
% %     drift=[drift;savedata(x).drift]
% % end
% % id=find(abs(drift(:,1))<DRFcor)
% % savedata=savedata(id);
% 
% totalleng_slayer=length(savedata)
% 
% savedata1=savedata;
% 
% clear savedata
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% TrialsLim=220;
% 
%load('savedata_sabbath__1.mat');
% 
% id=(find([savedata(:).goodtrialslength]>TrialsLim))
% 
% savedata=savedata(id);
% 
% % drift=[];
% % for x=1:length(savedata)
% %     drift=[drift;savedata(x).drift]
% % end
% % id=find(abs(drift(:,1))<DRFcor)
% % savedata=savedata(id);
% 
% totalleng_sabbath=length(savedata)
% 
% savedata=[savedata savedata1]
% 
% totalleng=length(savedata)
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%s=savedata;

% filename ='combinedneuronsOFC.mat'
% save(filename, 'savedata', '-v7.3')
savedata=s;




id=(find([savedata(:).goodtrialslength]>280))
savedata=savedata(id);

% 
% drift=[];
% for x=1:length(savedata)
%     drift=[drift;savedata(x).drift]
% end
% id=find(abs(drift(:,1))<0.5)
% savedata=savedata(id);

%NeuronalVisualizerGlm


% 
% id=(find([savedata(:).variance]<0.01))
% savedata=savedata(id);


% for each unit, get loglik

%sva_struct_name = 'sva'; % behav model fit to each single unit's behavioral data 
sva_struct_name = 'sva_bigbehavvalues'; % behav model fit to big behavioral dataset
ssn = sva_struct_name;

% behavioral model types: 1 = linear indep, 2 = nonlinear indep, 3 = nonlinear joint
bmodi = 2; % use model type 2 (nonlinear indep)

% subjective value models fit to neural activity:
% 1 = rewandpunvalues (2 params + constant)
% 2 = value (1 param + constant)
% 3 = rewvalue (1 param + constant)
% 4 = punvalue (1 param + constant)
nsvmodels = 4;

% get loglik for each unit, each value model, and each offer response
noffers = 2;

emptymat = nan*ones(numel(savedata),nsvmodels,noffers);

unit_stats = struct();
unit_stats.loglik = emptymat;
unit_stats.r2 = emptymat;
unit_stats.b = emptymat;
unit_stats.se = emptymat;
unit_stats.p = emptymat;

unit_stats.ok = true(size(emptymat)); % which units/responses/etc are OK to use for analysis?
unit_stats.svmodname = {};

for u = 1:numel(savedata)
    
    if ~isstruct(savedata(u).(sva_struct_name))
        unit_stats.ok(u,:,:) = false;
        continue;
    end
    
    nvf = savedata(u).(sva_struct_name).model.analysis{bmodi}.neural_value_fit;
    assert(numel(nvf.name) == nsvmodels);
    
    unit_stats.svmodname = nvf.name;
    for svmodi = 1:nsvmodels
        for offi = 1:noffers
            unit_stats.loglik(u,svmodi,offi) = nvf.fit{svmodi,offi}.loglik;
            unit_stats.r2(u,svmodi,offi) = nvf.fit{svmodi,offi}.r2;
            % get fitted weight/se/p of value-related regressor
            % (for models that have only a single weight other than the
            %  constant factor)
            if nvf.fit{svmodi,offi}.nx == 2
                unit_stats.b(u,svmodi,offi) = nvf.fit{svmodi,offi}.stats.beta(1);
                unit_stats.se(u,svmodi,offi) = nvf.fit{svmodi,offi}.stats.se(1);
                unit_stats.p(u,svmodi,offi) = nvf.fit{svmodi,offi}.stats.p(1);
            end
        end
    end
end


unit_total_ll = sum(unit_stats.loglik,3); % sum LL over the two offer responses

% only take 'ok' units
unit_stats.oku = all(all(unit_stats.ok,3),2);
unit_total_ll = unit_total_ll(unit_stats.oku,:);


value_vs_rewvalue = unit_total_ll(:,2) - unit_total_ll(:,3)
value_vs_punvalue = unit_total_ll(:,2) - unit_total_ll(:,4)

clc;
disp('rew')
mean(value_vs_rewvalue)
median(value_vs_rewvalue)
signrank(value_vs_rewvalue)

disp('pun')
mean(value_vs_punvalue)
median(value_vs_punvalue)
signrank(value_vs_punvalue)

disp('lengths')
length(savedata)


























