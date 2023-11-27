clear all;
close all;
beep off;
warning off;
addpath('C:\Users\Ilya Monosov\Dropbox\HELPER\HELPER_GENERAL');

% add path to include necessary files for Ethan's analysis code
% NOTE: not sure if this will work on your computer. I tried to write
% this line so if you are in the current directory (Dropbox/LASER/Ilya)
% it should add the correct path whether you are on Mac or PC.
addpath(fullfile('.','ethan_dependencies'));

for monkeytype=1:1
    
    if monkeytype==1
        pathname = 'Y:\MONKEYDATA\Sabbath\LaserTest\PLEXON\PDS\';
        addpath(pathname);% Sabbath
        monkeyname='sabbath';
        
        DDD = dir([pathname '*.mat']);
        clear d
        for X=1:length(DDD)
            d(X).t=DDD(X).name(1:21);
            clear X
        end
        UniqueSessions=unique(struct2cell(d));
        for X=1:length(DDD)
            DDD(X).Session=find(strcmp(UniqueSessions, DDD(X).name(1:21)));
            clear X
        end
        
    elseif monkeytype==2
        
        pathname = 'Y:\MONKEYDATA\Slayer2\Laser test\PLEXON\PDS\';
        addpath(pathname);
        monkeyname='slayer';
        
        DDD = dir([pathname '*.mat']);
        clear d
        for X=1:length(DDD)
            d(X).t=DDD(X).name(1:21);
            clear X
        end
        
        pathname = 'Y:\MONKEYDATA\Slayer2\Laser test\PLEXON\PDS\LHB\';
        addpath(pathname);
        monkeyname='slayer';
        DDD1 = dir([pathname '*.mat']);
        for X=1:length(DDD1)
            d1(X).t=DDD1(X).name(1:21);
            clear X
        end
        
        DDD=[DDD; DDD1]
        d=[d d1]

        UniqueSessions=unique(struct2cell(d));
        for X=1:length(DDD)
            DDD(X).Session=find(strcmp(UniqueSessions, DDD(X).name(1:21)));
            clear X
        end
        

    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%  Definition of parameters
    
    s.CENTER = 8000;
    s.gauswindow_ms = 50;
    s.eventfieldname = ...
        {'timefpon',...
        'timetargeton',...
        'timetargeton2',...
        'timeChoice',...
        'timeLaser',...
        'timereward'};
    
    eventfieldname = s.eventfieldname;
    timefpon_N = find(contains(eventfieldname, 'timefpon'));
    timetargeton_N = find(contains(eventfieldname, 'timetargeton'), 1 );
    timetargeton2_N = find(contains(eventfieldname, 'timetargeton2'));
    timeChoice_N = find(contains(eventfieldname, 'timeChoice'));
    timeLaser_N = find(contains(eventfieldname, 'timeLaser'));
    timereward_N = find(contains(eventfieldname, 'timereward'));
    
    choices=[];
    L=[];
    
    
    for x_file = 1 :size(DDD, 1)
        
        savedata(x_file).exclude=0;
        
        % clearvars -except savestruct s DDD x_file pathname offer1_LR1_offer1_SR1_diff offer1_LP1_offer1_SP1_diff offer2_LR2_offer2_SR2_diff offer2_LP2_offer2_SP2_diff
        
        % load PDS from each directory using recording list
        specificfilename = DDD(x_file).name;
        pathoffile = which(specificfilename);
        load(pathoffile, 'PDS');
        
        
        savedata(x_file).pathoffile=pathoffile;
        savedata(x_file).filename=DDD(x_file).name;
        savedata(x_file).loopnum=x_file;
        savedata(x_file).monkeyname=monkeyname;
        
        

        choices_=[PDS.RewardRange1' PDS.PunishmentRange1' PDS.RewardRange2' PDS.PunishmentRange2' PDS.chosenwindow'];
            
        session= DDD(x_file).Session;
        SessionID(1:size(choices_,1))=session;
        choices_=[choices_ SessionID'  ];
        
        numbertoremovenonchoice=-1;
        choices_=choices_(find(choices_(:,5)>numbertoremovenonchoice),:);
    
        choices_(:,5)=choices_(:,5)+1;
        savedata(x_file).choices=choices_;
        

       
        
        clear choices_ OF1 OF2 LoopNumber nn eventtime Rasters SessionID LoopNumber TrialID roc p LP SP LR SR eventIndices    
        
    end
    
    
    
    
    filename = ['savedata_' monkeyname 'choice.mat']
    save(filename, 'savedata')
    
    clear savedata filename choices_ choices
end

%NeuralVisualization;











