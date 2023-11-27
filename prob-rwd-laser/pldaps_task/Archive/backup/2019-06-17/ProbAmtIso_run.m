function [PDS ,c ,s]= ProbAmtIso_run(PDS ,c ,s)

s.fixDur  =0.5;





% trial-variables and hardware initialization
[PDS, c, s, t]      = trial_init(PDS, c, s);
t.wlCount = 0;





%%%%% Runtrial While-Loop           %%%%%
while  ~any(t.state == t.endStates) && c.quit == 0
    
    % iterate loop-count;
    t.wlCount = t.wlCount + 1;
    %NML 2015-03-29 do we need this?
    
    
    % get analog voltages (joystick and gaze position)
    [s.EyeX, s.EyeY, t.joy, eyeXd, eyeYd] = getEyeJoy(c);
    
    
    %eyeXd and eyeYd are for velocity calculation and can eventually be
    %removed
    %ilya's add to show random eye positions
    %  s.EyeX=rand*50;
    %  s.EyeY=330;
    
    %     % eye position storge (for velocity computation)
    t.eyePos(t.wlCount, :)    = [eyeXd, eyeYd, t.joy, GetSecs];
    
    
    [lickSpoutInstantForce] = getLickForce(c);
    
    t.lickSpoutForce(t.wlCount, :)    = [lickSpoutInstantForce, GetSecs];
    
    
    c.sampleInTargetZonevector(1,t.wlCount) =[false];% seed ongoing logical arrays with zeros
    c.sampleInTargetZonevector(2,t.wlCount) =[false];
    
    c.blinkLogicalSamples(t.wlCount) =[false];
    
    %     c.samplesInChoiceWindow1(t.wlCount) = 0;
    %     c.samplesInChoiceWindow2(t.wlCount) = 0;
    
    t.ttime = GetSecs - t.trstart;
    t.timeVect(t.wlCount) = t.ttime;
    
    %     Put blink check here?
    %NML=======================================================
    % blink checking goes here
    %t.joy
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
    %NML=======================================================
    
    switch t.state
        
        case 0
            
            if t.wlCount ==1
                unpausePlexon;
                strobe(c.codes.trialBegin);
                t.timeofabort=NaN;
                tstate_back=NaN;
                c.repeatflag =0;
            end
            if GetSecs >= t.trstart+ 1
                t.state     = 0.00001;
            end
            
            
        case 0.00001
            c.repeatflag=0;
            tstate_back=0;
            t.state     = 0.0001;
            t.fwcolor   = t.grey1c;
            
        
           % if c.fixreq == 1
                t.fcolor    = 9;
           % else
            %    t.fcolor = 9;
           % end
            
            t.strobeOnFlip.logic = true;
            t.strobeOnFlip.value = c.codes.fixdoton;
            delayvar = GetSecs;
            t.timeofabort=NaN;
            
        case 0.0001
            if GetSecs>=delayvar+1
            t.state=0.0055;
            end
            
            
%             if checkEye(c.passEye, t.PfixXY-[s.EyeX s.EyeY], [t.PfpWindW, t.PfpWindH]) %if fixates go on
%                 strobe(c.codes.fixacqd);
%                 t.timeFA = GetSecs - t.trstart;
%                 t.state = 0.25;
%             elseif t.ttime > c.maxFixWait %if not fixate, abort
%                 t.state = 1.26;
%                 c.repeatflag=1;
%                 temp=GetSecs;
%                 strobe(c.codes.nonstart);
%                 c.monkeynotinitiated=1;
%             end
            
        case 0.25
            if t.ttime < (t.timeFA + s.fixDur) && checkEye(c.passEye, t.PfixXY-[s.EyeX s.EyeY], [t.PfpWindW, t.PfpWindH])
                
            elseif ~checkEye(c.passEye, t.PfixXY-[s.EyeX s.EyeY], [t.PfpWindW, t.PfpWindH])
                strobe(c.codes.fixbreak);
                c.repeatflag=1;
                t.state                 = 1.26;
                temp=GetSecs;
                t.timeBF                = GetSecs - t.trstart; % time broke joy fixation
                
                
            elseif t.ttime >= t.timeFPON + s.fixDur
                t.state       = 0.0055;
            end
            
        case 0.0055 %show target
           
