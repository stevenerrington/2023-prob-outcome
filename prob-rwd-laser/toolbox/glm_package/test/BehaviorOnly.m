clear all; clc; beep off; close all; clc;

addpath('/Users/Ilya/Dropbox/HELPER/HELPER_GENERAL/');
addpath('C:\Users\Ilya Monosov\Dropbox\HELPER\HELPER_GENERAL');
pathname = '/Users/Ilya/Dropbox/LASER/'; addpath(pathname);

for monkeyid=3:5
    clear DDD S idx
    clear savestruct choices filesave L
    if monkeyid==3
        pathname = 'Y:\MONKEYDATA\Slayer2\Laser test\'; addpath(pathname);
        pathname1 = 'Y:\MONKEYDATA\Sabbath\LaserTest\'; addpath(pathname1);
        
        S = dir([pathname 'V*.mat']);
        S = S(~[S.isdir]);
        [~,idx] = sort([S.datenum]);
        DDD = S(idx)
        
        S = dir([pathname1 'V*.mat']);
        S = S(~[S.isdir]);
        [~,idx] = sort([S.datenum]);
        DDD1 = S(idx)
        
        DDD=[DDD; DDD1];
        monk='combined'
    elseif monkeyid ==4
        pathname = 'Y:\MONKEYDATA\Slayer2\Laser test\'; addpath(pathname);
        
        S = dir([pathname 'V*.mat']);
        S = S(~[S.isdir]);
        [~,idx] = sort([S.datenum]);
        DDD = S(idx)
        monk='slayer'
    elseif monkeyid ==5
        pathname = 'Y:\MONKEYDATA\Sabbath\LaserTest\'; addpath(pathname);
        
        S = dir([pathname 'V*.mat']);
        S = S(~[S.isdir]);
        [~,idx] = sort([S.datenum]);
        DDD = S(idx)
        monk='sabbath'
        
    end
    
    
    choices=[];
    ITIs=[];
    L=[];
    for xyz = 1:length(DDD)
        %%
        %%
        filename = DDD(xyz).name(1:end-4);
        load([filename '.mat'],'PDS'); %load session
        
        z=diff(PDS.datapixxtime);
        z=z(find(z<50));
        
        z=nanmean(z)-nanmean(PDS.timereward-PDS.timefpon);
        ITIs=[ITIs; z];
        
        choices_=[PDS.RewardRange1' PDS.PunishmentRange1' PDS.RewardRange2' PDS.PunishmentRange2' PDS.chosenwindow'];
        choices_=choices_(find(choices_(:,5)>0),:);
        
        sessid(1:size(choices_,1))=xyz;
        choices_=[choices_ sessid'];
        %%
        %%
        choices=[choices;choices_];
        %%
        savestruct(xyz).name=filename;
        savestruct(xyz).monk=monk;
        savestruct(xyz).choices=choices_;
        savestruct(xyz).laserpowers=unique(PDS.PunishStrength_);
        savestruct(xyz).numberoflasers=length(unique(PDS.PunishStrength_));
        savestruct(xyz).rewardsizes=unique(PDS. RewardTimeDur);
        savestruct(xyz).numberofrewards=length(unique(PDS. RewardTimeDur));
        %%
        %%
        % %     l1=length(find(choices_(:,1) == max([PDS.RewardRange1 PDS.RewardRange2])))
        % %     l2=length(find(choices_(:,3) == max([PDS.RewardRange1 PDS.RewardRange2])))
        % %     L=[L; l1 l2 ];
        %%
        %%
        clear choices_ sessid
    end
    
    filesave=[monk 'ITI.mat']
    save(filesave,'ITIs')
    
    filesave=[monk 'ChoiceOnly.mat']
    save(filesave,'choices')
    
    filesave=[monk 'ChoiceOnlySavestruct.mat']
    save(filesave,'savestruct')
    
    
    
end


asdfkjh
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;
clear all;
load('/Users/Ilya/Dropbox/LASER/Ilya/sabbathChoiceOnlySavestruct.mat')
LPW=unique([savestruct(:).laserpowers]);  LPW=LPW(find(LPW>-1))
REWs=unique([savestruct(:).rewardsizes]);  REWs=REWs(find(REWs>-1))

R=[];
RR=[];
for x=1:length(savestruct)

        
        TB= unique(savestruct(x).rewardsizes);
        TB=TB(find(TB>-1));
        if length(TB)==3
            TB(4:5)=NaN;
        elseif length(TB)==4
             TB(5)=NaN;
        end

        RR=[RR; TB];
        clear TB
        
        T(1:5)=NaN;
        t=unique(savestruct(x).choices(:,1));
        t=t(find(t>-1));
        T(1:length(t))=t;
        R=[R; T];
        clear T t

end
id=find(RR(:,1)==0.2 & isnan(RR(:,4))==1) 
savestruct1=savestruct(id);

choices=vertcat(savestruct1(1,:).choices)
filesave=['sabbath1ChoiceOnly.mat']
save(filesave,'choices'); 
clear choices savestruct x id;


load('slayerChoiceOnlySavestruct.mat')
LPW=unique([savestruct(:).laserpowers]);  LPW=LPW(find(LPW>-1))
REWs=unique([savestruct(:).rewardsizes]);  REWs=REWs(find(REWs>-1))

R=[];
RR=[];
for x=1:length(savestruct)     
        TB= unique(savestruct(x).rewardsizes);
        TB=TB(find(TB>-1));
        if length(TB)==3
            TB(4:5)=NaN;
        elseif length(TB)==4
             TB(5)=NaN;
        end

        RR=[RR; TB];
        clear TB
        
        T(1:5)=NaN;
        t=unique(savestruct(x).choices(:,1));
        t=t(find(t>-1));
        T(1:length(t))=t;
        R=[R; T];
        clear T t
end
id=find(RR(:,1)==0.4 & isnan(RR(:,4))==1) 
savestruct=savestruct(id);

for x=1:length(savestruct)
    t=unique(savestruct(x).choices(:,1));
    t1=unique(savestruct(x).choices(:,3));
    t=[t;t1]
    if find(t==2)
        savestruct(x).choices(:,1)=savestruct(x).choices(:,1)*2
        savestruct(x).choices(:,3)=savestruct(x).choices(:,3)*2
      
    end
      clear t t1
end
choices=vertcat(savestruct(1,:).choices)
filesave=['slayer1ChoiceOnly.mat']
save(filesave,'choices'); clear choices;


savestruct=[savestruct1,savestruct]
choices=vertcat(savestruct(1,:).choices)
filesave=['combined1ChoiceOnly.mat']
save(filesave,'choices'); clear choices;



slayerrew=['Slayer: 0.2  0.4  0.6  0.8  0.2155ml 0.4310ml 0.6466ml 0.8621ml ']
sabrew=['Slayer: 0.1  0.2  0.3  0.4  0.1121ml 0.2241ml 0.3362ml 0.4483ml ']
noterew=['For Slayer, we also used 0.1.  0.2  0.3  0.4 during 1 LHb recording']

choices=vertcat(savestruct(1,:).choices)


% load('/Users/Ilya/Dropbox/LASER/Ilya/combinedChoiceOnly.mat')

% SlayerJuice= [0.4310  0.6466  0.8621 ]
% SabbathJuice=[ 0.4483 0.6724 0.8966]
% juices=round(nanmean([SlayerJuice; SabbathJuice])*1000)./1000


% addpath('/Users/Ilya/Dropbox/HELPER/HELPER_GENERAL/');
% 



rewdiff=choices(:,1)-choices(:,3)
pundiff=choices(:,2)-choices(:,4)

firstoffer=find(choices(:,5)==1)
secondoffer=find(choices(:,5)==2)

diffrewards=unique(rewdiff)

noLaser=[find(choices(:,2)==2 & choices(:,4)==2);];

% laseronlyinoneLow=[find(choices(:,2)==4 & choices(:,4)==2); find(choices(:,2)==2 & choices(:,4)==4)];
% laseronlyinoneMed=[find(choices(:,2)==6 & choices(:,4)==2); find(choices(:,2)==2 & choices(:,4)==6)];


laseronlyinoneLowOf1=[find(choices(:,2)==4 & choices(:,4)==2)];
laseronlyinoneMedOf1=[find(choices(:,2)==6 & choices(:,4)==2)];
laseronlyinoneHighOf1=[find(choices(:,2)==8 & choices(:,4)==2)];

laseronlyinoneLowOf2=[find(choices(:,2)==2 & choices(:,4)==4)];
laseronlyinoneMedOf2=[find(choices(:,2)==2 & choices(:,4)==6)];
laseronlyinoneHighOf2=[find(choices(:,2)==2 & choices(:,4)==8)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LaserSet=noLaser
%
rR=-6;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet)),secondoffer) );
%
rR=6;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc1=(length(chosen)/length(totaltrials))*100
%
Perc1d=[length(chosen) length(totaltrials)]
%

