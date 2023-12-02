function [PDS ,c ,s]= ProbAmtIso_next(PDS ,c ,s)
%% next_trial function
% this is executed once at the beginning of each trial
% as the first step of the 'Run' action from the GUI
% (the other steps are 'run_trial' and 'finish_trial'
% This is where values are set as needed for setupthe next trial
%% increment trial count

c.j = c.j + 1;

try
    instrreset
    fclose(s1)
    clear s1
end

if c.repeatflag==0
    %% Next trial parameters
    [c, s]                  = nextparams(c, s);
    s.targFixDurReq=c.targFixDurReq;
    c.showfirst=0;
    c.chosen=0;
    c.punishdel=0;
    c.AmpUseAver=11;
    c.outcomechannel = 0;
    c.rwd_reveal_flag = 0;

else
    c.showfirst=0;
    c.chosen=0;
    c.punishdel=0;
    c.rwd_reveal_flag = 0;
    s.targFixDurReq=c.targFixDurReq;
    c.AmpUseAver=11;
    c.outcomechannel = 0;
    c.targAmp               = 0;
    s.targXY                = [0 0];
    
end
end

function [c, s]         = nextparams(c, s)

c.fracsize=4;
c.infocuesize=1.75;

ITI_dur= 0.5;
c.fixreq=2;
TS_dur=0.5;
CS_dur=3;
trace_dur=0; %this is set to 0 as baseline
rewardtimeafterCSoff=[1.5 1.5 1.5];
rewardtimeafterCSoff=rewardtimeafterCSoff(randperm(length(rewardtimeafterCSoff))); rewardtimeafterCSoff=rewardtimeafterCSoff(1);
c.rewardtimeafterCSoff=rewardtimeafterCSoff;
c.reveal_first_idx = 1;

c.intrareveal_interval = 0.0;
c.reveal_outcome_interval = 1;
c.intraoutcome_interval = 5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c.rwd_delay = [2 8]; % 1.5 seconds, 2.5 seconds
c.rewarddist = [0.13*1.3 0.34*1.3]; %; [0.075 0.15];

RewardRange1=[0 50 100]; % [0 50 100]
RewardRange2=[0 50 100]; % [0 50 100]
PunishmentRange1=[0 50 100]; % [0 50 100]
PunishmentRange2=[0 50 100]; % [0 50 100]

for xB=1:100
    c.RewardRange1=RewardRange1(randi(length(RewardRange1)));
    c.RewardRange2=RewardRange2(randi(length(RewardRange2)));
    
    c.PunishmentRange1=PunishmentRange1(randi(length(PunishmentRange1)));
    c.PunishmentRange2=PunishmentRange2(randi(length(PunishmentRange2)));
    
    if (c.PunishmentRange1==c.PunishmentRange2 & c.RewardRange1==c.RewardRange2) 
        %|| ...
        %(c.RewardRange1 == 0 & c.RewardRange2 == 0)
    else
        break
    end
end

% Define choices/outcomes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% Option 1
rew1=1;    pun1=1;
rew2=1;    pun2=1;

RewardHist1(1:c.RewardRange1)=1;
RewardHist1_1(1:100-c.RewardRange1)=0;
RewardHist1=([RewardHist1 RewardHist1_1]);
RewardHist1=RewardHist1(randperm(length(RewardHist1)));
c.Offer1Rew=RewardHist1(1);

RewardHist2(1:c.RewardRange2)=1;
RewardHist2_1(1:100-c.RewardRange2)=0;
RewardHist2=([RewardHist2 RewardHist2_1]);
RewardHist2=RewardHist2(randperm(length(RewardHist2)));
c.Offer2Rew=RewardHist2(1);

PunishmentHist1(1:c.PunishmentRange1)=1;
PunishmentHist1_1(1:100-c.PunishmentRange1)=0;
PunishmentHist1=([PunishmentHist1 PunishmentHist1_1]);
PunishmentHist1=PunishmentHist1(randperm(length(PunishmentHist1)));
c.Offer1Pun=PunishmentHist1(1);

PunishmentHist2(1:c.PunishmentRange2)=1;
PunishmentHist2_1(1:100-c.PunishmentRange2)=0;
PunishmentHist2=([PunishmentHist2 PunishmentHist2_1]);
PunishmentHist2=PunishmentHist2(randperm(length(PunishmentHist2)));
c.Offer2Pun=PunishmentHist2(1);

c.ActualRewardOffer1=rew1*c.Offer1Rew;
c.ActualDelayOffer1=pun1*c.Offer1Pun;

c.ActualRewardOffer2=rew2*c.Offer2Rew;
c.ActualDelayOffer2=pun2*c.Offer2Pun;


c.maxValrange=10;

c.rewfactoffer1=randi(length(c.rewarddist));
c.rewfactoffer2=randi(length(c.rewarddist));
c.punfactoffer1=randi(length(c.rwd_delay));
c.punfactoffer2=randi(length(c.rwd_delay));

c.maxValrangeOf1R=c.maxValrange;
c.maxValrangeOf1P=c.maxValrange;
c.maxValrangeOf2R=c.maxValrange;
c.maxValrangeOf2P=c.maxValrange;


c.RewardRange1=(c.RewardRange1./c.maxValrange);% ./ c.rewfactoffer1;
c.PunishmentRange1=(c.PunishmentRange1 ./c.maxValrange);% ./ c.punfactoffer1;
c.RewardRange2=(c.RewardRange2./c.maxValrange);%./ c.rewfactoffer2;
c.PunishmentRange2=(c.PunishmentRange2./c.maxValrange);%./ c.punfactoffer2;


c.rewardorpunishfirst= 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Angs=[0 180]; c.angs=Angs(1:2);

c.AmpUse=11;

c.whichtoshowfirst=randi(2);

c.feedid=8000+randi(4)-1;

c.fractalid=c.feedid;

location=-1;
c.targAngle             = -1; location; %rand*360;

c.targAmp               = 0;
s.targXY                = [0 0];

c.ITI_dur=ITI_dur;
c.TS_dur=TS_dur;
%c.rwd_delay=CS_dur;
c.trace_dur=trace_dur;
c.setupITI=0;
c.freeoutcometype=0; clear randnum setupITI

end


%% Setup: Define colors and setup charts
function [CLUT_, images_]        =   CLUTmaker(trialimagesid, c)

im1=[]; im2=[]; im3=[]; im4=[];

oneimage=0;
if size(trialimagesid,2)==1
    oneimage=1;
end

for getim=1:size(trialimagesid,2)
    % if c.fixreq == 1
    %     readinimage=['i' int2str(trialimagesid(getim)) '.tif'];
    % elseif c.fixreq == 2
    readinimage=['j' int2str(trialimagesid(getim)) '.tif'];
    % end
    
    cd fractals
    readinimage=imread(readinimage);
    cd ..
    if size(trialimagesid,2)>1 %get all the images to make CLUTs
        
        if getim==1
            im1=readinimage;
        elseif getim==2
            im2=readinimage;
        elseif getim==3
            im3=readinimage;
        elseif getim==4
            im4=readinimage;
        end
        
    elseif size(trialimagesid,2)==1
        im1=readinimage;
        im2=readinimage;
    end
    clear readinimage getim
end


% what are their sizes?
% least ONE dimension is common between the images.
% first, make a big image by appending one image to the other.
%bigIm = [im1(1:min([n1 n3]),:,:), im2];

n1=[]; n3=[]; n5=[]; n7=[];
try
    [n1, n2, ~] = size(im1);
    [n3, n4, ~] = size(im2);
    [n5, n6, ~] = size(im3);
    [n7, n8, ~] = size(im4);
end
dimentest=nonzeros([n1, n3, n5, n7]);
mindimen=find(dimentest==min(dimentest)); mindimen=mindimen(1);
mindimen=dimentest(mindimen);
try
    im1=im1(1:mindimen,:,:);
    im2=im2(1:mindimen,:,:);
    im3=im3(1:mindimen,:,:);
    im4=im4(1:mindimen,:,:);
end
dimentest=nonzeros([n2, n4, n6, n8]);
mindimen=find(dimentest==min(dimentest)); mindimen=mindimen(1);
mindimen=dimentest(mindimen);
try
    im1=im1(:,1:mindimen,:);
    im2=im2(:,1:mindimen,:);
    im3=im3(:,1:mindimen,:);
    im4=im4(:,1:mindimen,:);
end

if isempty(im3)==1 && isempty(im4)==1
    bigIm=[im1,im2];
    % make an indexed version of the appended big image, and a CLUT
    [imIndexed, CLUT_] = rgb2ind(bigIm, 246, 'nodither');
    
    
elseif isempty(im3)==0 && isempty(im4)==0
    bigIm=[im1,im2,im3, im4];
    [imIndexed, CLUT_] = rgb2ind(bigIm, 246, 'nodither');
end

% separate the big indexed image
im1i=[]; im2i=[]; im3i=[]; im4i=[];
try
    im1i    = imIndexed(:, 1:size(imIndexed,2)/size(trialimagesid,2));
    im2i    = imIndexed(:, (size(imIndexed,2)/size(trialimagesid,2)+1):(2*size(imIndexed,2)/size(trialimagesid,2)));
    im3i    = imIndexed(:, (2*(size(imIndexed,2)/size(trialimagesid,2)))+1:(3*size(imIndexed,2)/size(trialimagesid,2)));
    im4i    = imIndexed(:, (3*(size(imIndexed,2)/size(trialimagesid,2)))+1:(4*size(imIndexed,2)/size(trialimagesid,2)));
end

if oneimage==1
    im2i=[];
    im3i=[];
    im4i=[];
end

if size(CLUT_,1) < 246
    CLUT_(length(CLUT_)+1:246,:)=0;
end
try
    images_(1).im1i=convertIndexedImageToL48DImage(im1i+10);
    images_(1).im2i=convertIndexedImageToL48DImage(im2i+10);
    images_(1).im3i=convertIndexedImageToL48DImage(im3i+10);
    images_(1).im4i=convertIndexedImageToL48DImage(im4i+10);
end

clear im1i im2i im3i im4i

end