%             if c.fixreq == 1
%                 tstate_back=0.0055;
%                 t.strobeOnFlip.logic = true;
%                 t.strobeOnFlip.value = c.codes.targeton;
%                 c.loopCountOfTargetOn =t.wlCount;
%                 PDS.fixOverlap(c.j) = c.fixOverlap;
                
           %     t.state=0.00555;
           %     delayvar = GetSecs;
           %     tempback=delayvar;
           %     tempback1=tempback;
           %     t.overlapStart = GetSecs;
                
          %  elseif c.fixreq == 2
                t.state = 0.0505;
                delayvar = GetSecs;
                tstate_back = 0.005;
                t.strobeOnFlip.logic = true;
                t.strobeOnFlip.value = c.codes.targeton;
                c.loopCountOfTargetOn =t.wlCount;
          %  end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%fixrew 1 trials
        case 0.00555
            if    checkEye(c.passEye, t.PfixXY-[s.EyeX s.EyeY], [t.PfpWindW, t.PfpWindH]) && ...
                    t.ttime <= t.timeFPON + s.fixDur + PDS.fixOverlap(c.j)
            elseif ~checkEye(c.passEye, t.PfixXY-[s.EyeX s.EyeY], [t.PfpWindW, t.PfpWindH])
                % Fixation broken during overlap!
                strobe(c.codes.fixbreak);
                c.repeatflag=1;
                t.state                 = 1.26;
                c.ITI_dur=2;
                temp=GetSecs;
                t.timeBF                = GetSecs - t.trstart; % time broke joy fixation
            elseif t.ttime >= ((t.overlapStart - t.trstart ) + PDS.fixOverlap(c.j))
                %FIXATION TIME with overlap OVER enter free looking
                disp(['t.overlapStart:' num2str( (t.overlapStart - t.trstart ) +  PDS.fixOverlap(c.j)) ...
                    ' t.ttime: ' num2str(t.ttime)]);
                t.state       = 0.0065;
                c.setWindow =0;
                c.repeatflag=0;
                tstate_back = 0.005;
                t.strobeOnFlip.logic = true;
                t.strobeOnFlip.value = c.codes.fixdotoff;
            end
            
        case 0.0065
            temp1=GetSecs;
            if checkEye(c.passEye,t.PtargXY -[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH]) && isnan(t.monkeyenteredtargwin)
                t.monkeyenteredtargwin =GetSecs;
                c.sampleInTargetZonevector(1,t.wlCount) =[true];
                
            elseif checkEye(c.passEye,t.PtargXY -[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH]) &&  ...
                    (GetSecs - t.monkeyenteredtargwin) > c.targetAcquisitionRequired ...
                    && isnan(t.monkeyenteredtargwinFix)
                c.sampleInTargetZonevector(1,t.wlCount) =[true];
                t.monkeyenteredtargwinFix=GetSecs - c.targetAcquisitionRequired;
                strobe(c.codes.monkeyenteredtargwin );
                
                tstate_back=0.00557;
                t.strobeOnFlip.value=c.codes.feedon ;
                t.strobeOnFlip.logic =1;
                
            elseif ~checkEye(c.passEye,t.PtargXY -[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH])
                t.monkeyenteredtargwin=NaN;
                c.sampleInTargetZonevector(1,t.wlCount) =[true];
            elseif checkEye(c.passEye,t.PtargXY -[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH])
                c.sampleInTargetZonevector(1,t.wlCount) =[false];
            end
            if (GetSecs - delayvar) >= 3;
                t.state =1.25;
            elseif GetSecs - tempback1 >= c.choicemax;
                t.state=1.26;
                t.timeofabort=GetSecs - t.trstart;
                temp=GetSecs;
                t.timeOUTCOME=NaN;
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%fixrew 1 trials  END
            
            
            %%%%%%%%%%%%%%%% no fix trials
        case 0.0505
            
            temp1=GetSecs;
            if checkEye(c.passEye,t.PtargXY -[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH]) && isnan(t.monkeyenteredtargwin)
                t.monkeyenteredtargwin =GetSecs;
                c.sampleInTargetZonevector(1,t.wlCount) =[true];
            elseif ~checkEye(c.passEye,t.PtargXY -[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH]) %&& ~isnan(t.monkeyenteredtargwin)
                t.monkeyenteredtargwin=NaN;
                c.sampleInTargetZonevector(1,t.wlCount) =[true];
            elseif checkEye(c.passEye,t.PtargXY -[s.EyeX s.EyeY], [t.PtpWindW, t.PtpWindH])
                c.sampleInTargetZonevector(1,t.wlCount) =[false];
            end
            
            if (GetSecs - delayvar) >= 1;
                t.state =0.0606;
            end
            
        case 0.0606 % ESBM note: this is "cue on" state?
            tstate_back=0.00557;
            t.strobeOnFlip.value=c.codes.feedon ;
            t.strobeOnFlip.logic =1;
            t.state = 0.06061;
            tempty = GetSecs;
            
        case 0.06061
            if (GetSecs - tempty) >= 1.5
                t.state = 0.060699
            end
            
        case 0.060699 % ESBM note: this is "target off" state?
            tstate_back=0.005575;
            t.strobeOnFlip.value=c.codes.targetoff ;
            t.strobeOnFlip.logic =1;
            t.state = 0.0606999;
            tempty = GetSecs;     
            
        case 0.0606999
            if (GetSecs - tempty) >= 0.75
                t.state = 1.25
            end

        
        case 1.25 % ESBM note: this is "outcome delivery (or non-delivery)" state?
        
        if s.RewardTime>0
            Volt                        = 4.0;
            pad                         = 0.00;  % removed at Ilya's instruction ...
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
%             %Datapixx('SetDacSchedule', t.chnl, [1000,1], 1000); % 1000 times per second, and our demo has 1000 frames.
             Datapixx('SetDacSchedule', 0, [1000,1], 1000, t.chnl);
             Datapixx('StartDacSchedule');
             Datapixx('RegWrRd');
             if c.outcomechannel==0
             strobe(c.codes.reward);
             elseif c.outcomechannel==2
                 strobe(c.codes.airpuff);
             end
             c.outcomedel=1;
             
             % ESBM TEST
             if t.chnl == 2
                 disp(['delivered airpuff on channel ' num2str(t.chnl)]);
             end
     
        else
            strobe(c.codes.noreward);
            c.outcomedel=0;
        end
        
        tstate_back=0.0055559;

        t.timeOUTCOME     = GetSecs - t.trstart
        t.state=999;
        temp=GetSecs;
        
        singleriskydouble=randi(3);
        rewardpunishmentneutral=randi(3);
        durationbetween=1.25;
        if randi(6)==1
            freeoutcomeoccurs=1;
        else
            freeoutcomeoccurs=0;
        end
        delnotdel=randi(2);
        
