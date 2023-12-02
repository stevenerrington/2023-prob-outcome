function [PDS ,c ,s]= ProbRwdDelay_run(PDS ,c ,s)

%%% ////////////////////////////////////////////////////////////////////////////
% Experiment loop
%       The primary loop and state controller for the experiment
%%% ////////////////////////////////////////////////////////////////////////////

% Initialize trial-variables from the init function
[PDS, c, s, t]      = trial_init(PDS, c, s);

t.wlCount = 0;

while  ~any(t.state == t.endStates) && c.quit == 0
    % Iterate loop-count;
    t.wlCount = t.wlCount + 1;
    % Get analog voltages (joystick and gaze position)
    [s.EyeX, s.EyeY, t.joy, eyeXd, eyeYd] = getEyeJoy(c);
    [lickSpoutInstantForce] = getLickForce(c);
    

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
    if t.joy < t.blinkThreshold
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
    
    
    %%% ////////////////////////////////////////////////////////////////////////////
    % State switch
    %       This will progress through the experiment using state logic.
    %%% ////////////////////////////////////////////////////////////////////////////
    
    switch t.state
        
        % !STATE: Trial start -----------------------------------
        case 0
            if t.wlCount ==1
                strobe(c.codes.trialBegin);
                t.timeofabort=NaN;
                tstate_back=NaN;
                c.repeatflag =0;
                
            end
            if GetSecs >= t.trstart + 0.1
                t.state     = 0.1;
            end
            c.outcometrial=0;
            
            
            
            % !STATE: Fixspot on --------------------
        case 0.1
            c.repeatflag=0;
            tstate_back=0;
            t.state     = 0.2;
            t.fwcolor   = t.grey1c;
            t.fcolor    = 9;
            c.outcometrial=0;
            t.strobeOnFlip.logic = true;
            t.strobeOnFlip.value = c.codes.fixdoton;           
            delayvar = GetSecs;
            t.timefpon = GetSecs - t.trstart;
           
            fprintf('-------------------------- \n Trial %i \n', c.j)
            fprintf('Good trials: %i      \n', sum(c.goodtrial))
            % !SE: Can insert n_trials here after troubleshooting
            fprintf(' > Fix spot on \n')
            
            % !STATE: Fixation acquisition
        case 0.2
            % If eye is within the given window, then progress to next state
            if checkEye(c.passEye, t.PfixXY-[s.EyeX s.EyeY], [t.PfpWindW, t.PfpWindH])
                strobe(c.codes.fixacqd);
                t.timeFA = GetSecs - t.trstart;
                t.state = 0.3;
                
                % Otherwise, if time elapses, then end the trial
            elseif t.ttime > c.maxFixWait
                % monkey not fixated
                delayvar = GetSecs;
                t.state=1.2;
                c.repeatflag=1;
                t.timeNostart = GetSecs - t.trstart;
                temp=GetSecs;
                strobe(c.codes.nonstart);
                c.monkeynotinitiated=1;
            end
            
            % !STATE: Fixation attained
        case 0.3
            % If the eye is in the window, and the time is less than the required duration, keep going
            if t.ttime < (t.timeFA + c.minFixDur) && checkEye(c.passEye, t.PfixXY-[s.EyeX s.EyeY], [t.PfpWindW, t.PfpWindH])
                
                % If the monkey breaks the fixation out of the window, then end the trial
            elseif ~checkEye(c.passEye, t.PfixXY-[s.EyeX s.EyeY], [t.PfpWindW, t.PfpWindH])
                % Fixation broken!
                strobe(c.codes.fixbreak);
                c.repeatflag=1;
                delayvar = GetSecs;
                t.state=1.2;
                temp=GetSecs;
                t.timeFixBreak = GetSecs - t.trstart; % time broke joy fixation
                
                
                % If the monkey has maintained fixation long enough, go to the next state
            elseif t.ttime >= t.timeFPON + c.minFixDur
                t.state       = 0.4;
            end
            
            
            % !STATE: Present the first offer ---------------------
        case 0.4
            t.timeOffer1 = GetSecs - t.trstart;
            t.state =  0.5;
            tstate_back = 0.005;
            strobe(c.codes.fixdotoff);
            t.strobeOnFlip.logic = true;
            t.strobeOnFlip.value = c.codes.offer1on;
            c.loopCountOfTargetOn =t.wlCount;
            
            delayvar=GetSecs;
            fprintf(' > Choice 1 onset \n')
            
            
            % !STATE: Present the second offer ---------------------
        case 0.5
            if (GetSecs - delayvar) >= c.intraoffer_interval
                t.timeOffer2 = GetSecs - t.trstart;
                t.state =0.55;
                tstate_back = 0.006;
                delayvar=GetSecs;
                c.showfirst=1;
                t.strobeOnFlip.logic = true;
                t.strobeOnFlip.value = c.codes.offer2on;
                fprintf(' > Choice 2 onset \n')
            end
            
            % !STATE: Wait after a short period with both options on screen ---------------------
        case 0.55
            if (GetSecs - delayvar) >= c.offer_display_period
                t.state = 0.6;
                delayvar = GetSecs;
                tempback = delayvar;
                tempback1 = tempback;
            end
            
            % !STATE: Determine choice outcome --------------------
        case 0.6
            temp1=GetSecs;
            s.targFixDurReq=c.targFixDurReq;
            
            % Get the eye position to determine if the monkey is within an offer window
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
            
            % Impose choice deadline (choicemax)
            if GetSecs - tempback1 >= c.choicemax
                delayvar = GetSecs;
                t.state=1.2;
                c.repeatflag=1;
                t.timeNoChoice=GetSecs - t.trstart;
                temp=GetSecs;
                tstate_back=999999999;
                t.timeOUTCOME=NaN;
                fprintf(' > ! No choice selected ! \n')
                strobe(c.codes.choicerefuse);

            end
            
            % Find which option was selected -----------------------------------------------
            % If the monkey was in the window for long enough, determine
            % the choice
            if delayvar >= (tempback + s.targFixDurReq)
                % Option 1 (A) selected:
                if checkEye(c.passEye, t.ang1-[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH])
                    t.choice_selected = 1;
                    strobe(c.codes.offer1chosen);
                   
                    % Option 2 (B) selected:
                elseif delayvar >= (tempback + s.targFixDurReq) && checkEye(c.passEye, t.ang2-[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH])
                    t.choice_selected = 2;
                    strobe(c.codes.offer2chosen);
                end
                
                fprintf(' > Choice %i selected \n', t.choice_selected)
                c.chosenwindow = t.choice_selected; c.chosen = t.choice_selected;
                strobe(c.codes.choiceselected);
                
                t.timeChoice     = GetSecs - t.trstart;
                t.state                 = 0.7;
                delayvar = GetSecs;
                
                
                % Reward amount setup
                if c.(['ActualRewardOffer' int2str(t.choice_selected)]) == 1 % If prob is 100%
                    s.RewardTime = c.rewarddist(length(c.rewarddist)); % Large magnitude
                else
                    s.RewardTime = c.rewarddist(1); % Small magnitude
                end
                
                % Delay setup
                if c.(['ActualDelayOffer' int2str(t.choice_selected)]) == 1 % If prob is 100%
                    s.rewardDelay_ = c.rwd_delay(2); % Long delay
                else
                    s.rewardDelay_ = c.rwd_delay(1); % Short delay
                end
                
                c.delay_period = s.rewardDelay_;
                
                % OTHERWISE... if the monkey is out of either target window, then reset the timer.
            elseif ~checkEye(c.passEye, t.ang1-[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH]) &...
                    ~checkEye(c.passEye, t.ang2-[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH]);
                tempback =temp1; % reset target fixation time if monkey is ooking out of both windows
                c.setWindow=0;
                c.sampleInTargetZonevector(1,t.wlCount) = [false];
                c.sampleInTargetZonevector(2,t.wlCount) = [false];
                
            end
            
            delayvar = GetSecs;
            
            % !STATE: Show choice selection --------------------
        case 0.7
            if (GetSecs - delayvar) >= 0.0 % Immediately after choice is confirmed
                t.strobeOnFlip.logic = true;
                t.strobeOnFlip.value = c.codes.choicepresented;   
                tstate_back=0.0071;
                delayvar = GetSecs;
                t.state = 0.71;
            end
            
            % !STATE: Reveal/confirm delay duration
         case 0.71
            if (GetSecs - delayvar) >= c.choice_reveal_dur % Immediately after choice is confirmed
                t.timeDelayReveal     = GetSecs - t.trstart;
                t.strobeOnFlip.logic = true;
                t.strobeOnFlip.value = c.codes.timerreveal;   
                tstate_back=0.0081;
                delayvar = GetSecs;
                t.state = 0.8;
                tic
            end        
            
            % !STATE: Prepare to start timer
        case 0.8           
            if (GetSecs - delayvar) >= c.delayreveal_timer_dur
                t.timeTimerStart     = GetSecs - t.trstart;
                t.strobeOnFlip.logic = true;
                t.strobeOnFlip.value = c.codes.timerstart;                delayvar = GetSecs;
                timervar = GetSecs;
                tstate_back=0.0081;
              
                
                t.state = 0.9;
                fprintf([' > $ Delay reveal to delay epoch: ' num2str(toc) ' seconds\n'])
                tic
            end
            
            % !STATE: Run delay timer
        case 0.9
            % Work out the tick step
            c.tick_diff = ((GetSecs - timervar)*1000)*c.tick_step;
            tstate_back=0.0091;  
            
            % If the delay period has elapsed then progress to the next state
            if (GetSecs - delayvar) >= c.delay_period
                t.timeTimerEnd     = GetSecs - t.trstart;
                t.strobeOnFlip.logic = true;
                t.strobeOnFlip.value = c.codes.timerend;              
                delayvar = GetSecs;
                t.state = 0.99;
                fprintf([' > $ Delay reveal to reward reveal: ' num2str(toc) ' seconds\n'])
                tic
            end
            
         case 0.99
                if (GetSecs - delayvar) >= c.timer_rwdreveal_dur % Immediately after choice is confirmed
                    delayvar = GetSecs;
                    t.state = 1.0;
                end
                
            % !STATE: Reveal reward outcome
        case 1.0
            t.timeRewardReveal   = GetSecs - t.trstart;
            t.strobeOnFlip.logic = true;
            t.strobeOnFlip.value = c.codes.rwdreveal;     
            tstate_back=0.0101; 
            t.state = 1.1;
            delayvar = GetSecs;
            fprintf([' > $ Delay end to reward reveal: ' num2str(toc) ' seconds\n'])
            tic
            
            % !STATE: Deliver reward outcome
        case 1.1
            if (GetSecs - delayvar) >= c.rwdreveal_rwddel_dur
                fprintf([' > $ Reward reveal to delivery: ' num2str(toc) ' seconds\n'])
                tstate_back=0.0111; 

                % Make counters for delays
                c.short_reward_del_flag = 0;
                c.long_reward_del_flag = 0;
                
                % Send relevant pulses to deliver reward from solenoid
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
                t.timeReward     = GetSecs - t.trstart;
                delayvar=GetSecs;
                t.state = 1.11;
            end
            
        case 1.11
            if (GetSecs - delayvar) >= c.rwddel_iti_dur
                delayvar = GetSecs;
                tstate_back=  0.05;
                t.state = 1.2;
            end


        case 1.2
            fprintf('************* End of Trial ************* \n')
            fprintf('ITI: %i seconds... \n', c.ITI_dur)
            t.timeITIstart     = GetSecs - t.trstart;
            strobe(c.codes.itistart);               
            iti_start = GetSecs;
            tstate_back=  0.05;
            t.state = 1.21;
            
        case 1.21
            if (GetSecs - iti_start) >= 0
                t.timeITIreward = GetSecs - t.trstart;
                    t.state = 1.22;
                
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
                    strobe(c.codes.itirwd);
                    delayvar = GetSecs;
                    
                end
                
            end
            
        case 1.22
            if (GetSecs - iti_start) >= c.ITI_dur
                fprintf('End of ITI >>>>>>>>>>>>>>>>>>>>> \n')
                t.timeITIend = GetSecs - t.trstart;
               
                strobe(c.codes.itiend);
                strobe(c.codes.trialEnd);
                t.state = 1.5;
                t.trialover     = GetSecs - t.trstart;
            end
            
    end % // END OF STATE MACHINE
    
    % If state machine fails, try going back to the previous saved state
    try
        c.tstate_back = tstate_back ;
    end
    
    %%% ////////////////////////////////////////////////////////////////////////////
    % Screen draw states
    %      Define states that draw all relevant screens and options. Do all the drawing, first note what
    %  time it is so we can compute what frame we're in, relative to cue-onset (timeCON).
    %%% ////////////////////////////////////////////////////////////////////////////
    
    t.ttime       = GetSecs - t.trstart;
    
    if t.ttime > t.lastframetime + t.frametimestep - t.magicNumber
        
        % Fill the window with the background color.
        Screen('FillRect', c.window, convertColorToL48D(c.backcolor));
        
        % Draw the grid
        Screen('DrawLines', c.window, t.GridXY,[], convertColorToL48D( t.gridc), c.middleXY);
        % Draw the gaze position, MUST DRAW THE GAZE BEFORE THE
        % FIXATION. Otherwise, when the gaze indicator goes over any
        % stimuli it will change the occluded stimulus' color!
        
        Screen('FillRect', c.window, convertColorToL48D(t.ecolor), [s.EyeX s.EyeY s.EyeX s.EyeY] + [-1 -1 1 1] * c.EyePtR + repmat(c.middleXY,1,2));
        Datapixx('RegWrRd');
        
        % Screen draw logic: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % !Screen: Draw the fixation and or target point / window (if desired)
        if tstate_back==0
            disp_fixdot(c, t);
        end
        
        % !Screen: Draw the targets (offer 1)
        if tstate_back==0.005 || tstate_back==0.006
            t=disp_targ_offer1(c, t);
        end
        
        % !Screen: Draw the targets (offer 2)
        if tstate_back==0.006
            t=disp_targ_offer2(c, t);
        end
        
        % !Screen: Draw the chosen target (remove the unselected option)
        if tstate_back==0.0071
            t=disp_choice(c, t);
        end
        
        % !Screen: Draw the delay reveal
        if tstate_back==0.0081
            t=disp_delay_reveal(c, t); %!SE: SCREEN TBC
        end
        
        % !Screen: Draw the delay timer
        if tstate_back==0.0091
            t=disp_delay_timer(c, t); %!SE: SCREEN TBC
        end
        
        % !Screen: Draw the reward reveal
        if tstate_back==0.0101
            t=disp_reward_reveal(c, t); %!SE: SCREEN TBC
        end
        % !Screen: Draw the reward delivery
        if tstate_back==0.0111
            t=disp_reward_delivery(c, t); %!SE: SCREEN TBC
        end
        
        % !Screen: Draw a blank screen
        if tstate_back==0.05
            disp_blank_screen(c,t,s);
            tstate_back = 1;
        end
        
        % Screen draw timings: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Flip (note thef time relative to trial-start).
        t.lastframetime1= Screen('Flip', c.window, GetSecs + 0.00) ;
        t.lastframetime =   t.lastframetime1- t.trstart;