%%
%%
%%
rR=-4;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet)),secondoffer) );
%%
rR=4;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc2=(length(chosen)/length(totaltrials))*100
%
Perc2d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=-2;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet)),secondoffer) );
%%
rR=2;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc3=(length(chosen)/length(totaltrials))*100
%
Perc3d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=0;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet)),secondoffer) );
%%
rR=0;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc4=(length(chosen)/length(totaltrials))*100
%
Perc4d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=2;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet)),secondoffer) );
%%
rR=-2;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc5=(length(chosen)/length(totaltrials))*100
%
Perc5d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=4;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet)),secondoffer) );
%%
rR=-4;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc6=(length(chosen)/length(totaltrials))*100
%
Perc6d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=6;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet)),secondoffer) );
%%
rR=-6;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc7=(length(chosen)/length(totaltrials))*100
%
Perc7d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
PercentNoLaser=[Perc1 Perc2 Perc3 Perc4 Perc5 Perc6 Perc7]
PercentNoLaserd=[Perc1d; Perc2d; Perc3d; Perc4d; Perc5d; Perc6d; Perc7d];
clear Perc1d Perc2d Perc3d Perc4d Perc5d Perc6d Perc7d
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LaserSet1=laseronlyinoneLowOf1;
LaserSet2=laseronlyinoneLowOf2;
%
rR=-6;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet2)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet2)),secondoffer) );
%
rR=6;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet1)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet1)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc1=(length(chosen)/length(totaltrials))*100
%
Perc1d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=-4;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet2)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet2)),secondoffer) );
%%
rR=4;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet1)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet1)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc2=(length(chosen)/length(totaltrials))*100
%
Perc2d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=-2;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet2)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet2)),secondoffer) );
%%
rR=2;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet1)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet1)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc3=(length(chosen)/length(totaltrials))*100
%
Perc3d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=0;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet2)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet2)),secondoffer) );
%%
rR=0;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet1)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet1)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc4=(length(chosen)/length(totaltrials))*100
%
Perc4d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=2;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet2)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet2)),secondoffer) );
%%
rR=-2;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet1)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet1)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc5=(length(chosen)/length(totaltrials))*100
%
Perc5d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=4;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet2)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet2)),secondoffer) );
%%
rR=-4;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet1)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet1)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc6=(length(chosen)/length(totaltrials))*100
%
Perc6d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=6;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet2)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet2)),secondoffer) );
%%
rR=-6;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet1)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet1)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc7=(length(chosen)/length(totaltrials))*100
%
Perc7d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
PercentLaserLow=[Perc1 Perc2 Perc3 Perc4 Perc5 Perc6 Perc7]
PercentLaserLowd=[Perc1d; Perc2d; Perc3d; Perc4d; Perc5d; Perc6d; Perc7d];
clear Perc1d Perc2d Perc3d Perc4d Perc5d Perc6d Perc7d

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LaserSet1=laseronlyinoneMedOf1;
LaserSet2=laseronlyinoneMedOf2;
%
rR=-6;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet2)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet2)),secondoffer) );
%
rR=6;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet1)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet1)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc1=(length(chosen)/length(totaltrials))*100
%
Perc1d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=-4;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet2)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet2)),secondoffer) );
%%
rR=4;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet1)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet1)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc2=(length(chosen)/length(totaltrials))*100
%
Perc2d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=-2;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet2)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet2)),secondoffer) );
%%
rR=2;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet1)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet1)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc3=(length(chosen)/length(totaltrials))*100
%
Perc3d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=0;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet2)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet2)),secondoffer) );
%%
rR=0;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet1)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet1)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc4=(length(chosen)/length(totaltrials))*100
%
Perc4d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=2;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet2)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet2)),secondoffer) );
%%
rR=-2;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet1)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet1)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc5=(length(chosen)/length(totaltrials))*100
%
Perc5d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=4;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet2)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet2)),secondoffer) );
%%
rR=-4;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet1)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet1)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc6=(length(chosen)/length(totaltrials))*100
%
Perc6d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=6;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet2)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet2)),secondoffer) );
%%
rR=-6;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet1)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet1)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc7=(length(chosen)/length(totaltrials))*100
%
Perc7d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
PercentLaserMed=[Perc1 Perc2 Perc3 Perc4 Perc5 Perc6 Perc7]
PercentLaserMedd=[Perc1d; Perc2d; Perc3d; Perc4d; Perc5d; Perc6d; Perc7d];
clear Perc1d Perc2d Perc3d Perc4d Perc5d Perc6d Perc7d
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LaserSet1=laseronlyinoneHighOf1;
LaserSet2=laseronlyinoneHighOf2;
%
rR=-6;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet2)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet2)),secondoffer) );
%
rR=6;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet1)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet1)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc1=(length(chosen)/length(totaltrials))*100
%
Perc1d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=-4;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet2)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet2)),secondoffer) );
%%
rR=4;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet1)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet1)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc2=(length(chosen)/length(totaltrials))*100

