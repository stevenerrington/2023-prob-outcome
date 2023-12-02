function [PDS ,c ,s]= ProbAmtIso_run(PDS ,c ,s)

% Note: Issues may occur with the feedback/outcome epochs if
% c.rewardorpunishfirst != 1 (SE: 2023-03-27).

% Setup trial based parameters
s.fixDur  = 0.5;

% Initialize trial-variables from the init function
[PDS, c, s, t]      = trial_init(PDS, c, s);
t.wlCount = 0;

c.intrareveal_interval = 1.0;
c.reveal_outcome_interval = 1.0;
c.intraoutcome_interval = 0;
c.tick_diff = 0;
c.tick_step = 1/((max(c.rwd_delay)*1000)/6.66);

c.large_reward_cuesize = 9;
c.small_reward_cuesize = 1;


%% EXPERIMENT LOOP >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

while  ~any(t.state == t.endStates) && c.quit == 0
    
    % Iterate loop-count;
    t.wlCount = t.wlCount + 1;
    
    % Get analog voltages (joystick and gaze position)
    [s.EyeX, s.EyeY, t.joy, eyeXd, eyeYd] = getEyeJoy(c);
    [lickSpoutInstantForce] = getLickForce(c);
    
    % NOTE: eyeXd and eyeYd are for velocity calculation and can eventually be
    %       removed.
    % FOR TESTING: s.EyeY=rand*50; s.EyeX=randsample([-180 180],1);
    
    
    t.eyePos(t.wlCount, :)    = [eyeXd, eyeYd, t.joy, GetSecs];
    t.lickSpoutForce(t.wlCount, :)    = [lickSpoutInstantForce, GetSecs];
    
    % Setup eye-position variables
    c.sampleInTargetZonevector(1,t.wlCount) =[false];% seed ongoing logical arrays with zeros
    c.sampleInTargetZonevector(2,t.wlCount) =[false];
    c.blinkLogicalSamples(t.wlCount) =[false];
    
    % Get time relative to trial start
    t.ttime = GetSecs - t.trstart;
    t.timeVect(t.wlCount) = t.ttime;
    
    % Detect blinks
    if t.joy < t.blinkThreshold % && s.EyeX<-40  && s.EyeY<-40
        %inBlinkState
        thrownBlinkFlag = exist('blinkStartTime', 'var');
        if thrownBlinkFlag == 0
            blinkStartTime = GetSecs - t.trstart;
            %first sample of bliknk
        elseif (( (GetSecs - t.trstart) - blinkStartTime) < t.blinkTimeAllowed)
            % blink is under allowed time
            c.passEye = 1;
        elseif thrownBlinkFlag == 1 && ((GetSecs - t.trstart) - blinkStartTime > t.blinkTimeAllowed)
            % blink too long enter fixation broken loop
            clear blinkStartTime thrownBlinkFlag
            c.passEye = 0;
        end
        c.blinkLogicalSamples(t.wlCount) =[true];
    else
        c.passEye = 0;
        c.blinkLogicalSamples(t.wlCount) =[false];
    end
    
    
    % State switch:
    %       This will progress through the experiment using state logic.
    
    
    switch t.state
        
        % Trial start -----------------------------------
        case 0
            if t.wlCount ==1
                strobe(c.codes.trialBegin);
                t.timeofabort=NaN;
                tstate_back=NaN;
                c.repeatflag =0;
                
            end
            if GetSecs >= t.trstart + 0.1
                t.state     = 0.00001;
            end
            c.outcometrial=0;
            TimeTargon=NaN;
            
            % Add a fixspot on screen --------------------
        case 0.00001
            c.repeatflag=0;
            tstate_back=0;
            t.state     = 0.0001;
            t.fwcolor   = t.grey1c;
            t.fcolor    = 9;
            c.outcometrial=0;
            t.strobeOnFlip.logic = true;
            t.strobeOnFlip.value = c.codes.fixdoton;
            delayvar = GetSecs;
            t.timeofabort=NaN;
            fprintf('-------------------------- \n Trial %i \n', c.j)
            
            fprintf(' %i/%i (short/long delay); %i/%i (small/large reward); Good trials: %i      \n',...
                c.shortDelayCount, c.longDelayCount, c.smallRewardCount, c.largeRewardCount, sum(c.goodtrial))
            fprintf(' > Fix spot on \n')
            
            
        case 0.0001
            if GetSecs>=delayvar+0.5
                t.state=0.0055;
            end
            
            % Present the first option ---------------------
        case 0.0055
            t.state =  0.0505123;
            tstate_back = 0.005;
            t.strobeOnFlip.logic = true;
            t.strobeOnFlip.value = c.codes.targeton;
            c.loopCountOfTargetOn =t.wlCount;
            delayvar=GetSecs;
            fprintf(' > Choice 1 onset \n')
            
            
            % Present the second option --------------------
        case 0.0505123
            if (GetSecs - delayvar) >= 0.5
                t.state =0.0505;
                delayvar=GetSecs;
                c.showfirst=1;
                t.strobeOnFlip.logic = true;
                t.strobeOnFlip.value = c.codes.targeton2;
                fprintf(' > Choice 2 onset \n')
            end
            
        case 0.0505
            if (GetSecs - delayvar) >= 0.5
                t.state =0.0065;
                delayvar=GetSecs;
                tempback=delayvar;
                tempback1=tempback;
            end
            
            % Determine choice outcome --------------------
        case 0.0065
            temp1=GetSecs;
            s.targFixDurReq=c.targFixDurReq;
            %s.targFixDurReq=0.5;
            
            if checkEye(c.passEye,t.PtargXY -[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH]) && isnan(t.monkeyenteredtargwin)
                t.monkeyenteredtargwin =GetSecs;
                c.sampleInTargetZonevector(1,t.wlCount) =[true];
            elseif checkEye(c.passEye,t.PtargXY -[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH]) &&  ...
                    (GetSecs - t.monkeyenteredtargwin) > c.targetAcquisitionRequired ...
                    && isnan(t.monkeyenteredtargwinFix)
                c.sampleInTargetZonevector(1,t.wlCount) =[true];
                t.monkeyenteredtargwinFix=GetSecs - c.targetAcquisitionRequired;
            elseif ~checkEye(c.passEye,t.PtargXY -[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH])
                t.monkeyenteredtargwin=NaN;
                c.sampleInTargetZonevector(1,t.wlCount) =[true];
            elseif checkEye(c.passEye,t.PtargXY -[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH])
                c.sampleInTargetZonevector(1,t.wlCount) =[false];
            end
            
            
            % Impose a 5 second choice deadline:
            if GetSecs - tempback1 >= c.choicemax %if 5 seconds erase and abort.
                % if there are multiple fractals and the choice duration is
                % over move to the choice end state
                t.state=999900;
                c.repeatflag=1;
                t.timeofabort=GetSecs - t.trstart;
                temp=GetSecs;
                tstate_back=999999999;
                t.timeOUTCOME=NaN;
                fprintf(' > ! No choice selected ! \n')
                
            end
            
            % Option 2 (B) selected:
            if delayvar >= (tempback + s.targFixDurReq) && checkEye(c.passEye, t.ang2-[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH])
                fprintf(' > Choice 2 selected \n')
                
                c.chosenwindow=2; c.chosen=2;
                
                if c.rewardorpunishfirst==1
                    t.state                 = 0.05056;
                else
                    t.state                 = 0.05059;
                end
                
                t.strobeOnFlip.logic = true;
                t.strobeOnFlip.value = c.codes.window2chosen;
                delayvar = GetSecs;
                tstate_back=0.00557;
                
                t.timeChoice     = GetSecs - t.trstart;
                
                % s.RewardTime=c.ActualRewardOffer2;
                s.rewardDelay_=c.ActualDelayOffer2;
                
                % Reward amount setup ---------------------------
                if c.ActualRewardOffer2 == 1 % If prob is 100%
                    s.RewardTime = c.rewarddist(length(c.rewarddist)); % High magnitude
                else
                    s.RewardTime = c.rewarddist(1); % No Reward
                end
                
                % Delay setup ---------------------------
                if c.ActualDelayOffer2 == 1 % If prob is 100%
                    s.rewardDelay_ = c.rwd_delay(2); % Long delay
                else
                    s.rewardDelay_ = c.rwd_delay(1); % Short delay
                end
                
                c.intraoutcome_interval = s.rewardDelay_;
                
                
                % Option 1 (A) selected:
            elseif delayvar >= (tempback + s.targFixDurReq) && checkEye(c.passEye, t.ang1-[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH])
                % chosing of fractal one if fixated on for > delayvar
                
                fprintf(' > Choice 1 selected \n')
                
                c.chosenwindow=1;
                c.chosen=1;
                
                if c.rewardorpunishfirst==1
                    t.state                 = 0.05056;
                else
                    t.state                 = 0.05059;
                end
                
                t.strobeOnFlip.logic = true;
                t.strobeOnFlip.value = c.codes.window1chosen;
                delayvar = GetSecs;
                tstate_back=0.00557;
                
                t.timeChoice     = GetSecs - t.trstart;
                
                s.RewardTime=c.ActualRewardOffer1;
                s.rewardDelay_=c.ActualDelayOffer1;
                
                % Reward amount setup ---------------------------
                if c.ActualRewardOffer1 == 1 % If prob is 100%
                    s.RewardTime = c.rewarddist(length(c.rewarddist)); % High magnitude
                else
                    s.RewardTime = c.rewarddist(1); % No Reward
                end
                
                % Delay setup ---------------------------
                if c.ActualDelayOffer1 == 1 % If prob is 100%
                    s.rewardDelay_ = c.rwd_delay(2); % Long delay
                else
                    s.rewardDelay_ = c.rwd_delay(1); % Short delay
                end
                
                c.intraoutcome_interval = s.rewardDelay_;
                
                
            elseif ~checkEye(c.passEye, t.ang1-[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH]) & ~checkEye(c.passEye, t.ang2-[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH]);
                %  If out of both fractal choice windows reset the timer for choice
                tempback =temp1; % reset target fixation time if monkey is ooking out of both windows
                %              Can this handle rapid saccades between the fractals?
                c.setWindow=0;
                %NML set both choice entered vectors to 0...
                
                c.sampleInTargetZonevector(1,t.wlCount) = [false];
                c.sampleInTargetZonevector(2,t.wlCount) = [false];
                
            end
            delayvar = GetSecs;
            
            % Show delay outcome --------------------
        case 0.05056
            if (GetSecs - delayvar) >= 1 % a second after choice is confirmed
                tstate_back=0.005575;
                delayvar = GetSecs;
                t.state = 0.050563;
                tic
            end
            
            % Deliver delay outcome --------------------
        case 0.050563
            
            if (GetSecs - delayvar) >= c.reveal_outcome_interval
                delayvar = GetSecs;
                timervar = GetSecs;
                
                c.punishdel = 1;
                tstate_back=0.005575;
                
                t.state = 0.050561;
                fprintf([' > $ Delay reveal to delay epoch: ' num2str(toc) ' seconds\n'])
                tic
            end
            
            % Show reward outcome --------------------
        case 0.050561
            c.tick_diff = ((GetSecs - timervar)*1000)*c.tick_step;
            
            if (GetSecs - delayvar) >= c.intraoutcome_interval
                
                c.rwd_reveal_flag = 1;
                tstate_back=0.005575;
                
                t.state = 0.050562;
                delayvar = GetSecs;
                fprintf([' > $ Delay reveal to reward reveal: ' num2str(toc) ' seconds\n'])
                
                tic
            end
            
            % Deliver reward outcome ---------------
        case 0.050562
            if (GetSecs - delayvar) >= c.reveal_outcome_interval
                t.state = 99990;
                fprintf([' > $ Reward reveal to delivery: ' num2str(toc) ' seconds\n'])
                
            end
            
        case 0.050566
            if (GetSecs - delayvar) >= c.reveal_outcome_interval;
                t.state = 99990;
                delayvar=GetSecs;
            end
            
            % Deliver reward outcome --------------------
        case 0.05059
            
            if (GetSecs - delayvar) >= 1; tstate_back=0.005575; end
            
            if (GetSecs - delayvar) >= 3.5
                fprintf('Reward epoch... \n')
                t.state = 0.0505661;
                c.punishdel=1;
                if s.RewardTime>0
                    Volt                        = 4.0;
                    pad                         = 0.00;
                    Wave_time                   = s.RewardTime+pad;
                    t.Dacrate                   = 1000;
                    reward_Voltages             = [zeros(1,round(t.Dacrate*pad/2)) Volt*ones(1,round(t.Dacrate*s.RewardTime)) zeros(1,round(t.Dacrate*pad/2))];
                    t.ndacsamples               = floor(t.Dacrate*Wave_time);
                    t.dacBuffAddr               = 6e6;
                    t.chnl                      = c.outcomechannel;
                    Datapixx('RegWrRd');
                    DacData=Volt*ones(1,round(t.Dacrate*s.RewardTime));
                    DacData(length(DacData):1000)=0;
                    Datapixx('WriteDacBuffer', DacData);
                    Datapixx('RegWrRd');
                    Datapixx('SetDacSchedule', 0, [1000,1], 1000, t.chnl);
                    Datapixx('StartDacSchedule');
                    Datapixx('RegWrRd');
                    fprintf('!! Reward Delivered !!\n')
                end
                strobe(c.codes.reward);
                t.timeOUTCOME     = GetSecs - t.trstart;
                delayvar = GetSecs;
                % tstate_back=  0.0055559;
            end
            
            
        case 99990
            t.short_reward_del_flag = 0;
            t.long_reward_del_flag = 0;
            
            %tstate_back=t.state;
            if s.RewardTime>0
                Volt                        = 4.0;
                pad                         = 0.00;
                Wave_time                   = s.RewardTime+pad;
                t.Dacrate                   = 1000;
                reward_Voltages             = [zeros(1,round(t.Dacrate*pad/2)) Volt*ones(1,round(t.Dacrate*s.RewardTime)) zeros(1,round(t.Dacrate*pad/2))];
                t.ndacsamples               = floor(t.Dacrate*Wave_time);
                t.dacBuffAddr               = 6e6;
                t.chnl                      = c.outcomechannel;
                Datapixx('RegWrRd');
                DacData=Volt*ones(1,round(t.Dacrate*s.RewardTime));
                DacData(length(DacData):1000)=0;
                Datapixx('WriteDacBuffer', DacData);
                Datapixx('RegWrRd');
                Datapixx('SetDacSchedule', 0, [1000,1], 1000, t.chnl);
                Datapixx('StartDacSchedule');
                Datapixx('RegWrRd');
                fprintf(['!! Reward delivered: ' num2str(s.RewardTime) 'ms !! \n'])
                
                if s.RewardTime == min(c.rewarddist)
                    c.small_reward_del_flag = 1;
                    c.large_reward_del_flag = 0;
                else
                    c.small_reward_del_flag = 0;
                    c.large_reward_del_flag = 1;
                end
                
            end
            strobe(c.codes.reward);
            tstate_back=  0.0055559;
            t.timeOUTCOME     = GetSecs - t.trstart;
            t.state = 999905;
            delayvar=GetSecs;
            
            
            
        case 999905
            if (GetSecs - delayvar) >= c.intraoutcome_interval;
                
                fprintf('************* End of Trial ************* \n')
                fprintf('ITI: %i seconds... \n', c.ITI_dur)
                iti_start = GetSecs;
                t.state = 999910;
            end
            
            
        case 0.0505661
            if (GetSecs - delayvar) >= 1.5
                t.state =999901;
                delayvar=GetSecs;
                tstate_back=  0.0055559;
            end
            
        case 999901
            t.state = 999900;
            delayvar=GetSecs;
            s.TimeofPunish     = GetSecs - t.trstart;
            tstate_back=  0.0055559;
            
            
        case 999900
            if (GetSecs - temp) >= c.ITI_dur
                fprintf('End of ITI >>>>>>>>>>>>>>>>>>>>> \n')
                
                strobe(c.codes.trialEnd);
                t.state = 1.5;
                t.trialover     = GetSecs - t.trstart;
            end
            
            
        case 999910
            if (GetSecs - iti_start) >= 1
                t.iti_reward = GetSecs - t.trstart;
                t.state = 999906;
                
                if c.iti_rwd_amount>0
                    s.ITI_RewardTime = c.iti_rwd_amount;
                    
                    if s.ITI_RewardTime>0
                        Volt                        = 4.0;
                        pad                         = 0.00;
                        Wave_time                   = s.ITI_RewardTime+pad;
                        t.Dacrate                   = 1000;
                        reward_Voltages             = [zeros(1,round(t.Dacrate*pad/2)) Volt*ones(1,round(t.Dacrate*s.ITI_RewardTime)) zeros(1,round(t.Dacrate*pad/2))];
                        t.ndacsamples               = floor(t.Dacrate*Wave_time);
                        t.dacBuffAddr               = 6e6;
                        t.chnl                      = c.outcomechannel;
                        Datapixx('RegWrRd');
                        DacData=Volt*ones(1,round(t.Dacrate*s.ITI_RewardTime));
                        DacData(length(DacData):1000)=0;
                        Datapixx('WriteDacBuffer', DacData);
                        Datapixx('RegWrRd');
                        Datapixx('SetDacSchedule', 0, [1000,1], 1000, t.chnl);
                        Datapixx('StartDacSchedule');
                        Datapixx('RegWrRd');
                        fprintf('****ITI REWARD DELIVERED**** \n')
                    end
                    strobe(c.codes.reward);
                    t.timeOUTCOME     = GetSecs - t.trstart;
                    delayvar = GetSecs;
                    
                end
                
            end
            
        case 999906
            if (GetSecs - iti_start) >= c.ITI_dur
                fprintf('End of ITI >>>>>>>>>>>>>>>>>>>>> \n')
                
                strobe(c.codes.trialEnd);
                t.state = 1.5;
                t.trialover     = GetSecs - t.trstart;
            end
            
            
    end % // END OF STATE MACHINE
    
    try
        c.tstate_back =tstate_back ;
    end
    
    
    %% Draw: draw all relevant screens and options
    % Do all the drawing, first note what time it is so we can compute what
    % frame we're in, relative to cue-onset (timeCON).
    t.ttime       = GetSecs - t.trstart;
    
    if t.ttime > t.lastframetime + t.frametimestep - t.magicNumber
        
        % Fill the window with the background color.
        Screen('FillRect', c.window, convertColorToL48D(c.backcolor));
        
        % Draw the grid
        Screen('DrawLines', c.window, t.GridXY,[], convertColorToL48D( t.gridc), c.middleXY);
        %DrawFormattedText(c.window, 'PUT TRIAL INFO HERE', 'center', 40, convertColorToL48D(t.gridc));
        %Datapixx('RegWrRd');
        % Draw the gaze position, MUST DRAW THE GAZE BEFORE THE
        % FIXATION. Otherwise, when the gaze indicator goes over any
        % stimuli it will change the occluded stimulus' color!
        
        Screen('FillRect', c.window, convertColorToL48D(t.ecolor), [s.EyeX s.EyeY s.EyeX s.EyeY] + [-1 -1 1 1] * c.EyePtR + repmat(c.middleXY,1,2));
        Datapixx('RegWrRd');
        
        % Draw the fixation and or target point / window (if desired)
        if tstate_back==0
            fixdotframe(c, t);
        end
        if tstate_back==0.005
            t=maketargets(c, t);
        end
        
        if tstate_back==0.0055
            t=maketargetsFIXOVERLAP(c, t);
        end
        
        if tstate_back== 99990
            fixdotframeRew(c, t);
        end
        
        
        if tstate_back==0.00557
            t= maketargetspostchoice(c, t);
        end
        
        if tstate_back==0.005575
            t=maketargetspostchoiceShow(c, t);
        end
        
        
        if tstate_back >= 0.050510 & tstate_back < 0.050516
            t=maketargets(c, t);
        end
        
        
        if tstate_back==0.0055559
            makescreenblank(c,t,s);
            tstate_back = 1;
        end
        
        % Flip (note thef time relative to trial-start).
        %         t.lastframetime = Screen('Flip', c.window, GetSecs + 0.00) - t.trstart;
        t.lastframetime1= Screen('Flip', c.window, GetSecs + 0.00) ;
        t.lastframetime =   t.lastframetime1- t.trstart;
        
        
        if t.strobeOnFlip.value==c.codes.targetoff && t.strobeOnFlip.logic ==1
            t.timeTARGETOFF   = t.lastframetime;
        end
        
        if t.strobeOnFlip.value==c.codes.targeton && t.strobeOnFlip.logic ==1
            t.timeTARGETON     = t.lastframetime;
            strobe(c.fractalid + c.codes.targetid_to_strobe_code_offset);
        end
        
        if t.strobeOnFlip.value==c.codes.feedon && t.strobeOnFlip.logic ==1
            t.FEEDback     = t.lastframetime;
        end
        
        if t.strobeOnFlip.value==c.codes.fixdoton && t.strobeOnFlip.logic ==1
            t.timeFPON     = t.lastframetime;
        end
        
        if c.showfirst==1 && t.strobeOnFlip.logic ==1
            t.timeTARGETON2      = t.lastframetime;
        end
        
        % if this flip was a stimulus onset event, we want to tell plexon
        if t.strobeOnFlip.logic
            strobe(t.strobeOnFlip.value);
            t.strobeOnFlip.logic = false;
        end
        
    end
