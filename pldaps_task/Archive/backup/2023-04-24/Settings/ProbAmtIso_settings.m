function [m, s, c] = ProbAmtIso_settings(a,b,c)
% Joy press + Fixation + Release then reward settings file
% fpon means FP on or Fp off, fixholdduration = duration that the monkey
% has to press the joystick

disp('Settings')

%% VALUES THAT WILL FIRST SHOW UP IN MENU

% 1
clear c

c.startBlock = 1;
c.targetAcquisitionRequired = 0.100;

c.fixOverlap = 0.5;%  Overlap of fixation and CS stimuli during which monk must maintain fixation
% 2
% maximum fixation-only time before target onset
c.probblockonly        = 0;

% minimum fixation duration
c.minFixDur        = 1;

% 2
% maximum fixation duration
c.maxFixDur        = 1;

c.freeRewardProbability =0.01;

% 5
% fixation point window height in deg
c.fp1WindH          = 3;

% 6
% fixation point window width in deg
c.fp1WindW          = 3;

%maximum duration we give the monkey to fixate before aborting the trial
%and going to ITI in SECONDS
c.maxFixWait = 5;

%choice fixation duration
c.targFixDurReq=0.5;

% fixation point window height in deg
c.tp1WindH          = 5;

% fixation point window width in deg
c.tp1WindW          = 5;

%duration of choice
c.choicemax=5;

% 3
% fixation point/window hoirzontal center (in degrees).
c.fpX               = 0;

% 4
% fixation point/window vertical center (in degrees).
c.fpY               = 0;


% 3
% minimum fixation/target overlap duration
c.overlapMin        = 0;

% 4
% maximum fixation/target overlap duration
c.overlapMax        = 0;

% 5
% minimum saccade-latency criterion
c.minLatency        = 0;

% 6
% maximum saccade-latency criterion
c.maxLatency        = 0;

% 7
% minimum post-saccade fixation duration
c.minTargFix        = 0;

% 8
% maximum post-saccade fixation duration
c.maxTargFix        = 0;

% 9
% reward magnitude (solenoid opening time in seconds)
c.rewardDur         = 0.2;

% 10
% length of velocity-filter
c.vFiltLength       = 5;

% 11
% pass = 1; simulate correct trials (for debugging)
c.passEye           = 0;

% 12
% online velocity threshold
c.vThresh           = 25;
c.postChoiceOnScreenTime = 1;

%% The following values must always be included and defined
%% These two values are always shown in menu

% Define the m-files used for this protocol
% "initialization" m-file
m.initialization_file   = 'ProbAmtIso_init.m';   %'VisSac_init.m';

% "next_trial" m-file
m.next_trial_file       = 'ProbAmtIso_next.m';

% "run_trial" m-file
m.run_trial_file        = 'ProbAmtIso_run.m';

% "finish_trial" m-file
m.finish_trial_file     = 'ProbAmtIso_finish.m';

% "savedata" m-file
m.action_1              = 'savedata.m';

% "saveplot" m-file
m.action_2              = 'saveplot.m';

% plot psychometric function m-file
m.action_3              = 'datatoworkspace.m';

% dump data into workspace
m.action_4              = 'playnoise.m';

% Define the prefix for the Output File
c.output_prefix         = 'ProbRwdPunish';

% Define Banner text to identify the experimental protocol
c.protocol_title        = 'ProbRwdPunish';

%% End of obligatory values section


%% Other parameter values

% how long to time-out after an error-trial (in seconds)?
%c.timeoutdur        = 0.25;

% maximum time to wait for fixation-acquisition
%c.maxFixWait        = 1;


c.TargAmp        = 10;


% number of possible target-directions
c.numTargAngles     = 8;

% delay reward delivery after a correctly performed trial
c.rewardDelay       = 0; %0.35;

% required consequtive trials for bonus-reward
%c.conseqtrials      = 10;

% do we want there to be a time-out penalty following incorrect trials?
%c.wanttimeout       = 1;

% ITERATOR for current trial count
c.j                 = 0;

% current trial number (excluding fixation breaks and non-starts)
c.trialnumber       = 1;

% fixation point/window hoirzontal center (in degrees).
c.fpX               = 0;

% fixation point/window vertical center (in degrees).
c.fpY               = 0;





% Total number of trials to run
%c.finish            = 5000;

% FP dimming (or going off).
%c.fpdimflag         = 0;

% pass = 1; simulate correct trials (for debugging)
%c.passJoy           = 0;

% cursor (fixation) radius in pixels
%c.cursorR           = 6;

% Gaze-position indicator radius in pixels
c.EyePtR            = 3;

% fixation-point pen-thickness
c.fixdotW           = 8;


c.fixwinW           = 2;

% flag variable controls trial-randomization stuff...
%c.flag              = 2;

% Voltage joyr press ON
%c.joythP            = 0.5;

% joystick release check voltage. (press is < joythP; release is >= joythR)
%c.joythR            = 2;

% cursor width in pixels
c.cursorW           = 6;

% framerate
c.framerate         = 100;

% using datapixx
c.useDataPixxBool   = 1;

% ITERATOR for # of good trials
%c.goodtrial         = 0;

% 0 = continue, 1 = pause, 2 = quit
c.quit              = 0;

% zero for one screen set-up, 1 or 2 for multiscreen
c.screen_number     = 1;

c.minTargAmp        = c.TargAmp;

c.maxTargAmp        = c.TargAmp;

% minimum fixation-only time before target onset
c.freelookingset        = 6000;

% time before start of joystick press check (s)
%c.freeduration      = 0;

% how many rasters do we have?
c.rasterLineCount(1:6) =0;

% max length of the trial (s)
%c.maxDur            = 15;

% Joybar edges for the second CLUT
%c.joyBarCoords      = [1600  800  1700  1100];

% psychometric function bins
%c.psychFuncBins     = 10;

%%  Status values.
s.TrialNumber   = 1; % What is the current trial number?
%s.fixXY         = [0 0];
%s.targXY        = [0 0];
s.TrialType     = 0;
s.TrialType1     = 0;
%s.rmi           = 0;
s.blocknumber =0;
s.successfulTrials = -1;
s.choiceblocksCompleted = 0;
s.choicetrialsCompleted = -1;
%s.preTargDur    = 0;
%s.overlapDur    = 0;
%s.targFixDurReq = 0;

end