%         
%         if t.strobeOnFlip.value==c.codes.targetoff && t.strobeOnFlip.logic ==1
%             t.timeTARGETOFF   = t.lastframetime;
%         end
%         
%         if t.strobeOnFlip.value==c.codes.targeton && t.strobeOnFlip.logic ==1
%             t.timeTARGETON     = t.lastframetime;
%         end
%         
%         if t.strobeOnFlip.value==c.codes.feedon && t.strobeOnFlip.logic ==1
%             t.FEEDback     = t.lastframetime;
%         end
%         
%         if t.strobeOnFlip.value==c.codes.fixdoton && t.strobeOnFlip.logic ==1
%             t.timeFPON     = t.lastframetime;
%         end
%         
%         if c.showfirst==1 && t.strobeOnFlip.logic ==1
%             t.timeTARGETON2      = t.lastframetime;
%         end
%         
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END OF TRIAL LOOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% ////////////////////////////////////////////////////////////////////////////
% Helper functions
%%% ////////////////////////////////////////////////////////////////////////////
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
V       = Datapixx('GetAdcVoltages'); % read voltages
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



function sendPlexonInfo(c, s, t)
% LEGACY FUNCTION
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ////////////////////////////////////////////////////////////////////////////
% Screen draws
%       Draw all relevant screens and options. Do all the drawing, first note what
%  time it is so we can compute what frame we're in, relative to cue-onset (timeCON).
%%% ////////////////////////////////////////////////////////////////////////////

