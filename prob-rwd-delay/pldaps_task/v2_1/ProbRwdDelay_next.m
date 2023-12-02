function [PDS ,c ,s]= ProbRwdDelay_next(PDS ,c ,s)
%% next_trial function
% this is executed once at the beginning of each trial
% as the first step of the 'Run' action from the GUI
% (the other steps are 'run_trial' and 'finish_trial'
% This is where values are set as needed for setup the next trial


% Increment trial count
c.j = c.j + 1;


% Configure settings for repeat trials
% > If a good trial, get new settings
if c.repeatflag==0
    %% Next trial parameters
    [c, s]                  = nextparams(c, s);
    c.showfirst=0;
    c.outcomechannel = 0;
    
else
    c.showfirst=0;
    c.AmpUseAver=11;
    c.targAmp               = 0;
end

s.targFixDurReq = c.targFixDurReq;
c.chosen=0;
c.AmpUseAver=11;
c.outcomechannel = 0;
c.rwd_reveal_flag = 0;
c.delay_reveal_flag=0;

end

function [c, s]         = nextparams(c, s)

c.maxValrange = 10; % Max bar height

c.first_offer_idx = randi(2);

%%% ////////////////////////////////////////////////////////////////////////////
% Target location definition
%       Here we define the properties of the target stimulus
%%% ////////////////////////////////////////////////////////////////////////////
c.angs=[0 180]; % Target angles (left [0deg]; right [180deg])
c.AmpUse=11; % Target amplitude (11 degs)




%%% ////////////////////////////////////////////////////////////////////////////
% Attribute definition
%       Here we define the values of the attributes that will be presented with
%       each offer
%%% ////////////////////////////////////////////////////////////////////////////

% Define magnitudes of delay and reward
c.rwd_delay = [2 8]; % The short (1) and long (2) delay in seconds
c.rewarddist = [0.13*1.3 0.34*1.3]; % The small (1) and large reward magnitude.

% Define probabilities of delay and reward
rew_mag_offer1=[0 50 100]; delay_mag_offer1=[0 50 100];
rew_mag_offer2 = rew_mag_offer1; delay_mag_offer2 = delay_mag_offer1;

%%% ////////////////////////////////////////////////////////////////////////////
% Offer definition
%       Here we define the offers that will be presented 
%%% ////////////////////////////////////////////////////////////////////////////

% Ensure that offer A and offer B are not equal (i.e. different offers are presented)
for xB=1:100
    c.rew_mag_offer1=rew_mag_offer1(randi(length(rew_mag_offer1)));
    c.rew_mag_offer2=rew_mag_offer2(randi(length(rew_mag_offer2)));
    
    c.delay_mag_offer1=delay_mag_offer1(randi(length(delay_mag_offer1)));
    c.delay_mag_offer2=delay_mag_offer2(randi(length(delay_mag_offer2)));
    
    if (c.delay_mag_offer1==c.delay_mag_offer2 & c.rew_mag_offer1==c.rew_mag_offer2)
    else
        break
    end
end

% Determine the offer values to be presented
c.rew_mag_offer1=(c.rew_mag_offer1./c.maxValrange);
c.delay_mag_offer1=(c.delay_mag_offer1 ./c.maxValrange);
c.rew_mag_offer2=(c.rew_mag_offer2./c.maxValrange);
c.delay_mag_offer2=(c.delay_mag_offer2./c.maxValrange);

%%% ////////////////////////////////////////////////////////////////////////////
% Choice and outcome definition
%       Here we define the outcomes for the given choices and offers
%%% ////////////////////////////////////////////////////////////////////////////
% Run a permutation -------------------------------------------
% This willdetermine if the outcome will be small/large (for reward)
% or short/long (for delay). This is required for 50% conditions, where
% this variable will define the actual outcomes

rew1=1;    delay1=1; rew2=1;    delay2=1;

clear RewardHist1 RewardHist2 DelayHist1 DelayHist2
RewardHist1(1:c.rew_mag_offer1)=1; RewardHist1_1(1:100-c.rew_mag_offer1*c.maxValrange)=0;
RewardHist1=([RewardHist1 RewardHist1_1]); RewardHist1=RewardHist1(randperm(length(RewardHist1)));

RewardHist2(1:c.rew_mag_offer2)=1; RewardHist2_1(1:100-c.rew_mag_offer2*c.maxValrange)=0;
RewardHist2=([RewardHist2 RewardHist2_1]); RewardHist2=RewardHist2(randperm(length(RewardHist2)));

DelayHist1(1:c.delay_mag_offer1)=1; DelayHist1_1(1:100-c.delay_mag_offer1*c.maxValrange)=0;
DelayHist1=([DelayHist1 DelayHist1_1]); DelayHist1=DelayHist1(randperm(length(DelayHist1)));

DelayHist2(1:c.delay_mag_offer2)=1; DelayHist2_1(1:100-c.delay_mag_offer2*c.maxValrange)=0;
DelayHist2=([DelayHist2 DelayHist2_1]); DelayHist2=DelayHist2(randperm(length(DelayHist2)));

% Save permutation outcome -------------------------------------
% These variables are flags. 0 will indicate a small magnitude, whilst
% 1 will indicate a large magnitude.

c.ActualRewardOffer1=rew1*RewardHist1(1); % Offer 1 reward magnitude
c.ActualDelayOffer1=delay1*DelayHist1(1); % Offer 1 delay magnitude

c.ActualRewardOffer2=rew2*RewardHist2(1); % Offer 2 reward magnitude
c.ActualDelayOffer2=delay2*DelayHist2(1); % Offer 2 delay magnitude

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ////////////////////////////////////////////////////////////////////////////
% Timing setting definition
%       Here we define the values of the timings within the task
%%% ////////////////////////////////////////////////////////////////////////////

% !SE - THESE NEED TO MOVE INTO SETTINGS SOMEWAY....
    % TAKEN FROM _run.m

c.intraoffer_interval = 0.5; % Time between offer 1 and offer 2 presentation
c.offer_display_period = 0.0; % Time for which both offers are displayed after choice has been made
c.choice_reveal_dur = 1.0; % Time between choice displayed and the delay reveal presentation
c.delayreveal_timer_dur = 1.0; % Time between delay reveal and the start of the timer
c.timer_rwdreveal_dur = 0.0; % Time between timer completion and reward reveal
c.rwdreveal_rwddel_dur = 1.0; % Time between reward reveal and reward delivery
c.rwddel_iti_dur = 1.0; % Time between reward delivery and ITI start

% Define cue presentation sizes
c.small_reward_cuesize = 1; % Height of bar for small reward magnitude attribute
c.large_reward_cuesize = 9; % Height of bar for large reward magnitude attribute
c.short_delay_cuesize = 2; % Height of bar for short delay magnitude attribute
c.long_delay_cuesize = 8; % Height of bar for long delay magnitude attribute

% Define timer step (based on maximum delay and the cue size)
c.tick_step = 1/((max(c.rwd_delay)*1000)/c.long_delay_cuesize);

% Initialize variables !SE TO CHECK
c.RwdMagnitude_outcome = 0; % !SE THIS MAY BE ABLE TO GO
c.tick_diff = 0; % !SE THIS MAY BE ABLE TO GO

%%% ////////////////////////////////////////////////////////////////////////////
% ITI definitions
%       Here we define the properties of the inter-trial interval
%%% ////////////////////////////////////////////////////////////////////////////
c.ITI_dur = 0.5; % ITI duration in seconds
c.iti_rwd_amount = 0.0;


end





