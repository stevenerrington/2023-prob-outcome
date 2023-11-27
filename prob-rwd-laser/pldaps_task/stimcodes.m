function codes = stimcodes

% This file contains the 'timestamp' and stimulus 'tag' codes that are
% Strobed by PLDAPS to the Omniplex system.
% WARNING: This is the key to the data. DO NOT change the contents of this
% file.

%% 
%codes.start = 1000;
%codes.stop = 1010;
codes.trialBegin = 1001;
codes.trialEnd = 1009;
codes.connectPLX = 11001;
codes.trialcount = 11002;
codes.trialnumber = 11003;
codes.blocknumber = 11004;
codes.state       = 11005;


codes.choicerefuse       = 3005;


codes.nonstart = 2006;
codes.fixbreak = 2007;
codes.fixacqd = 2008;

codes.fixdoton = 3001;
codes.fixdotoff = 3003;

codes.abortatfixation=3004;
%
codes.targeton = 4001;
codes.targeton2 = 4002;
codes.targetoff = 4003;
codes.targetonnofix = 4004;
codes.screenclear = 4005;
codes.rewarddot = 4008;

codes.startsendingtrialinfo=5000;
codes.endsendingtrialinfo=5001;

codes.window1chosen=9000;
codes.window2chosen=9001;
codes.choicetimeout=9002;



codes.monkeyescaped=9005;
codes.freereward=9006;
codes.freeairpuff=9006;
codes.monkeyface=9007;
codes.freelookarray=9008;

codes.monkeyenteredtargwin=9103; %NML testCode


%
codes.reward = 8000;
codes.noreward = 8001;
codes.airpuff = 8002;
codes.noairpuff = 8003;
codes.laser = 8004;
codes.nolaser = 8005;

%
codes.microstimon = 7001;
codes.saconset = 7005;


% Added 2019-06-14 by ESBM for indicating cue onset
% and cue identity
codes.feedon = 7070;
codes.feedoff = 7071;
% offset to add to feedback ID to convert it to an event code
% to strobe to Plexon. We need to do this because in the ApetAversiveINFONEW task,
% the feedback cue identities (feedid variables) were set to be:
%  Noinfo: 8000, 8010
%  Info: 8001, 8002, 8003, 8004
% ...which overlap with the event codes currently being used for reward, noreward, etc.
% So we will currently make a strobe code by adding a fixed offset to the feedid 
% (e.g. +100, so that feedid = 8000 ==> strobe code = 8100
codes.feedid_to_strobe_code_offset = +100;

% Added 2019-06-17 by AJ to strobe fractals IDs at the time of target onset
% offset to add to fractal ID to convert in to an event code 
% to strobe to Plexon. We nee to do this to avoid overlapping with  
% the fractals IDs codes (8800, 8801, ..., 9800, 9801, ...) sent
% at the the end of the trials. 
% We will make a strobe code by adding a fixed offset to the to the fractlid
% (e.g. +10000, so that fractalid = 8800 = 18800)
codes.targetid_to_strobe_code_offset = +10000;

% 9000s already used for choice trials and aversive/social stimuli
% codes.lowtone = 9001;
% codes.noisetone = 9002;
% codes.hightone = 9003;
% % 9000s already used for choice trials and aversive/social stimuli
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
