% Add a frame around the fixation dot
function disp_fixdot(c, t)
cursorR           = 9;
Screen('FrameRect',c.window, convertColorToL48D(t.fcolor),repmat(t.PfixXY + c.middleXY,1,2) + [-cursorR -cursorR cursorR cursorR],c.fixdotW)
Screen('FrameRect',c.window, convertColorToL48D(t.fwcolor),repmat(t.PfixXY + c.middleXY,1,2) + [-t.PfpWindW -t.PfpWindH t.PfpWindW t.PfpWindH],c.fixwinW)
end

% Make targets in relevant locations/with relevant stimuli
function t = disp_targ_offer1(c, t)

c.middleXYt=c.middleXY; c.middleXYt(2)=c.middleXYt(2)+60;
c.middleXYt1=c.middleXY; c.middleXYt1(2)=c.middleXYt(2)-100;

c.middleXYtt=c.middleXYt; c.middleXYtt(1)=c.middleXYtt(1)+70;
colors=9;

switch c.first_offer_idx
    case 1
        ang=t.ang1;
        DelayMagnitude=c.delay_mag_offer1;
        RwdMagnitude=c.rew_mag_offer1;
    case 2
        ang=t.ang2;
        DelayMagnitude=c.delay_mag_offer2;
        RwdMagnitude=c.rew_mag_offer2;