%
Perc2d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=-2;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet2)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet2)),secondoffer) );
%%
rR=2;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet1)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet1)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc3=(length(chosen)/length(totaltrials))*100
%
Perc3d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=0;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet2)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet2)),secondoffer) );
%%
rR=0;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet1)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet1)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc4=(length(chosen)/length(totaltrials))*100
%
Perc4d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=2;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet2)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet2)),secondoffer) );
%%
rR=-2;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet1)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet1)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc5=(length(chosen)/length(totaltrials))*100
%
Perc5d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=4;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet2)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet2)),secondoffer) );
%%
rR=-4;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet1)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet1)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc6=(length(chosen)/length(totaltrials))*100
%
Perc6d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
rR=6;
totaltrials1=(intersect(find(rewdiff==rR),LaserSet2)) ;
chosen1=(intersect((intersect(find(rewdiff==rR),LaserSet2)),secondoffer) );
%%
rR=-6;
totaltrials2=(intersect(find(rewdiff==rR),LaserSet1)) ;
chosen2=(intersect((intersect(find(rewdiff==rR),LaserSet1)),firstoffer) );
%
chosen=[chosen1; chosen2];
totaltrials=[totaltrials1; totaltrials2];
Perc7=(length(chosen)/length(totaltrials))*100
%
Perc7d=[length(chosen) length(totaltrials)]
%
%%
%%
%%
PercentLaserHigh=[Perc1 Perc2 Perc3 Perc4 Perc5 Perc6 Perc7]