%         case 1.26
%             % Fixation broken, abort trial
%             tstate_back=0.0055559;
%             t.strobeOnFlip.logic = true;
%             t.strobeOnFlip.value = c.codes.abortatfixation;
%             temp=GetSecs;
%             t.state=999;
%             
%             
%             freq          = 10000;                % Sampling rate. samples/second
%             rightFreq     = 150;                  % A low-frequency tone to signal "WRONG"
%             nTF=            round(0.2*10*1000); % The tone-duration. %100ms = 0.1
%             lrMode        = 0;                    % Mono sound on both channels.
%             wrongbuffadd  = 0;                    % Start-address of the first sound's buffer.
%             risefallProp                    = 1/4;                              % proportion of sound for rise/fall
%             plateauProp                     = 1-2*risefallProp;                 % proportion of sound for plateau
%             mu1                             = round(risefallProp*nTF);        % Gaussian mean expressed in samples
%             sigma1                          = round(nTF/12);                  % Gaussian SD in samples, effectively the rate of rise/fall.
%             tempWindow                      = [normpdf(1:mu1,mu1,sigma1),...                                % RISE
%                 ones(1,round(plateauProp*nTF))*normpdf(mu1,mu1,sigma1),...    % PLATEAU (scaled to meet the rise/fall)
%                 fliplr(normpdf(1:mu1,mu1,sigma1))];                             % FALL
%             tempWindow                      = tempWindow - min(tempWindow);
%             tempWindow                      = tempWindow/max(tempWindow);
%             
%             righttone     = tempWindow.*sin((1:nTF)*2*pi*rightFreq/freq);
%             righttone     = righttone/max(abs(righttone));
%             rightbuffadd = Datapixx('WriteAudioBuffer', righttone, 0);
%             Datapixx('RegWrRd');
%             Datapixx('SetAudioVolume', 0.25);       % Not too loud
%             Datapixx('RegWrRd');
%             Datapixx('WriteAudioBuffer', righttone, rightbuffadd);
%             Datapixx('SetAudioSchedule', 0, freq, nTF, lrMode, rightbuffadd, nTF);
%             Datapixx('StartAudioSchedule');
%             Datapixx('RegWrRd');
%             t.timeOUTCOME     = NaN;
%             temp=GetSecs;
            

        case 999
            %%%
          
            
            