end

if DelayMagnitude == 0; DelayMagnitude = c.short_delay_cuesize;...
elseif DelayMagnitude == 5; DelayMagnitude = 5.00;...
elseif DelayMagnitude == 10; DelayMagnitude = c.long_delay_cuesize;...
end

if RwdMagnitude == 0; RwdMagnitude = c.small_reward_cuesize;...
elseif RwdMagnitude == 5; RwdMagnitude = 5.00;...
elseif RwdMagnitude == 10; RwdMagnitude = c.large_reward_cuesize;...
end

PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(DelayMagnitude,c); % target point window height
Screen('FillRect',c.window, convertColorToL48D(colors),repmat(ang  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)
n=c.maxValrange;
PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(n,c); % target point window height
Screen('FrameRect',c.window, convertColorToL48D(colors),repmat(ang  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)
colors=10;

PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(RwdMagnitude,c); % target point window height
Screen('FillRect',c.window, convertColorToL48D(colors),repmat(ang  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)

n=c.maxValrange;
PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(n,c); % target point window height
Screen('FrameRect',c.window, convertColorToL48D(colors),repmat(ang  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)

t.PtpWindW    =  deg2pix(6,c); % target point window width
t.PtpWindH    =  deg2pix(8,c); % target point window height
Screen('FrameRect',c.window, convertColorToL48D(t.fwcolor),repmat(ang  + c.middleXYt1,1,2) + [-t.PtpWindW -t.PtpWindH t.PtpWindW t.PtpWindH],c.fixwinW)


end

function t = disp_targ_offer2(c, t)
c.middleXYt=c.middleXY; c.middleXYt(2)=c.middleXYt(2)+60;
c.middleXYt1=c.middleXY; c.middleXYt1(2)=c.middleXYt(2)-100;

c.middleXYtt=c.middleXYt; c.middleXYtt(1)=c.middleXYtt(1)+70;
colors=9;

switch c.first_offer_idx
    case 1
        ang=t.ang2;
        DelayMagnitude=c.delay_mag_offer2;
        RwdMagnitude=c.rew_mag_offer2;
    case 2
        ang=t.ang1;
        DelayMagnitude=c.delay_mag_offer1;
        RwdMagnitude=c.rew_mag_offer1;        
end

switch DelayMagnitude
    case 0; DelayMagnitude = c.short_delay_cuesize;
    case 5; DelayMagnitude = 5;
    case 10; DelayMagnitude = c.long_delay_cuesize;
end

switch RwdMagnitude
    case 0; RwdMagnitude = c.small_reward_cuesize;
    case 5; RwdMagnitude = 5;
    case 10; RwdMagnitude = c.large_reward_cuesize;
end


PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(DelayMagnitude,c); % target point window height
Screen('FillRect',c.window, convertColorToL48D(colors),repmat(ang  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)
n=c.maxValrange;
PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(n,c); % target point window height
Screen('FrameRect',c.window, convertColorToL48D(colors),repmat(ang  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)

colors=10;
PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(RwdMagnitude,c); % target point window height
Screen('FillRect',c.window, convertColorToL48D(colors),repmat(ang  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)

n=c.maxValrange;
PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(n,c); % target point window height
Screen('FrameRect',c.window, convertColorToL48D(colors),repmat(ang  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)

t.PtpWindW    =  deg2pix(6,c); % target point window width
t.PtpWindH    =  deg2pix(8,c); % target point window height
Screen('FrameRect',c.window, convertColorToL48D(t.fwcolor),repmat(ang  + c.middleXYt1,1,2) + [-t.PtpWindW -t.PtpWindH t.PtpWindW t.PtpWindH],c.fixwinW)

end


function t = disp_choice(c, t)
c.middleXYt=c.middleXY; c.middleXYt(2)=c.middleXYt(2)+60;
c.middleXYt1=c.middleXY; c.middleXYt1(2)=c.middleXYt(2)-100;
c.AmpUse=11;

targ_angle_in = t.(['ang' int2str(c.chosen)]);
reward_range = c.(['rew_mag_offer' int2str(c.chosen)]);
delay_range = c.(['delay_mag_offer' int2str(c.chosen)]);
max_val_range_rwd = c.maxValrange;

% Determine where the reward bar should be shown
if reward_range == 0; RwdMagnitude = c.small_reward_cuesize;
elseif reward_range == 5; RwdMagnitude = 5.00;
elseif reward_range == 10; RwdMagnitude = c.large_reward_cuesize;
end

switch delay_range
    case 0; DelayMagnitude = c.short_delay_cuesize;
    case 5; DelayMagnitude = 5;
    case 10; DelayMagnitude = c.long_delay_cuesize;
end


% Reward attribute ----------------------
colors = 10;
PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(RwdMagnitude,c); % target point window height
Screen('FillRect',c.window, convertColorToL48D(colors),repmat(targ_angle_in  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)

n = max_val_range_rwd;
PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(n,c); % target point window height
Screen('FrameRect',c.window, convertColorToL48D(colors),repmat(targ_angle_in  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)

% Delay attribute ----------------------
colors = 9;
PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(DelayMagnitude,c); % target point window height
c.middleXYtt=c.middleXYt; c.middleXYtt(1)=c.middleXYtt(1)+70;
Screen('FillRect',c.window, convertColorToL48D(colors),repmat(targ_angle_in  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)

n = c.maxValrange;
PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(n,c); % target point window height
Screen('FrameRect',c.window, convertColorToL48D(colors),repmat(targ_angle_in  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)


end


function t = disp_delay_reveal(c, t)
c.middleXYt=c.middleXY; c.middleXYt(2)=c.middleXYt(2)+60;
c.middleXYt1=c.middleXY; c.middleXYt1(2)=c.middleXYt(2)-100;
c.AmpUse=11;

targ_angle_in = t.(['ang' int2str(c.chosen)]);
reward_range = c.(['rew_mag_offer' int2str(c.chosen)]);
delay_range = c.(['delay_mag_offer' int2str(c.chosen)]);
delay_outcome = c.(['ActualDelayOffer' int2str(c.chosen)]);
max_val_range_rwd = c.maxValrange;

% Determine where the timer bar should start
if delay_range*delay_outcome == 0
    c.timer_start = c.short_delay_cuesize; c.short_delay_flag = 1; c.long_delay_flag = 0;
else
    c.timer_start = c.long_delay_cuesize; c.short_delay_flag = 0; c.long_delay_flag = 1;
end

% Determine where the reward bar should be shown
if reward_range == 0; RwdMagnitude = c.small_reward_cuesize;
elseif reward_range == 5; RwdMagnitude = 5.00;
elseif reward_range == 10; RwdMagnitude = c.large_reward_cuesize;
end


% Reward attribute ----------------------
colors = 10;
PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(RwdMagnitude,c); % target point window height
Screen('FillRect',c.window, convertColorToL48D(colors),repmat(targ_angle_in  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)

n = max_val_range_rwd;
PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(n,c); % target point window height
Screen('FrameRect',c.window, convertColorToL48D(colors),repmat(targ_angle_in  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)

% Delay attribute ----------------------
colors = 9;
PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(c.timer_start,c); % target point window height
c.middleXYtt=c.middleXYt; c.middleXYtt(1)=c.middleXYtt(1)+70;
Screen('FillRect',c.window, convertColorToL48D(colors),repmat(targ_angle_in  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)

n = c.maxValrange;
PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(n,c); % target point window height
Screen('FrameRect',c.window, c.delay_reveal_color,repmat(targ_angle_in  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)


end

function t = disp_delay_timer(c, t)

c.middleXYt=c.middleXY; c.middleXYt(2)=c.middleXYt(2)+60;
c.middleXYt1=c.middleXY; c.middleXYt1(2)=c.middleXYt(2)-100;
c.AmpUse=11;

targ_angle_in = t.(['ang' int2str(c.chosen)]);
reward_range = c.(['rew_mag_offer' int2str(c.chosen)]);
delay_range = c.(['delay_mag_offer' int2str(c.chosen)]);
delay_outcome = c.(['ActualDelayOffer' int2str(c.chosen)]);
max_val_range_rwd = c.maxValrange;

% Determine where the timer bar should start
if delay_range*delay_outcome == 0
    c.timer_start = c.short_delay_cuesize; c.short_delay_flag = 1; c.long_delay_flag = 0;
else
    c.timer_start = c.long_delay_cuesize; c.short_delay_flag = 0; c.long_delay_flag = 1;
end

% Determine where the reward bar should be shown
if reward_range == 0; RwdMagnitude = c.small_reward_cuesize;
elseif reward_range == 5; RwdMagnitude = 5.00;
elseif reward_range == 10; RwdMagnitude = c.large_reward_cuesize;
end


% Reward ----------------------
colors=10;
PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(RwdMagnitude,c); % target point window height
Screen('FillRect',c.window, convertColorToL48D(colors),repmat(targ_angle_in  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)

n=max_val_range_rwd;
PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(n,c); % target point window height
Screen('FrameRect',c.window, convertColorToL48D(colors),repmat(targ_angle_in  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)


% Delay ----------------------
colors=9;
timer_height = c.timer_start-c.tick_diff;

if timer_height < 0; timer_height = 0; end

PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(timer_height,c); % target point window height

c.middleXYtt=c.middleXYt; c.middleXYtt(1)=c.middleXYtt(1)+70;
Screen('FillRect',c.window, c.delay_reveal_color,repmat(targ_angle_in  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)

n=c.maxValrange;
PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(n,c); % target point window height
Screen('FrameRect',c.window, c.delay_reveal_color,repmat(targ_angle_in  + c.middleXYtt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)

end

function t = disp_reward_reveal(c, t)
c.middleXYt=c.middleXY; c.middleXYt(2)=c.middleXYt(2)+60;
c.middleXYt1=c.middleXY; c.middleXYt1(2)=c.middleXYt(2)-100;
c.AmpUse=11;

targ_angle_in = t.(['ang' int2str(c.chosen)]);
offer_rwd = c.(['ActualRewardOffer' int2str(c.chosen)]);
max_val_range_rwd = c.maxValrange;

if offer_rwd == 0; c.RwdMagnitude_outcome = c.small_reward_cuesize;
else c.RwdMagnitude_outcome = c.large_reward_cuesize;
end

% Reward ----------------------
colors=10;
PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(c.RwdMagnitude_outcome,c); % target point window height
Screen('FillRect',c.window, c.rwd_reveal_color,repmat(targ_angle_in  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],1)

n=max_val_range_rwd;
PtpWindW    =  deg2pix(1,c); % target point window width
PtpWindH    =  deg2pix(n,c); % target point window height
Screen('FrameRect',c.window, c.rwd_reveal_color,repmat(targ_angle_in  + c.middleXYt,1,2) + [-PtpWindW -PtpWindH PtpWindW PtpWindH*0],5)

end

function t = disp_reward_delivery(c, t)
end

% Create a blank screen
function disp_blank_screen(c, t, s)
Screen('FillRect', c.window, convertColorToL48D(c.backcolor));
Screen('DrawLines', c.window, t.GridXY,[], convertColorToL48D( t.gridc), c.middleXY);
end


function [PDS, c, s, t]     =   trial_init(PDS, c, s)

% start of trial time
t.trstart = GetSecs;
Datapixx('RegWrRd');
t.vpixxstart = Datapixx('GetTime');

%%% Start ADC of Eyelink (x,y,pupil) and joystick data; 4 channels
maxDur              = 16;                     % how many seconds of data do we want to read?
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


%%% ////////////////////////////////////////////////////////////////////////////
% Initialize varibles
%       Create variables to store times, events, etc...
%%% ////////////////////////////////////////////////////////////////////////////

% Color ------------------------------------
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

% Times ------------------------------------
t.timeFPON        = -1;             % time of fixation point onset
t.timeFA          = -1;             % time of fixation acquisition
t.timeNostart          = -1;        % time of fixation acquisition
t.timeOffer1      = -1;
t.timeOffer2      = -1;
t.timeChoice      = -1;
t.timeDelayReveal = -1;
t.timeTimerStart = -1;
t.timeTimerEnd = -1;
t.timeRewardReveal = -1;
t.timeReward = -1;
t.timeITIstart = -1;
t.timeITIreward = -1;
t.timeITIend = -1;
t.timeFixBreak = -1;
t.timeNoChoice = -1;
t.timeTARGETOFF=NaN;
t.timeFixationabort=0;
c.monkeynotinitiated=0;
t.monkeyenteredtargwin=NaN;
t.monkeyenteredtargwinFix=NaN;


% Loop variables ------------------------------------
s.RewardTime=NaN;
s.rewardDelay_=NaN;
s.rewardDelay=NaN;
s.Timeofdelay=NaN;

c.loopCountOfTargetOn =NaN;
c.loopCountOfTargetOff =NaN;
c.pulseprogtime=NaN;
c.chosen=NaN;
c.chosenwindow=NaN;
c.outcomedel=NaN;
c.outcomedel=NaN;
c.monkeynotinitiated=NaN;
c.outcomedel=NaN;
c.timer_start = NaN;


% Plexon/Vpixx/Datapixx initial variables
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
s.targXY                = [0 0];
t.PfixXY      = [sign(s.fixXY(1))*deg2pix(abs(s.fixXY(1)),c) -sign(s.fixXY(2))*deg2pix(abs(s.fixXY(2)),c)]; % fixation point xy
t.PtargXY     = [sign(s.targXY(1))*deg2pix(abs(s.targXY(1)),c) -sign(s.targXY(2))*deg2pix(abs(s.targXY(2)),c)]; % target point xy

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
    

t.blinkThreshold = -4.8;
t.blinkTimeAllowed = 0.5;

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
% c.smallRewardCount     = c.smallRewardCount + c.small_reward_del_flag;
% c.largeRewardCount     = c.largeRewardCount + c.large_reward_del_flag;
% c.shortDelayCount     = c.shortDelayCount + c.short_delay_flag;
% c.longDelayCount     = c.longDelayCount + c.long_delay_flag;

s.TrialNumber   = c.j;

%%% ////////////////////////////////////////////////////////////////////////////
% Output trial-based behavioral data and times
%       Generated a super-structure (PDS) that holds all the behavioral information
%       from the task.
%%% ////////////////////////////////////////////////////////////////////////////

if c.j~=0
    % Admin -------------------------------------------------------------
    PDS.trialnumber(c.j)       = c.j;                   % Trial number
    PDS.repeatflag(c.j)        = c.repeatflag;          % Repeat flag
    PDS.goodtrial(c.j)         = good;                  % Good trial flag
    
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
    
    % Misc parameters -----------------------------------------------
    PDS.iti_dur(c.j)            = c.ITI_dur;            % ITI duration


    % Option related variables ------------------------------------------
    %   Option 1:
    PDS.offerInfo{1}.choice_rwd(c.j) = c.rew_mag_offer1;
    PDS.offerInfo{1}.choice_delay(c.j) = c.delay_mag_offer1;
    %   Option 2:
    PDS.offerInfo{2}.choice_rwd(c.j) = c.rew_mag_offer2;
    PDS.offerInfo{2}.choice_delay(c.j) = c.delay_mag_offer2;
    
    % Outcome
    PDS.rwdOutcomeInfo(c.j) = c.RwdMagnitude_outcome;
    PDS.delayOutcomeInfo(c.j) = c.timer_start;
    
    PDS.offer_settings.max_range(c.j) = c.maxValrange;
    PDS.offer_settings.offer1_delay(c.j) = c.ActualDelayOffer1;
    PDS.offer_settings.offer1_rwd(c.j) = c.ActualRewardOffer1;
    PDS.offer_settings.offer2_delay(c.j) = c.ActualDelayOffer2;
    PDS.offer_settings.offer2_rwd(c.j) = c.ActualRewardOffer2;
    
    %   Selection:
    PDS.first_offer_idx(c.j) = c.first_offer_idx;     % First shown option (1 or 2)
    PDS.chosenwindow(c.j)     = c.chosenwindow;         % Selected option
    
    % Times ------------------------------------------------------------
    PDS.trialstarttime(c.j,:)   = t.trstart';           % Trial start
    PDS.datapixxtime(c.j)       = t.vpixxstart;         % Trial start in viewpixx time
    PDS.timefpon(c.j)           = t.timeFPON;           % YES: Fixation on
    PDS.timefa(c.j)             = t.timeFA;             % YES: Fixation achieved
    PDS.timeNostart(c.j)        = t.timeNostart;        % YES: No fixation
    PDS.timeFixBreak(c.j)       = t.timeFixBreak;       % YES: Time of fix break
    PDS.timeOffer1(c.j)         = t.timeOffer1;         % YES: Offer 1 Onset
    PDS.timeOffer2(c.j)         = t.timeOffer2;         % YES: Offer 2 Onset
    PDS.timeChoice(c.j)         = t.timeChoice;         % YES: Time of choice confirmation
    PDS.timeDelayReveal(c.j)    = t.timeDelayReveal;    % YES: Time of choice confirmation
    PDS.timeTimerStart(c.j)     = t.timeTimerStart;     % YES: Time of choice confirmation
    PDS.timeTimerEnd(c.j)       = t.timeTimerEnd;       % YES: Time of choice confirmation
    PDS.timeRewardReveal(c.j)   = t.timeRewardReveal;   % YES: Time of choice confirmation
    PDS.timeReward(c.j)         = t.timeReward;         % YES: Time of choice confirmation
    PDS.timeITIstart(c.j)       = t.timeITIstart;         % Time of choice confirmation
    PDS.timeITIreward(c.j)      = t.timeITIreward;         % Time of choice confirmation
    PDS.timeITIend(c.j)         = t.timeITIend;         % Time of choice confirmation
    PDS.timeNoChoice(c.j)       = t.timeNoChoice;         % Time of choice confirmation
    PDS.trialover(c.j)          = t.trialover;          % Trial finish time
    
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
