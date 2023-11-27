figuren;

load choices.mat;
c = choices;

nt = size(c,1);

% (trial) x (amt,prob) x (rew,aver) x (off1,off2)
off1 = cat(3,[c(:,1) c(:,2)],[c(:,3) c(:,4)]);
off2 = cat(3,[c(:,5) c(:,6)],[c(:,7) c(:,8)]);
off = cat(4,off1,off2);

chosen_offer = c(:,9);

% (trial) x (E,SD) x (rew,aver) x (off1,off2)
% for model using expected rew/pun, and SD of rew/pun
p_to_sd = @(p) sqrt((p).*((1-p).^2) + (1-p).*(p.^2));
off_ersd = [off(:,1,:,:).*off(:,2,:,:) off(:,1,:,:).*p_to_sd(off(:,2,:,:))];


% simple choice matrix like the original one, but replacing
%  amt and prob with E and SD
c_esd = [ ...
    c(:,1).*c(:,2) c(:,1).*p_to_sd(c(:,2)) ...
    c(:,3).*c(:,4) c(:,3).*p_to_sd(c(:,4)) ...
    c(:,5).*c(:,6) c(:,5).*p_to_sd(c(:,6)) ...
    c(:,7).*c(:,8) c(:,7).*p_to_sd(c(:,8)) ...
    ];


figuren;

nmodel = 2;

fits = {};

for modi = 1:nmodel
    xreg = {};
    switch modi
        case 1
            % E SD model
            model_name = 'E SD model';
%             xreg{end+1} = struct('name','ER','terms',{{diff(off_ersd(:,1,1,:),[],4)}});
%             xreg{end+1} = struct('name','SDR','terms',{{diff(off_ersd(:,2,1,:),[],4)}});
%             xreg{end+1} = struct('name','EP','terms',{{diff(off_ersd(:,1,2,:),[],4)}});
%             xreg{end+1} = struct('name','SDP','terms',{{diff(off_ersd(:,2,2,:),[],4)}});

        %    xreg{end+1} = struct('name','ER','terms',{{c_esd(:,5)-c_esd(:,1)}});
        %    xreg{end+1} = struct('name','SDR','terms',{{c_esd(:,6)-c_esd(:,2)}});
            xreg{end+1} = struct('name','EP','terms',{{c_esd(:,7)-c_esd(:,3)}});
            xreg{end+1} = struct('name','SDP','terms',{{c_esd(:,8)-c_esd(:,4)}});
        case 2
            % AMT PROB model
            model_name = 'AMT PROB model';
%             xreg{end+1} = struct('name','aR','terms',{{diff(off(:,1,1,:),[],4)}});
%             xreg{end+1} = struct('name','pR','terms',{{diff(off(:,2,1,:),[],4)}});
%             xreg{end+1} = struct('name','aP','terms',{{diff(off(:,1,2,:),[],4)}});
%             xreg{end+1} = struct('name','pP','terms',{{diff(off(:,2,2,:),[],4)}});

        %    xreg{end+1} = struct('name','aR','terms',{{c(:,5)-c(:,1)}});
        %    xreg{end+1} = struct('name','pR','terms',{{c(:,6)-c(:,2)}});
            xreg{end+1} = struct('name','aP','terms',{{c(:,7)-c(:,3)}});
            xreg{end+1} = struct('name','pP','terms',{{c(:,8)-c(:,4)}});
    end

    % bias term
    xreg{end+1} = struct('name','off2','terms',{{'flag',[zeros(nt,1) ones(nt,1)]}});

    yreg = chosen_offer==2;

    fits{modi} = eglm_fit(xreg,yreg,'binary choices','name',model_name);

    nsubplot(nmodel,1,modi,1);
    eglm_plot_fit(fits{modi});
end