%             if GetSecs>=temp+1 & freeoutcomeoccurs==1;
%                 if singleriskydouble==1 %single
%                     if rewardpunishmentneutral==1
%                         [t.time_return_final(1),endtime1]=FreeOutcomesHelper(c.freeoutcometype,0.17, c, t, s,0); %0.15
%                     elseif rewardpunishmentneutral==2
%                         [t.time_return_final(1),endtime1]=FreeOutcomesHelper(c.freeoutcometype,0.17, c, t, s,0); %0.15
%                     elseif rewardpunishmentneutral==3
%                         [t.time_return_final(1),endtime1]=FreeOutcomesHelper(c.freeoutcometype,0.17, c, t, s,0); %0.15
%                     end
%                 elseif singleriskydouble==2 %risky
%                     if delnotdel==1 & rewardpunishmentneutral==1
%                         [t.time_return_final(1),endtime1]=FreeOutcomesHelper(c.freeoutcometype,0.17, c, t, s,0); %0.15
%                     elseif delnotdel==2 & rewardpunishmentneutral==1
%                         [t.time_return_final(1),endtime1]=FreeOutcomesHelper(c.freeoutcometype,0.17, c, t, s,0); %0.15
%                     end
%                 elseif singleriskydouble==3
%                     
%                 end
%             end
%             
            
            
            
            if GetSecs>=temp+3;
                t.state =1.5;
                t.trialover     = GetSecs - t.trstart;
                strobe(c.codes.trialEnd);
                clear temp temp1;
            end
            
            
            
                
end



% Do all the drawing, first note what time it is so we can compute what
% frame we're in, relative to cue-onset (timeCON).
t.ttime       = GetSecs - t.trstart;

if t.ttime > t.lastframetime + t.frametimestep - t.magicNumber
    
    % Fill the window with the background color.
    Screen('FillRect', c.window, convertColorToL48D(c.backcolor));
    
    % Draw the grid
    Screen('DrawLines', c.window, t.GridXY,[], convertColorToL48D( t.gridc), c.middleXY);
    %DrawFormattedText(c.window, 'PUT TRIAL INFO HERE', 'center', 40, convertColorToL48D(t.gridc));
    Datapixx('RegWrRd');
    % Draw the gaze position, MUST DRAW THE GAZE BEFORE THE
    % FIXATION. Otherwise, when the gaze indicator goes over any
    % stimuli it will change the occluded stimulus' color!
    Screen('FillRect', c.window, convertColorToL48D(t.ecolor), [s.EyeX s.EyeY s.EyeX s.EyeY] + [-1 -1 1 1]*c.EyePtR + repmat(c.middleXY,1,2));
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
    
    if tstate_back==0.00557
        t=maketargetsInfo(c, t);
    end
    
    if tstate_back==0.005575
        t=Infoonly(c, t);
    end
    
    
    
    if tstate_back==0.0055559
        makescreenblank(c,t,s);
        tstate_back = 1;
    end
    
    % Flip (note thef time relative to trial-start).
    %         t.lastframetime = Screen('Flip', c.window, GetSecs + 0.00) - t.trstart;
    t.lastframetime1= Screen('Flip', c.window, GetSecs + 0.00) ;
    t.lastframetime =   t.lastframetime1- t.trstart;
    
    
%     if t.strobeOnFlip.value==c.codes.targeton && t.strobeOnFlip.logic ==1
%         t.timeTARGETON     = t.lastframetime;
%     end
% %     
%     if t.strobeOnFlip.value==c.codes.targetoff && t.strobeOnFlip.logic ==1
%         t.timeTARGETOFF     = t.lastframetime;
%     end
%     

    
        if t.strobeOnFlip.value==c.codes.targetoff && t.strobeOnFlip.logic ==1
        t.timeTARGETOFF   = t.lastframetime;
    end
    
    if t.strobeOnFlip.value==c.codes.targeton && t.strobeOnFlip.logic ==1
        t.timeTARGETON     = t.lastframetime;
    end
    
    if t.strobeOnFlip.value==c.codes.feedon && t.strobeOnFlip.logic ==1
        t.FEEDback     = t.lastframetime;
    end
    
    if t.strobeOnFlip.value==c.codes.fixdoton && t.strobeOnFlip.logic ==1
        t.timeFPON     = t.lastframetime;
    end
    
    if t.strobeOnFlip.value==c.codes.fixdotoff && t.strobeOnFlip.logic ==1
        t.timeFPOFF     = t.lastframetime;
    end
    
    if t.strobeOnFlip.value==c.codes.abortatfixation && t.strobeOnFlip.logic ==1
        t.timeFixationabort     = t.lastframetime;
    end
    
    
    
    
    % if this flip was a stimulus onset event, we want to tell plexon
    if t.strobeOnFlip.logic
        strobe(t.strobeOnFlip.value);
        t.strobeOnFlip.logic = false;
    end
    