end

% Flip the screen
Screen('Flip', c.window);

% End of trial information:
%   Send data to plexon
sendPlexonInfo(c, s, t);
%   Finalize variables & store data to be saved.
[PDS, c, s] = trial_end(PDS, c, s, t);

end



%% Helper functions.

% Eye position/analog inputs
function [EyeX, EyeY, joy, eXd, eYd]  =   getEyeJoy(c)
% update data-pixx registers
Datapixx('RegWrRd')
% read voltages
V       = Datapixx('GetAdcVoltages');
% Convert eye-voltages into screen-pixels.
EyeX    = sign(V(1))*deg2pix(8*abs(V(1)),c);  % deg to pixx; sign change in X to account for camera inversion.
EyeY    = sign(V(2))*deg2pix(8*abs(V(2)),c);
% read joy-voltage
joy     = V(3);
eXd     = 8*V(1);
eYd     = 8*V(2);

end

% Lick force/analog input
function  [lickSpoutInstantForce] = getLickForce(c)
Datapixx('RegWrRd')
% read voltages
V       = Datapixx('GetAdcVoltages');
lickSpoutInstantForce = V(4); % licking neaby wall
end


% Check eye positions
function out = checkEye(pass, Eye, WinDim)
out = all(abs(Eye)<WinDim) || pass;
end