PercentLaserHighd=[Perc1d; Perc2d; Perc3d; Perc4d; Perc5d; Perc6d; Perc7d];
clear Perc1d Perc2d Perc3d Perc4d Perc5d Perc6d Perc7d
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



figuren;

for x=1:4
    if x==1
        data=PercentNoLaserd
        CL='g';
    elseif x==2
        data=PercentLaserLowd
        CL='c';
    elseif x==3
        data=PercentLaserMedd
        CL='m';
    elseif x==4
        data=PercentLaserHighd
        CL='b';
    end
    
    data=data(1:6,:)
    
    E=[];
    for y=1:size(data,1)
        T = data(y,1);
        nTotalChosen = data(y,2);
        
        [phat pci_nov] = binofit(T, nTotalChosen); % errorbars are 95% conf interval for binomial distribution
        err_low = [T/nTotalChosen - pci_nov(1)];
        err_hi = [pci_nov(2) - T/nTotalChosen ];
        
        E=[E; err_low err_hi];
%                 if x>1 & y>1
%                 errorbar(y, [T/nTotalChosen],...
%                     err_low, err_hi, CL, 'LineStyle', 'none')
%                 end
        clear T nTotalChosen
    end
    
    
    
    d= data(:,1)./data(:,2)
    d=d(2:end);
    E=E(2:6,:);
    
 tr=0.5;
    if x>1
        plot([2 3 4 5 6],d,CL,'LineWidth',2);

    end
    
    
    if x>1
    [hl,hp] = boundedline([2 3 4 5 6],d,E,CL, 'nan', 'fill','alpha',...
        'transparency', tr); %    'cmap', cool(4), ...
    
    ho = outlinebounds(hl,hp);
    %set(ho, 'linestyle', ':', 'color', CL, 'marker', '.');
    
    end
    
    
    clear data y E
end
plot([0 8],[.50 .50],'k-.')
plot([4 4],[0 1],'k-.')
xlim([0 7])


xticks([ 2 3 4 5 6])
set(gca,'XTickLabel',{'medium positive value diff';'small positive value diff'; ...
    'no value diff'; 'small negative value diff'; 'medium negative value diff';});
xtickangle(45)
ylabel('% Chosen of offers with Laser')
t=xlabel('Relative reward value: offer predicting laser - offer predicting no laser'); 

text(1,0.2,['laser pows J (here we show last 3 in dif colors)=  ' mat2str(LPW)]);
text(1,0.15,slayerrew);
text(1,0.1,sabrew);
text(1,0.05,noterew);


set(gcf,'Position',[1 41 2560 1484],'Paperposition',[0 0 26.6667 15.4583], 'Paperpositionmode','auto','Papersize',[26.6667 15.4583]);  % sets the size of the figure and orientation
print('-dpdf', 'RawCHOICE' ); 


clear all;
big_behavioral_dataset_analysis_v01

set(gcf,'Position',[1 41 2560 1484],'Paperposition',[0 0 26.6667 15.4583], 'Paperpositionmode','auto','Papersize',[26.6667 15.4583]);  % sets the size of the figure and orientation
print('-dpdf', 'glmCHOICE' ); 





print('-dpdf', 'craptest','painters' ); 