end
end


Screen('Flip', c.window);
%%%%% Runtrial While-Loop (end)     %%%%%
sendPlexonInfo(c, s, t);
pausePlexon;
% finalize stuff & store data to be saved.
[PDS, c, s]         = trial_end(PDS, c, s, t);

end         % end of run function

%% Helper functions.


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



function  [lickSpoutInstantForce] = getLickForce(c);

Datapixx('RegWrRd')
% read voltages
V       = Datapixx('GetAdcVoltages');

lickSpoutInstantForce = V(4);

%     t.lickSpoutForce(t.wlCount, :)    = [lickSpoutInstantForce, GetSecs];


end

function out                =   checkJoy(pass, Joy, Th)
% checkJoy checks if the joystick voltage is above th or below th depending
% on the SIGN of JOY & TH. For example: if JOY & TH are both positive, the
% function checks JOY > TH, but if JOY & TH are both negative, the function
% checks JOY < TH. Meanwhile, the PASS-value controls whether the funciton
% defaults to a true-state. If PASS is true, the funtion always returns
% "true."

out = Joy > Th || pass;

end

function out                =   checkEye(pass, Eye, WinDim)
% checkEye

out = all(abs(Eye)<WinDim) || pass;

end

function pixels             =   deg2pix(degrees,c) % PPD pixels/degree
% deg2pix convert degrees of visual angle into pixels
pixels = round(tand(degrees)*c.viewdist*c.screenhpix/c.screenh);

end

function                        fixdotframe(c, t)
cursorR           = 9;
Screen('FrameRect',c.window, convertColorToL48D(t.fcolor),repmat(t.PfixXY + c.middleXY,1,2) + [-cursorR -cursorR cursorR cursorR],c.fixdotW)
Screen('FrameRect',c.window, convertColorToL48D(t.fwcolor),repmat(t.PfixXY + c.middleXY,1,2) + [-t.PfpWindW -t.PfpWindH t.PfpWindW t.PfpWindH],c.fixwinW)
end


function t=                       maketargetsFIXOVERLAP(c, t)
n = c.infocuesize; % a scaling factor just so we can blow it up real big to make sure things look good.

if isempty(c.im2)==1
    t.img1 = Screen('MakeTexture', c.window, c.im1);
    Screen('DrawTexture', c.window, t.img1, [], repmat(t.PtargXY + c.middleXY,1,2) + n*[-30 -30 29 29], [], 0);
    Screen('FrameRect',c.window, convertColorToL48D(t.fwcolor),repmat(t.PtargXY  + c.middleXY,1,2) + [-t.PtpWindW -t.PtpWindH t.PtpWindW t.PtpWindH],c.fixwinW)
    
    
else
    
    t.img1=c.im1;
    t.img1 = Screen('MakeTexture', c.window, t.img1);
    Screen('DrawTexture', c.window, t.img1, [], repmat(t.ang1 + c.middleXY,1,2) + n*[-30 -30 29 29], [], 0);
    Screen('FrameRect',c.window, convertColorToL48D(t.fwcolor),repmat(t.ang1  + c.middleXY,1,2) + [-t.PtpWindW -t.PtpWindH t.PtpWindW t.PtpWindH],c.fixwinW)
    
    
    
    t.img2=c.im2;
    t.img2 = Screen('MakeTexture', c.window, t.img2);
    Screen('DrawTexture', c.window, t.img2, [], repmat(t.ang2 + c.middleXY,1,2) + n*[-30 -30 29 29], [], 0);
    Screen('FrameRect',c.window, convertColorToL48D(t.fwcolor),repmat(t.ang2  + c.middleXY,1,2) + [-t.PtpWindW -t.PtpWindH t.PtpWindW t.PtpWindH],c.fixwinW)
    