% Convert degrees to pixels
function pixels             =   deg2pix(degrees,c) % PPD pixels/degree
% deg2pix convert degrees of visual angle into pixels
pixels = round(tand(degrees)*c.viewdist*c.screenhpix/c.screenh);

end

% Add a frame around the fixation dot
function                        fixdotframe(c, t)
cursorR           = 9;
Screen('FrameRect',c.window, convertColorToL48D(t.fcolor),repmat(t.PfixXY + c.middleXY,1,2) + [-cursorR -cursorR cursorR cursorR],c.fixdotW)
Screen('FrameRect',c.window, convertColorToL48D(t.fwcolor),repmat(t.PfixXY + c.middleXY,1,2) + [-t.PfpWindW -t.PfpWindH t.PfpWindW t.PfpWindH],c.fixwinW)
end

% Make targets in relevant locations/with relevant stimuli
function t = maketargets(c, t)

c.middleXYt=c.middleXY;
c.middleXYt(2)=c.middleXYt(2)+60;

c.middleXYt1=c.middleXY;
c.middleXYt1(2)=c.middleXYt(2)-100;


if  c.showfirst>-1
    
    c.middleXYtt=c.middleXYt; c.middleXYtt(1)=c.middleXYtt(1)+70;
    colors=9;
    
    if c.whichtoshowfirst ==1
        ang=t.ang1;
        DelayRange=c.PunishmentRange1;
        RewardRange=c.RewardRange1;
        
        c.maxValrangeOfP=10;
        c.maxValrangeOfR=c.maxValrangeOf1R;
        
    else
        ang=t.ang2;
        DelayRange=c.PunishmentRange2;
        RewardRange=c.RewardRange2;
        
        c.maxValrangeOfP=10;
        c.maxValrangeOfR=c.maxValrangeOf2R;
    end
    
    if DelayRange == 0
        DelayRange = 3.3333;
    elseif DelayRange == 5
        DelayRange = 5.00;
    elseif DelayRange == 10
        DelayRange = 6.6666;
    end
  
    if RewardRange == 0
        RewardRange = c.small_reward_cuesize;
    elseif RewardRange == 5
        RewardRange = 5.00;
    elseif RewardRange == 10
        RewardRange = c.large_reward_cuesize;
    end
    
    
    PtpWindW    =  deg2pix(1,c); % target point window width
    PtpWindH    =  deg2pix(DelayRange,c); % target point window height
    Screen('FillRect',c.window, convertColorToL48D(colors),repmat(ang  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)
    n=c.maxValrangeOfP;
    PtpWindW    =  deg2pix(1,c); % target point window width
    PtpWindH    =  deg2pix(n,c); % target point window height
    Screen('FrameRect',c.window, convertColorToL48D(colors),repmat(ang  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)
    colors=10;
    
    PtpWindW    =  deg2pix(1,c); % target point window width
    PtpWindH    =  deg2pix(RewardRange,c); % target point window height
    Screen('FillRect',c.window, convertColorToL48D(colors),repmat(ang  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)
    
    n=c.maxValrangeOfR;
    PtpWindW    =  deg2pix(1,c); % target point window width
    PtpWindH    =  deg2pix(n,c); % target point window height
    Screen('FrameRect',c.window, convertColorToL48D(colors),repmat(ang  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)
    
    
    t.PtpWindW    =  deg2pix(6,c); % target point window width
    t.PtpWindH    =  deg2pix(8,c); % target point window height
    Screen('FrameRect',c.window, convertColorToL48D(t.fwcolor),repmat(ang  + c.middleXYt1,1,2) + [-t.PtpWindW -t.PtpWindH t.PtpWindW t.PtpWindH],c.fixwinW)
    
    
end


if  c.showfirst==1
    
    c.middleXYtt=c.middleXYt; c.middleXYtt(1)=c.middleXYtt(1)+70;
    colors=9;
    
    if c.whichtoshowfirst == 1
        ang=t.ang2;
        DelayRange=c.PunishmentRange2;
        RewardRange=c.RewardRange2;
        
        c.maxValrangeOfP=10;
        c.maxValrangeOfR=c.maxValrangeOf2R;
    else
        ang=t.ang1;
        DelayRange=c.PunishmentRange1;
        RewardRange=c.RewardRange1;
        
        c.maxValrangeOfP=10;
        c.maxValrangeOfR=c.maxValrangeOf1R;
    end
    
    if DelayRange == 0
        DelayRange = 3.3333;
    elseif DelayRange == 5
        DelayRange = 5;
    elseif DelayRange == 10
        DelayRange = 6.6666;
    end
    
    if RewardRange == 0
        RewardRange = c.small_reward_cuesize;
    elseif RewardRange == 5
        RewardRange = 5.00;
    elseif RewardRange == 10
        RewardRange = c.large_reward_cuesize;
    end
    
    PtpWindW    =  deg2pix(1,c); % target point window width
    PtpWindH    =  deg2pix(DelayRange,c); % target point window height
    Screen('FillRect',c.window, convertColorToL48D(colors),repmat(ang  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)
    n=c.maxValrangeOfP;
    PtpWindW    =  deg2pix(1,c); % target point window width
    PtpWindH    =  deg2pix(n,c); % target point window height
    Screen('FrameRect',c.window, convertColorToL48D(colors),repmat(ang  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)
    
    colors=10;
    PtpWindW    =  deg2pix(1,c); % target point window width
    PtpWindH    =  deg2pix(RewardRange,c); % target point window height
    Screen('FillRect',c.window, convertColorToL48D(colors),repmat(ang  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)
    
    n=c.maxValrangeOfR;
    PtpWindW    =  deg2pix(1,c); % target point window width
    PtpWindH    =  deg2pix(n,c); % target point window height
    Screen('FrameRect',c.window, convertColorToL48D(colors),repmat(ang  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)

    t.PtpWindW    =  deg2pix(6,c); % target point window width
    t.PtpWindH    =  deg2pix(8,c); % target point window height
    Screen('FrameRect',c.window, convertColorToL48D(t.fwcolor),repmat(ang  + c.middleXYt1,1,2) + [-t.PtpWindW -t.PtpWindH t.PtpWindW t.PtpWindH],c.fixwinW)

end

end

% Show selected option, post-choice
function t = maketargetspostchoice(c, t)

c.middleXYt=c.middleXY;
c.middleXYt(2)=c.middleXYt(2)+60;
c.middleXYt1=c.middleXY;
c.middleXYt1(2)=c.middleXYt(2)-100;
c.AmpUse=11;


if  c.chosen==1
    
    if c.PunishmentRange1 == 0
        DelayRange = 3.3333;
    elseif c.PunishmentRange1 == 5
        DelayRange = 5;
    elseif c.PunishmentRange1 == 10
        DelayRange = 6.6666;
    end
    
    if c.RewardRange1 == 0
        RewardRange = c.small_reward_cuesize;
    elseif c.RewardRange1 == 5
        RewardRange = 5.00;
    elseif c.RewardRange1 == 10
        RewardRange = c.large_reward_cuesize;
    end    
    
    if  c.punishdel==0
        
        colors=9;
        c.middleXYtt=c.middleXYt; c.middleXYtt(1)=c.middleXYtt(1)+70;
        
        PtpWindW    =  deg2pix(1,c); % target point window width
        PtpWindH    =  deg2pix(DelayRange,c); % target point window height
        
        Screen('FillRect',c.window, convertColorToL48D(colors),repmat(t.ang1  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)
        n=c.maxValrangeOf1P;
        PtpWindW    =  deg2pix(1,c); % target point window width
        PtpWindH    =  deg2pix(n,c); % target point window height
        Screen('FrameRect',c.window, convertColorToL48D(colors),repmat(t.ang1  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)
    end
    %%%
    
    colors=10;
    PtpWindW    =  deg2pix(1,c); % target point window width
    PtpWindH    =  deg2pix(RewardRange,c); % target point window height
    Screen('FillRect',c.window, convertColorToL48D(colors),repmat(t.ang1  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)
    n=c.maxValrangeOf1R;
    PtpWindW    =  deg2pix(1,c); % target point window width
    PtpWindH    =  deg2pix(n,c); % target point window height
    Screen('FrameRect',c.window, convertColorToL48D(colors),repmat(t.ang1  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)
    
end

if  c.chosen==2
    
    if c.PunishmentRange2 == 0
        DelayRange = 3.3333;
    elseif c.PunishmentRange2 == 5
        DelayRange = 5;
    elseif c.PunishmentRange2 == 10
        DelayRange = 6.6666;
    end
    
    if c.RewardRange2 == 0
        RewardRange = c.small_reward_cuesize;
    elseif c.RewardRange2 == 5
        RewardRange = 5.00;
    elseif c.RewardRange2 == 10
        RewardRange = c.large_reward_cuesize;
    end
    
    if  c.punishdel==0
        
        colors=9;
        c.middleXYtt=c.middleXYt; c.middleXYtt(1)=c.middleXYtt(1)+70;
        
        PtpWindW    =  deg2pix(1,c); % target point window width
        PtpWindH    =  deg2pix(DelayRange,c); % target point window height
        
        Screen('FillRect',c.window, convertColorToL48D(colors),repmat(t.ang2  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)
        n=c.maxValrangeOf2P;
        PtpWindW    =  deg2pix(1,c); % target point window width
        PtpWindH    =  deg2pix(n,c); % target point window height
        Screen('FrameRect',c.window, convertColorToL48D(colors),repmat(t.ang2  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)
    end
    %%%
    
    colors=10;
    PtpWindW    =  deg2pix(1,c); % target point window width
    PtpWindH    =  deg2pix(RewardRange,c); % target point window height
    Screen('FillRect',c.window, convertColorToL48D(colors),repmat(t.ang2  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)
    n=c.maxValrangeOf2R;
    PtpWindW    =  deg2pix(1,c); % target point window width
    PtpWindH    =  deg2pix(n,c); % target point window height
    Screen('FrameRect',c.window, convertColorToL48D(colors),repmat(t.ang2  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)
end
end

% Show selected option, with reveal
function t = maketargetspostchoiceShow(c, t)

c.middleXYt=c.middleXY;
c.middleXYt(2)=c.middleXYt(2)+60;
c.middleXYt1=c.middleXY;
c.middleXYt1(2)=c.middleXYt(2)-100;
c.AmpUse=11;

rwd_reveal_color = convertColorToL48D(7);%[102 178 255];
pun_reveal_color = convertColorToL48D(5);%[255 0 0];


switch c.chosen
    case 1 % Offer 1
        targ_angle_in = t.ang1;
        max_val_range_pun = c.maxValrangeOf1P;
        offer_pun = c.Offer1Pun;
        reward_range = c.RewardRange1;
        punish_range = c.PunishmentRange1;
        max_val_range_rwd = c.maxValrangeOf1R;
        offer_rwd = c.Offer1Rew;
        
    case 2 % Offer 2
        targ_angle_in = t.ang2;
        max_val_range_pun = c.maxValrangeOf2P;
        offer_pun = c.Offer2Pun;
        reward_range = c.RewardRange2;
        punish_range = c.PunishmentRange2;
        max_val_range_rwd = c.maxValrangeOf2R;
        offer_rwd = c.Offer2Rew;
end


if (max_val_range_pun*offer_pun) == 0
    timer_start = 3.333;
    c.short_delay_flag = 1;
    c.long_delay_flag = 0;
else
    timer_start = 6.666;
    c.short_delay_flag = 0;
    c.long_delay_flag = 1;
end

if reward_range == 0
    RewardRange = c.small_reward_cuesize;
elseif reward_range == 5
    RewardRange = 5.00;
elseif reward_range == 10
    RewardRange = c.large_reward_cuesize;
end

if offer_rwd == 0
    RewardRange_outcome = c.small_reward_cuesize;
else
    RewardRange_outcome = c.large_reward_cuesize;    
end


if c.reveal_first_idx == 1 % REVEAL Delay FIRST
    
    if c.punishdel==0
        % Reward ----------------------
        colors=10;
        PtpWindW    =  deg2pix(1,c); % target point window width
        PtpWindH    =  deg2pix(RewardRange,c); % target point window height
        Screen('FillRect',c.window, convertColorToL48D(colors),repmat(targ_angle_in  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)
        
        n=max_val_range_rwd;
        PtpWindW    =  deg2pix(1,c); % target point window width
        PtpWindH    =  deg2pix(n,c); % target point window height
        Screen('FrameRect',c.window, convertColorToL48D(colors),repmat(targ_angle_in  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)
        
        % Delay ----------------------
        colors=9;
        PtpWindW    =  deg2pix(1,c); % target point window width
        PtpWindH    =  deg2pix(timer_start,c); % target point window height
        c.middleXYtt=c.middleXYt; c.middleXYtt(1)=c.middleXYtt(1)+70;
        Screen('FillRect',c.window, convertColorToL48D(colors),repmat(targ_angle_in  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)
        
        n=max_val_range_pun;
        PtpWindW    =  deg2pix(1,c); % target point window width
        PtpWindH    =  deg2pix(n,c); % target point window height
        Screen('FrameRect',c.window, pun_reveal_color,repmat(targ_angle_in  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)
        
    elseif  c.punishdel==1
        if c.rwd_reveal_flag == 0
            % Reward ----------------------
            colors=10;
            PtpWindW    =  deg2pix(1,c); % target point window width
            PtpWindH    =  deg2pix(RewardRange,c); % target point window height
            Screen('FillRect',c.window, convertColorToL48D(colors),repmat(targ_angle_in  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)
            
            n=max_val_range_rwd;
            PtpWindW    =  deg2pix(1,c); % target point window width
            PtpWindH    =  deg2pix(n,c); % target point window height
            Screen('FrameRect',c.window, convertColorToL48D(colors),repmat(targ_angle_in  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)
            
            
            % Delay ----------------------
            colors=9;
            timer_height = timer_start-c.tick_diff;
            
            if timer_height < 0
                timer_height = 0;
            end
            
            PtpWindW    =  deg2pix(1,c); % target point window width
            PtpWindH    =  deg2pix(timer_height,c); % target point window height
            
            c.middleXYtt=c.middleXYt; c.middleXYtt(1)=c.middleXYtt(1)+70;
            Screen('FillRect',c.window, pun_reveal_color,repmat(targ_angle_in  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)
            
            n=max_val_range_pun;
            PtpWindW    =  deg2pix(1,c); % target point window width
            PtpWindH    =  deg2pix(n,c); % target point window height
            Screen('FrameRect',c.window, pun_reveal_color,repmat(targ_angle_in  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)
            
            
        elseif c.rwd_reveal_flag == 1
            % Reward ----------------------
            colors=10;
            PtpWindW    =  deg2pix(1,c); % target point window width
            PtpWindH    =  deg2pix(RewardRange_outcome,c); % target point window height
            Screen('FillRect',c.window, convertColorToL48D(colors),repmat(targ_angle_in  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)
            
            n=max_val_range_rwd;
            PtpWindW    =  deg2pix(1,c); % target point window width
            PtpWindH    =  deg2pix(n,c); % target point window height
            Screen('FrameRect',c.window, rwd_reveal_color,repmat(targ_angle_in  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)
            
            % Delay ----------------------
            PtpWindW    =  deg2pix(1,c); % target point window width
            PtpWindH    =  deg2pix(max_val_range_pun*offer_pun,c); % target point window height
            c.middleXYtt=c.middleXYt; c.middleXYtt(1)=c.middleXYtt(1)+70;
            Screen('FillRect',c.window, convertColorToL48D(c.backcolor),repmat(targ_angle_in  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)
            
            n=max_val_range_pun;
            PtpWindW    =  deg2pix(1,c); % target point window width
            PtpWindH    =  deg2pix(n,c); % target point window height
            Screen('FrameRect',c.window, convertColorToL48D(c.backcolor),repmat(targ_angle_in  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)
            
        end
        
    end
    
    
    
    
else %%% REVEAL RWD FIRST
    colors=10;
    
    PtpWindW    =  deg2pix(1,c); % target point window width
    PtpWindH    =  deg2pix(max_val_range_rwd*offer_rwd,c); % target point window height
    Screen('FillRect',c.window, convertColorToL48D(colors),repmat(targ_angle_in  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)
    
    n=max_val_range_rwd;
    PtpWindW    =  deg2pix(1,c); % target point window width
    PtpWindH    =  deg2pix(n,c); % target point window height
    Screen('FrameRect',c.window, rwd_reveal_color,repmat(targ_angle_in  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)
    
    c.middleXYtt=c.middleXYt; c.middleXYtt(1)=c.middleXYtt(1)+70;
    
    %%%
    if c.punishdel==0
        
        colors=9;
        
        PtpWindW    =  deg2pix(1,c); % target point window width
        PtpWindH    =  deg2pix(punish_range,c); % target point window height
        Screen('FillRect',c.window, convertColorToL48D(colors),repmat(targ_angle_in  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)
        
        n=max_val_range_pun;
        PtpWindW    =  deg2pix(1,c); % target point window width
        PtpWindH    =  deg2pix(n,c); % target point window height
        Screen('FrameRect',c.window, convertColorToL48D(colors),repmat(targ_angle_in  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)
        
        
    elseif  c.punishdel==1
        colors=9;
        
        PtpWindW    =  deg2pix(1,c); % target point window width
        PtpWindH    =  deg2pix(max_val_range_pun*offer_pun,c); % target point window height
        Screen('FillRect',c.window, convertColorToL48D(colors),repmat(targ_angle_in  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)
        
        n=max_val_range_pun;
        PtpWindW    =  deg2pix(1,c); % target point window width
        PtpWindH    =  deg2pix(n,c); % target point window height
        Screen('FrameRect',c.window, pun_reveal_color,repmat(targ_angle_in  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)
        
        
    end
    
end

end

% Create a blank screen
function makescreenblank(c, t, s)
Screen('FillRect', c.window, convertColorToL48D(c.backcolor));
Screen('DrawLines', c.window, t.GridXY,[], convertColorToL48D( t.gridc), c.middleXY);
%Screen('FillRect', c.window, convertColorToL48D(t.ecolor), [s.EyeX s.EyeY s.EyeX s.EyeY] + [-1 -1 1 1]*c.EyePtR + repmat(c.middleXY,1,2));
end


function                        fixdotframeRew(c, t)
cursorR           = 3;

Screen('FrameRect',c.window, convertColorToL48D(t.fcolor),repmat(t.PfixXY + c.middleXY,1,2) + [-cursorR -cursorR cursorR cursorR],c.fixdotW)
Screen('FrameRect',c.window, convertColorToL48D(t.fwcolor),repmat(t.PfixXY + c.middleXY,1,2) + [-t.PfpWindW -t.PfpWindH t.PfpWindW t.PfpWindH],c.fixwinW)
end


function [PDS, c, s, t]     =   trial_init(PDS, c, s)

% start of trial time
t.trstart = GetSecs;
Datapixx('RegWrRd');
t.vpixxstart = Datapixx('GetTime');

%%% Start ADC of Eyelink (x,y,pupil) and joystick data; 4 channels
maxDur              = 10;                     % how many seconds of data do we want to read?
adcRate             = 1000;                         % sampling rate
t.nAdcLocalBuffSpls = adcRate*maxDur;               % number of samples to preallocate for reading
t.LocalADCbuffer    = zeros(5,t.nAdcLocalBuffSpls);   % We'll acquire 4 ADC channels + 1 time-stamp channel into 5 rows
t.adcBuffBaseAddr   = 4e6;                          % Datapixx internal buffer address

% make sure an ADC schedule is not running
Datapixx('RegWrRd');
ADCstatus = Datapixx('GetAdcStatus');
while ADCstatus.scheduleRunning == 1;
    Datapixx('RegWrRd');
    ADCstatus = Datapixx('GetAdcStatus');
    WaitSecs(0.01);
end

% set the ADC schedule
Datapixx('SetAdcSchedule', 0, adcRate, t.nAdcLocalBuffSpls, [0 1 2 3], t.adcBuffBaseAddr, t.nAdcLocalBuffSpls);
Datapixx('StartAdcSchedule');
Datapixx('RegWrRd');

%%% Start DIN of spike data
t.DinRate             = 1000;                         % sampling rate
t.nDinLocalBuffFrms   = t.DinRate*maxDur;               % number of samples to preallocate for reading
t.DinBaseAddress      = 12e6;
t.DINdata             = zeros(1,t.nDinLocalBuffFrms);
t.DINtimes            = zeros(1,t.nDinLocalBuffFrms);


% make sure a DIN schedule is not running
Datapixx('RegWrRd');
t.DINstatus = Datapixx('GetDinStatus');
while t.DINstatus.logRunning == 1;
    Datapixx('StopDinLog');
    Datapixx('RegWrRd');
    t.DINstatus = Datapixx('GetDinStatus');
    WaitSecs(0.01);
end

Datapixx('SetDinLog', t.DinBaseAddress, t.nDinLocalBuffFrms);
Datapixx('StartDinLog');
Datapixx('RegWrRd');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%reward gets set here
%if length(c.fractalid1)==1
s.RewardTime = c.rewardDur;

%%% Set DAC schedule for reward system
Volt                        = 4.0;
pad                         = 0.01;  % pad 4 volts on either side with zeros
Wave_time                   = s.RewardTime+pad;
t.Dacrate                   = 1000;
reward_Voltages             = [zeros(1,round(t.Dacrate*pad/2)) Volt*ones(1,round(t.Dacrate*s.RewardTime)) zeros(1,round(t.Dacrate*pad/2))];
t.ndacsamples               = floor(t.Dacrate*Wave_time);
t.dacBuffAddr               = 6e6;
t.chnl                      = c.outcomechannel;

% make sure a Dac schedule is not running before setting a new schedule
Datapixx('RegWrRd');
Dacstatus = Datapixx('GetDacStatus');
while Dacstatus.scheduleRunning == 1;
    Datapixx('RegWrRd');
    Dacstatus = Datapixx('GetDacStatus');
end
Datapixx('RegWrRd');


if s.RewardTime>0
    Datapixx('RegWrRd');
    DacData=Volt*ones(1,round(t.Dacrate*s.RewardTime));
    DacData(length(DacData):1000)=0;
    Datapixx('WriteDacBuffer', DacData);
    Datapixx('RegWrRd');
end



% Initialize
t.state           = 0;                    %
t.backcolor       = c.backcolor;          % background color CLUT indx
t.fcolor          = c.backcolor;          % fixation pt CLUT indx, initially this should be BG colored.
t.fwcolor         = 3;                    % fixation window CLUT indx
t.tcolor          = c.backcolor;          % target pt CLUT indx, initially this should be BG colored.
t.twcolor         = 3;                    % target window CLUT indx
t.ecolor          = 3;                    % eye position CLUT indx
t.gridc           = 1;                    % grid CLUT indx
t.whitec          = 4;
t.grey1c          = 1;
t.grey2c          = 3;
t.cuecolor        = c.backcolor;

% initialize times
t.timeFPON        = -1;                   % time of fixation point onset
t.timeFPOFF       = -1;
t.timeFA          = -1;                   % time of fixation acquisition
t.timeTON         = -1;                   % time of target onset
t.timeFIXOFF      = -1;             % time of fixation offset
t.timeSACON       = -1;             % time of saccade onset (fixation window exit)
t.timeTA          = -1;             % time of target acquisition
t.timeTFC         = -1;             % time of target fixation completion
t.timeBF          = -1;             % time of broken fixation
t.timeBTF         = -1;             % time of broken TARGET fixation
t.timeRWD         = -1;             % time of reward delivery
t.timeTONE        = -1;             % time of reward-tone
t.rewarddot=-1;
c.outcomedel=NaN;
t.choicerefuse=0;
c.chosenwindow=0;
c.chosen=0;
t.windowchosen=0;
% t.timeTARGETON = NaN;
t.timeTARGETOFF=NaN;
t.timeFixationabort=0;
c.monkeynotinitiated=0;
t.monkeyenteredtargwin=NaN;
t.monkeyenteredtargwinFix=NaN;
c.loopCountOfTargetOn =NaN;
c.loopCountOfTargetOff =NaN;
t.timeOUTCOME=NaN;
t.timeTARGETON=NaN;
t.timeTARGETON1=NaN;
t.timeOUTCOME1=NaN;
t.timeOUTCOME=NaN;
c.outcomedel=NaN;
%t.trialover=NaN;
s.RewardTime=NaN;
t.timeOUTCOME=NaN;
c.outcomedel=NaN;
t.trialover=NaN;
t.time_return_final=NaN;
c.chosenwindow=NaN;
t.timeChoice=NaN;
s.RewardTime=0;
c.chosen=NaN;
s.rewardDelay_=NaN;
s.rewardDelay=NaN;
s.TimeofPunish=NaN;
t.timeTARGETON2=NaN;
c.pulseprogtime=NaN;
s.rewardDelay_=NaN;
s.rewardDelay=NaN;

c.short_delay_flag = 0;
c.long_delay_flag = 0;
t.short_reward_del_flag = 0;
t.long_reward_del_flag = 0;

t.magicNumber   = 0.008;            % define the "magic number" for stimulus-drawing
t.frametimestep = 1/c.framerate;    % IFI (inter-frame-interval = 1/frame-rate)
t.lastframetime = 0;                % time at which last frame was displayed
s.fixXY         = [c.fpX, c.fpY];   % Where will the fixation-point be shown?

% make grid with 2 degree (c.gridW) spacing
minmaxg     = 30;
grid_sp     = deg2pix(-minmaxg:2:minmaxg,c);  % -20 to 20 deg
t.GridXY      = [];
for i = 1:size(grid_sp,2)
    XY=[[-c.middleXY(1);grid_sp(i)] [c.middleXY(1);grid_sp(i)]];
    YX=[[grid_sp(i);-c.middleXY(2)] [grid_sp(i);c.middleXY(2)]];
    t.GridXY = [t.GridXY XY YX];
end

% for each stimulus event, we're going to strobe AFTER the flip, we'll use
% this variable to keep track of when we want to strobe and what we want to
% strobe:
t.strobeOnFlip.logic = false;
t.strobeOnFlip.value = 0;

% define the "magic number" for stimulus-drawing
t.magicNumber = 0.008;

% fixation-point (and surrounding window) in pixels.
t.PfixXY      = [sign(s.fixXY(1))*deg2pix(abs(s.fixXY(1)),c) -sign(s.fixXY(2))*deg2pix(abs(s.fixXY(2)),c)]; % fixation point xy
t.PtargXY     = [sign(s.targXY(1))*deg2pix(abs(s.targXY(1)),c) -sign(s.targXY(2))*deg2pix(abs(s.targXY(2)),c)]; % target point xy
%t.EscapeXY     = [sign(s.escapeXY(1))*deg2pix(abs(s.escapeXY(1)),c) -sign(s.escapeXY(2))*deg2pix(abs(s.escapeXY(2)),c)]; % escape point xy

ang=c.angs(1);
ang=c.AmpUse*[cosd(ang), sind(ang)];
t.ang1     = [sign(ang(1))*deg2pix(abs(ang(1)),c) -sign(ang(2))*deg2pix(abs(ang(2)),c)];

ang=c.angs(2);
ang=c.AmpUse*[cosd(ang), sind(ang)];
t.ang2     = [sign(ang(1))*deg2pix(abs(ang(1)),c) -sign(ang(2))*deg2pix(abs(ang(2)),c)];

clear ang

t.PfpWindW    =  deg2pix(c.fp1WindW,c); % fixation point window width
t.PfpWindH    =  deg2pix(c.fp1WindH,c); % fixation point window height
t.PtpWindW    =  deg2pix(c.tp1WindW,c); % target point window width
t.PtpWindH    =  deg2pix(c.tp1WindH,c); % target point window height

% possible trial-ending states
% endStates (state values that stop the trial)
t.endStates   = [   1.5, ...    % correct
    3, ...      % fixation-break prior to target onset
    3.1, ...    % fixation-break during overlap or too soon after fixation offset
    3.2, ...    % miss (didn't reach target in time)
    3.3, ...    % target fixation-break (didn't maintain target-fixation long enough)
    3.4]; ...   % non-start (never acquired fixation).
    

t.blinkThreshold = -4.8; % NML 03_05_2015
t.blinkTimeAllowed = 0.5; % NML 03_05_2015

%calculated in finish, store NaNs  now in case of try-catch loop triggers
%PDS.timeFocused(c.j)=NaN; % NML 03_27_2015
%PDS.acquisitionTime(c.j)=NaN; % NML 03_27_2015
%PDS.stableWindowByTrial{c.j}=NaN; % NML 03_27_2015
%PDS.meanPrestimulusDialation{c.j}=NaN; % NML 03_27_2015
%PDS.fixOverlap(c.j)=NaN; % NML 03_27_2015
c.sampleInTargetZonevector(1,1) =[false];
c.sampleInTargetZonevector(2,1) =[false];
c.blinkLogicalSamples(1) = [false];
end

function [PDS, c, s]        =   trial_end(PDS, c, s, t)

%%% Read continuously sampled Eye data
% Update registers for GetAdcStatus
Datapixx('RegWrRd');

% get VIEWPixx status.
status              = Datapixx('GetAdcStatus');

% How many samples available to read?
t.nReadSpls           = status.newBufferFrames;

% Read ADC buffer.
[t.LocalADCbuffer(1:4,1:t.nReadSpls), t.LocalADCbuffer(5,1:t.nReadSpls)]  = Datapixx('ReadAdcBuffer', t.nReadSpls, t.adcBuffBaseAddr);


%ilya' replacemnt
% t.LocalADCbuffer(1:5,1:t.nReadSpls) = zeros(5, t.nReadSpls);
% Why this replacement??
%TODO check this code?

% Stop ADC schedule.
Datapixx('StopAdcSchedule');
Datapixx('RegWrRd');

% Update registers for GetDinStatus
Datapixx('RegWrRd');

% get VIEWPixx ADC status.
t.DINstatus           = Datapixx('GetDinStatus');
Datapixx('RegWrRd');

% Read Data
[t.DINdata, t.DINtimes] = Datapixx('ReadDinLog', t.DINstatus.newLogFrames);
Datapixx('RegWrRd');

% Stop DIN schedule.
Datapixx('StopDinLog');
Datapixx('RegWrRd');


if c.repeatflag==0 %todo check this logic?
    good        = 1;
else
    good        = 0;
end

c.goodtrial     = c.goodtrial + good;
c.smallRewardCount     = c.smallRewardCount + c.small_reward_del_flag;
c.largeRewardCount     = c.largeRewardCount + c.large_reward_del_flag;
c.shortDelayCount     = c.shortDelayCount + c.short_delay_flag;
c.longDelayCount     = c.longDelayCount + c.long_delay_flag;



s.TrialNumber   = c.j;

%% OUTPUT behavioral data
if c.j~=0
    % Admin -------------------------------------------------------------
    PDS.trialnumber(c.j)       = c.j;                   % Trial number
    PDS.repeatflag(c.j)        = c.repeatflag;          % Repeat flag
    PDS.goodtrial(c.j) = good;                          % Good trial flag
    
    % Signals -----------------------------------------------------------
    PDS.EyeJoy{c.j}             = t.LocalADCbuffer;
    PDS.onlineEye{c.j}          = t.eyePos;
    PDS.onlineLickForce{c.j}    = t.lickSpoutForce;
    PDS.spikes{c.j}             = t.DINdata;
    PDS.sptimes{c.j}            = t.DINtimes - t.vpixxstart;
    
    % Stimuli information -----------------------------------------------
    PDS.targAngle1(c.j)         = c.angs(1);            % Target Angle (1)
    PDS.targAngle2(c.j)         = c.angs(2);            % Target Angle (2)
    PDS.targAmp(c.j)            = c.AmpUseAver;         % Target Amplitude (1 & 2)
    PDS.targFixDurReq(c.j)      = s.targFixDurReq;      % Required fixation time
    PDS.outcomeorder(c.j)       = c.rewardorpunishfirst;% Reward or Delay
    
    % Option related variables ------------------------------------------
    %   Option 1:
    
    PDS.offerInfo{1}.choice_rwdamount(c.j) = c.maxValrangeOf1R;
    PDS.offerInfo{1}.choice_rwdprob(c.j) = c.RewardRange1./c.maxValrangeOf1R;
    PDS.offerInfo{1}.choice_punishamount(c.j) = c.maxValrangeOf1P;
    PDS.offerInfo{1}.choice_punishprob(c.j) = c.PunishmentRange1/c.maxValrangeOf1P;
    PDS.offerInfo{1}.reveal_rwdprob(c.j) = c.Offer1Rew;
    PDS.offerInfo{1}.reveal_punishprob(c.j) = c.Offer1Pun;
    
    %   Option 2:
    PDS.offerInfo{2}.choice_rwdamount(c.j) = c.maxValrangeOf2R;
    PDS.offerInfo{2}.choice_rwdprob(c.j) = c.RewardRange2./c.maxValrangeOf2R;
    PDS.offerInfo{2}.choice_punishamount(c.j) = c.maxValrangeOf2P;
    PDS.offerInfo{2}.choice_punishprob(c.j) = c.PunishmentRange2/c.maxValrangeOf2P;
    PDS.offerInfo{2}.reveal_rwdprob(c.j) = c.Offer2Rew;
    PDS.offerInfo{2}.reveal_punishprob(c.j) = c.Offer2Pun;
    
    %   Selection:
    PDS.whichtoshowfirst(c.j) = c.whichtoshowfirst;     % First shown option (1 or 2)
    PDS.chosenwindow(c.j)     = c.chosenwindow;         % Selected option
    
    % Times ------------------------------------------------------------
    PDS.trialstarttime(c.j,:)   = t.trstart';            % Trial start
    PDS.datapixxtime(c.j)       = t.vpixxstart;         % Trial start in viewpixx time
    PDS.timefpon(c.j)           = t.timeFPON;           % Fixation on (joypress acquired)
    PDS.timetargeton(c.j)       = t.timeTARGETON;       % Option 1 Onset
    PDS.timetargeton2(c.j)      = t.timeTARGETON2;      % Option 2 Onset
    PDS.timeChoice(c.j)         = t.timeChoice;         % ?Time of choice *to check
    PDS.timereward(c.j)         = t.timeOUTCOME;        % Reward delivery time
    PDS.trialover(c.j)          = t.trialover;          % Trial finish time
    
    
    PDS.pulseprogtime(c.j)      = c.pulseprogtime;      % Laser duration
    PDS.iti_dur(c.j)            = c.ITI_dur;            % ITI duration
    %PDS.ts_dur(c.j)             = c.TS_dur;             % TS duration
    %PDS.cs_dur(c.j)             = c.rwd_delay;             % CS duration
    PDS.reveal_first_idx        = c.reveal_first_idx;   % Index of first revealed outcome
    
    % Conditional outcomes:
    %   Delay time
    try PDS.timepunish(c.j)= s.TimeofPunish;
    catch PDS.timepunish(c.j)= NaN;
    end
    
    %   Reward time
    try PDS.timereward(c.j)= s.RewardTime;
    catch PDS.timereward(c.j)= NaN;
    end
    
    %   Delay magnitude
    try PDS.magnitude_punish(c.j)= s.rewardDelay_;
    catch PDS.magnitude_punish(c.j)= NaN;
    end
    
    %   Delay magnitude
    try PDS.magnitude_reward(c.j)= s.RewardTimeDur;
    catch PDS.magnitude_reward(c.j)= NaN;
    end
    
    clear t;
end

end

function strobe(word)
Datapixx('SetDoutValues',fix(word),hex2dec('007fff'))    % set word in first 15 bits
Datapixx('RegWr');
Datapixx('SetDoutValues',2^16,hex2dec('010000'))   % set STRB to 1 (true)
Datapixx('RegWr');
Datapixx('SetDoutValues',0,hex2dec('017fff'))      % reset strobe and all 15 bits to 0.
Datapixx('RegWr');
end

%% Legacy code
% function [EyeX, EyeY, joy, eXd, eYd]  =   getEyeJoy(c)
% % update data-pixx registers
% Datapixx('RegWrRd')
% % read voltages
% V       = Datapixx('GetAdcVoltages');
% % Convert eye-voltages into screen-pixels.
% EyeX    = sign(V(4))*deg2pix(8*abs(V(4)),c);  % deg to pixx; sign change in X to account for camera inversion.
% EyeY    = sign(V(5))*deg2pix(8*abs(V(5)),c);
% % read joy-voltage
% joy     = V(6);
% eXd     = 8*V(4);
% eYd     = 8*V(5);
%
%
% end

% function  [lickSpoutInstantForce] = getLickForce(c)
%
% Datapixx('RegWrRd')
% % read voltages
% V       = Datapixx('GetAdcVoltages');
%
%
% lickSpoutInstantForce = V(8); % licking neaby door
% %     t.lickSpoutForce(t.wlCount, :)    = [lickSpoutInstantForce, GetSecs];
%
%
% end


%this strobe is the original that may have an error
% function strobe(word)
% Datapixx('SetDoutValues',fix(word),hex2dec('007fff'))    % set word in first 15 bits
% Datapixx('RegWr');
% Datapixx('SetDoutValues',2^16,hex2dec('010000'))   % set STRB to 1 (true)
% Datapixx('RegWr');
% Datapixx('SetDoutValues',0,hex2dec('017fff'))      % reset strobe and all 15 bits to 0.
% Datapixx('RegWr');
% end
%
% function out                =   checkJoy(pass, Joy, Th)
% % checkJoy checks if the joystick voltage is above th or below th depending
% % on the SIGN of JOY & TH. For example: if JOY & TH are both positive, the
% % function checks JOY > TH, but if JOY & TH are both negative, the function
% % checks JOY < TH. Meanwhile, the PASS-value controls whether the funciton
% % defaults to a true-state. If PASS is true, the funtion always returns
% % "true."
%
% out = Joy > Th || pass;
%
% end.

%
%
% function unpausePlexon
% Datapixx('SetDoutValues',2^17,2^17);
% Datapixx('RegWrRd');
% end
%
% function pausePlexon
% Datapixx('SetDoutValues',0,2^17);
% Datapixx('RegWrRd');
% end
%
%
% %this strobe is from fixate

%

function sendPlexonInfo(c, s, t)

% %start sending
% strobe(c.codes.startsendingtrialinfo);
%
% strobe(c.rewardorpunishfirst+11000);
% strobe(c.RewardRange1+12000);
% strobe(c.RewardRange2+13000);
% strobe(c.PunishmentRange1+12500);
% strobe(c.PunishmentRange2+13500);
% try
% strobe( c.rwd_delay(c.PunishmentRange1./2)+12700);
% catch
%   strobe( c.rwd_delay(c.PunishmentRange1)+12700);
% end
%
% try
% strobe( c.rwd_delay(c.PunishmentRange2./2)+13700);
% catch
%     strobe( c.rwd_delay(c.PunishmentRange2)+13700);
% end
% strobe(c.codes.endsendingtrialinfo);

end
