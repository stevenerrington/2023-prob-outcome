function codes = stimcodes

% This file contains the 'timestamp' and stimulus 'tag' codes that are
% Strobed by PLDAPS to the Omniplex system.
% WARNING: This is the key to the data. DO NOT change the contents of this
% file.

% Trial start
codes.trialBegin = 1001; 

% Fixation
codes.fixdoton = 3001; 
codes.fixdotoff = 3003; 
codes.nonstart = 2006; 
codes.fixbreak = 2007; 
codes.fixacqd = 2008; 

% Offer presentations
codes.offer1on = 4001; 
codes.offer2on = 4002; 

% Choice
codes.offer1chosen = 9000; 
codes.offer2chosen = 9001; 
codes.choiceselected = 9003; %IN 
codes.choicerefuse   = 3005; 
codes.choicepresented = 3006; 

% Timer
code.timerreveal = 7001; 
code.timerstart = 7002; 
code.timerend = 7003; 

% Reward
code.rwdreveal = 7001; 
codes.reward = 8000; 

% ITI
codes.itistart = 7501; 
codes.itirwd = 7502; 
codes.itiend = 7503; 

% Trial end
codes.trialEnd = 1009; 


%%% ////////////////////////////////////////////////////////////////////////////
% Legacy codes
%      Define strobe codes used in other tasks that were brought into this exp.
%      They are not required
%%% ////////
%
codes.connectPLX = 11001;
codes.trialcount = 11002;
codes.trialnumber = 11003;
codes.blocknumber = 11004;
codes.state       = 11005;
codes.abortatfixation=3004;
codes.monkeyescaped=9005;
codes.freereward=9006;
codes.freeairpuff=9006;
codes.monkeyface=9007;
codes.freelookarray=9008;
codes.monkeyenteredtargwin=9103;
codes.targetid_to_strobe_code_offset = +10000;
codes.lowtone = 9011;
codes.noisetone = 9012;
codes.hightone = 9013;
codes.freeflashsound= 9014;
codes.freesound=9015;
codes.freeflashsound=9016;
codes.freeflash=9010;
codes.freeflashsoundleftleft=9017;
codes.freeflashsoundleftrigh=9018;
codes.freeflashsoundrightright=9019;
codes.freeflashsoundrightleft=9020;
codes.freesmallreward=9021;
codes.feedon = 7070;
codes.feedoff = 7071;
codes.feedid_to_strobe_code_offset = +100;
codes.saconset = 7005;
codes.airpuff = 8002;
codes.noairpuff = 8003;
codes.laser = 8004;
codes.nolaser = 8005;
codes.startsendingtrialinfo=5000;
codes.endsendingtrialinfo=5001;
codes.choicetimeout=9002;
codes.targetoff = 4003;
codes.targetonnofix = 4004;
codes.screenclear = 4005;
codes.rewarddot = 4008;