end
fixdotframe(c, t);   %Should enable fixdot again...
end


function t=                       maketargetsInfo(c, t)

n=c.fracsize;
if isempty(c.im2)==1
    t.img1 = Screen('MakeTexture', c.window, c.im1);
    Screen('DrawTexture', c.window, t.img1, [], repmat(t.PtargXY + c.middleXY,1,2) + n*[-30 -30 29 29], [], 0);
    Screen('FrameRect',c.window, convertColorToL48D(t.fwcolor),repmat(t.PtargXY  + c.middleXY,1,2) + [-t.PtpWindW -t.PtpWindH t.PtpWindW t.PtpWindH],c.fixwinW)
    
    
else
    
    t.img1=c.im1;
    t.img1 = Screen('MakeTexture', c.window, t.img1);
    Screen('DrawTexture', c.window, t.img1, [], repmat(t.ang1 + c.middleXY,1,2) + n*[-30 -30 29 29], [], 0);
    Screen('FrameRect',c.window, convertColorToL48D(t.fwcolor),repmat(t.ang1  + c.middleXY,1,2) + [-t.PtpWindW -t.PtpWindH t.PtpWindW t.PtpWindH],c.fixwinW)
    
    
    
    t.img2=c.im2;
    t.img2 = Screen('MakeTexture', c.window, t.img2);
    Screen('DrawTexture', c.window, t.img2, [], repmat(t.ang2 + c.middleXY,1,2) + n*[-30 -30 29 29], [], 0);
    Screen('FrameRect',c.window, convertColorToL48D(t.fwcolor),repmat(t.ang2  + c.middleXY,1,2) + [-t.PtpWindW -t.PtpWindH t.PtpWindW t.PtpWindH],c.fixwinW)
    
end
%info cue
n = c.infocuesize;
t.img1 = Screen('MakeTexture', c.window, c.im3);
Screen('DrawTexture', c.window, t.img1, [], repmat(t.PtargXY + c.middleXY,1,2) + n*[-30 -30 29 29], [], 0);
Screen('FrameRect',c.window, convertColorToL48D(t.fwcolor),repmat(t.PtargXY  + c.middleXY,1,2) + [-t.PtpWindW -t.PtpWindH t.PtpWindW t.PtpWindH],c.fixwinW)
%info context (CS)
end



function t=                       maketargets(c, t)
n = c.fracsize; % a scaling factor just so we can blow it up real big to make sure things look good.

if isempty(c.im2)==1
    t.img1 = Screen('MakeTexture', c.window, c.im1);
    Screen('DrawTexture', c.window, t.img1, [], repmat(t.PtargXY + c.middleXY,1,2) + n*[-30 -30 29 29], [], 0);
    Screen('FrameRect',c.window, convertColorToL48D(t.fwcolor),repmat(t.PtargXY  + c.middleXY,1,2) + [-t.PtpWindW -t.PtpWindH t.PtpWindW t.PtpWindH],c.fixwinW)
    
    
else
    
    t.img1=c.im1;
    t.img1 = Screen('MakeTexture', c.window, t.img1);
    Screen('DrawTexture', c.window, t.img1, [], repmat(t.ang1 + c.middleXY,1,2) + n*[-30 -30 29 29], [], 0);
    Screen('FrameRect',c.window, convertColorToL48D(t.fwcolor),repmat(t.ang1  + c.middleXY,1,2) + [-t.PtpWindW -t.PtpWindH t.PtpWindW t.PtpWindH],c.fixwinW)
    
    
    
    t.img2=c.im2;
    t.img2 = Screen('MakeTexture', c.window, t.img2);
    Screen('DrawTexture', c.window, t.img2, [], repmat(t.ang2 + c.middleXY,1,2) + n*[-30 -30 29 29], [], 0);
    Screen('FrameRect',c.window, convertColorToL48D(t.fwcolor),repmat(t.ang2  + c.middleXY,1,2) + [-t.PtpWindW -t.PtpWindH t.PtpWindW t.PtpWindH],c.fixwinW)
    
end

n = c.infocuesize;

Screen('FillRect',c.window, convertColorToL48D(2), repmat(t.PtargXY + c.middleXY,1,2) + n*[-30 -30 29 29],c.fixwinW)


end

function t=                       Infoonly(c, t)

n=c.fracsize;
%info cue
n = c.infocuesize;
t.img1 = Screen('MakeTexture', c.window, c.im3);
Screen('DrawTexture', c.window, t.img1, [], repmat(t.PtargXY + c.middleXY,1,2) + n*[-30 -30 29 29], [], 0);
Screen('FrameRect',c.window, convertColorToL48D(t.fwcolor),repmat(t.PtargXY  + c.middleXY,1,2) + [-t.PtpWindW -t.PtpWindH t.PtpWindW t.PtpWindH],c.fixwinW)
%info context (CS)
end



function makescreenblank(c, t, s)
Screen('FillRect', c.window, convertColorToL48D(c.backcolor));
Screen('DrawLines', c.window, t.GridXY,[], convertColorToL48D( t.gridc), c.middleXY);
Screen('FillRect', c.window, convertColorToL48D(t.ecolor), [s.EyeX s.EyeY s.EyeX s.EyeY] + [-1 -1 1 1]*c.EyePtR + repmat(c.middleXY,1,2));
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
t.ecolor          = 7;                    % eye position CLUT indx
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


c.outcomedel=NaN;
t.choicerefuse=0;
c.chosenwindow=0;
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

t.timeOUTCOME=NaN;
c.outcomedel=NaN;
%t.trialover=NaN;
t.time_return_final=NaN;




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


s.TrialNumber   = c.j;
%% OUTPUT behavioral data
if c.j~=0
    PDS.trialnumber(c.j)        = c.j;
    PDS.fractals(c.j)=c.fractalid(1);


      PDS.fracsize(c.j)          = c.fracsize;
        PDS.infocuesize(c.j)          = c.infocuesize;
      
    PDS.targAngle(c.j)          = c.targAngle;
    PDS.targAmp(c.j)            = 10; %c.targAmp;
    PDS.goodtrial(c.j) = good;
    
    PDS.outcomedel(c.j) =  c.outcomedel;
    
    
    try
     PDS.feedbackID(c.j) = c.feedid;
    catch
        PDS.feedbackID(c.j) = NaN;
    end
     
     
    PDS.trialover(c.j)=t.trialover;
    
    PDS.datapixxtime(c.j)       = t.vpixxstart;     % trial start in viewpixx time
    PDS.trialstarttime(c.j,:)   = t.trstart;        % trial start
    PDS.timefpon(c.j)           = t.timeFPON;       % fixation on (joypress acquired)
    PDS.timefpoff(c.j)          = t.timeFPOFF;
    PDS.timetargeton(c.j)           = t.timeTARGETON;
    PDS.timetargetoff(c.j)           = t.timeTARGETOFF;
    
    
    PDS.timeoutcome(c.j)         = t.timeOUTCOME;        % reward delivered

    try
        PDS.FEEDbacktime(c.j)             = t.FEEDback;
    catch
        PDS.FEEDbacktime(c.j)             = -1;
    end
    
    PDS.outcomechanel(c.j)=c.outcomechannel;
    
    
    PDS.EyeJoy{c.j}             = t.LocalADCbuffer;
    
    PDS.onlineEye{c.j}          = t.eyePos;
    PDS.onlineLickForce{c.j}    = t.lickSpoutForce;
    
    PDS.spikes{c.j}             = t.DINdata;
    PDS.sptimes{c.j}            = t.DINtimes - t.vpixxstart;
    PDS.rewardduration(c.j) = c.rewardDur;
    
    
    clear t;
end

end

%this strobe is the original that may have an error
% function strobe(word)
% Datapixx('SetDoutValues',fix(word),hex2dec('007fff'))    % set word in first 15 bits
% Datapixx('RegWr');
% Datapixx('SetDoutValues',2^16,hex2dec('010000'))   % set STRB to 1 (true)
% Datapixx('RegWr');
% Datapixx('SetDoutValues',0,hex2dec('017fff'))      % reset strobe and all 15 bits to 0.
% Datapixx('RegWr');
% end


function unpausePlexon
Datapixx('SetDoutValues',2^17,2^17);
Datapixx('RegWrRd');
end

function pausePlexon
Datapixx('SetDoutValues',0,2^17);
Datapixx('RegWrRd');
end


%this strobe is from fixate
function strobe(word)
Datapixx('SetDoutValues',fix(word),hex2dec('007fff'))    % set word in first 15 bits
Datapixx('RegWr');
Datapixx('SetDoutValues',2^16,hex2dec('010000'))   % set STRB to 1 (true)
Datapixx('RegWr');
Datapixx('SetDoutValues',0,hex2dec('017fff'))      % reset strobe and all 15 bits to 0.
Datapixx('RegWr');
end


function sendPlexonInfo(c, s, t)

%start sending
strobe(c.codes.startsendingtrialinfo);

%send target information
for b=1:length(c.fractalid)
    strobe(c.fractalid(b));
end

for b=1:length(c.targAngle)
    strobe(c.targAngle(b)+11500);
end

%added by ESBM 2019-06-14
% send feedback cue information
% since some feedback ID #s overlap with the event codes used for
% outcome deliveries (e.g. reward, no reward, etc.), we need to add
% a fixed offset to get numbers that will be unique at least in
% this ApetAversiveINFONEW task.
for b=1:length(c.feedid)
    strobe(c.feedid(b) + c.codes.feedid_to_strobe_code_offset);
end

% %escape cue
% tryold
%     strobe(c.angles_escapecue(b)+11000);
% end
% %free looking array
% try
%     for b=1:length(c.setforfreelook)
%         strobe(c.setforfreelook(b)+13000);
%     end
%     for b=1:length(c.codes.possibleanglesfreelook)
%         strobe(c.codes.possibleanglesfreelook(b)+12000);
%     end
% end
%end sending
strobe(c.codes.endsendingtrialinfo);

end



function [c, PDS]               = plotwindowsetup(c, PDS)

% Create plotting windows
if isempty(findobj('Name','OnlinePlotWindow'))
    c.onplotwin         = figure('Position', [20 90 1600 1250],...
        'Name','OnlinePlotWindow',...
        'NumberTitle','off',...
        'Color',[0.8 0.8 0.8],...
        'Visible','on',...
        'NextPlot','add');
else
    c.onplotwin         = findobj('Name','OnlinePlotWindow');
    set(0, 'CurrentFigure', c.onplotwin);
end

% make a cell-array of x-axis text-labels and colors for plotting.
myColors                = [0 1 0; 1 0 0; 0 0 1];
myLabels                = {'Hit','Fixation-Break','Non-Start'};

% x-data for plotting
c.stateBreak            = [1.5 3 3.3];
c.X                     = [1 2 3];
Nx                      = length(c.X);

% create axis and plot handles for over-all performance
c.ax1 = subplot(211);
[c.fo, c.po]            = mybarerr(c.X, NaN(Nx,1), NaN(Nx,2), [], myColors);

% create axis and plot-handles for cumulative sums
c.ax2 = subplot(212);
c.cumpo                 = plot(NaN(2,Nx),NaN(2,Nx),'LineWidth',1.5);

set(c.cumpo(1),'Color', [0 1 0])
set(c.cumpo(2),'Color', [1 0 0])
set(c.cumpo(3),'Color', [0 0 1])

xlabel('Trial-Number','FontSize',18,'FontWeight','bold')

% set axis properties.
set(c.ax1,...
    'YGrid', 'on',...
    'YColor', [0.2 0.2 0.2],...
    'XGrid', 'on',...
    'XColor', [0.2 0.2 0.2],...
    'Color', [1 1 1],...
    'YLim', [0 1],...
    'XLim', [min(c.X)-1, max(c.X)+1],...
    'TickDir', 'out',...
    'TickLength',[0.005 0.001],...
    'LineWidth', 1.5,...
    'FontSize', 16,...
    'XTick', c.X,...
    'XTickLabel', myLabels);
set(c.ax2,...
    'YGrid', 'on',...
    'YColor', [0.2 0.2 0.2],...
    'XGrid', 'on',...
    'XColor', [0.2 0.2 0.2],...
    'Color', [1 1 1],...
    'TickDir', 'out',...
    'TickLength',[0.005 0.001],...
    'LineWidth', 1.5,...
    'FontSize', 16);


% read current axis position and adjust
ax1Pos = get(c.ax1,'Position');
ax2Pos = get(c.ax2,'Position');
set(c.ax1,'Position',[0.035 0.53 0.95 0.425])
set(c.ax2,'Position',[0.035 0.0425 0.95 0.45])

% create labels for various conditions.
vertPos     = 0.97;
annotPos    = [0.12 0.275 0.415 0.57 0.7225 0.8625];

% Show the online plot window.
set(c.onplotwin,'Visible','on');
end
