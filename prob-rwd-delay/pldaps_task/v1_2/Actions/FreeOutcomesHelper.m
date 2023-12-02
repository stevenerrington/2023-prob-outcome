function [time_return_final, endtime] = FreeOutcomes(typeoffreeoutcome,freeouthowlong, c, t, s, howmanytimes,lrMode, left)

%note that lrMode and left will be listened to only in "typeoffreeoutcome
%35".... lrMode should be set to 0 for mono, 1 for left speaker, 2 for
%right speaker. so make left and lrMode empty if not 35.

%now we can make left flash with left sound
%left flash with right sound
%right flash with left sound
% right flash with right sound

%i suggest not overwriting the outcomehelper in trace.. just put this into
%reward prob amount procedure. lets have free reward (single reward) and
%single flash of light with sound... one of those events every 5 ITIs
%(approximately).. we also need make new event codes so we know which is
%which (strobe them and send them to PDS)

%typeoffreeoutcome
%1 reward
%2 punishment
%3 sound
%4 flash
%  5 vibration


%elaybetweenstims=0;
% codes.freereward=9006;
% codes.freeairpuff=9006;
% codes.freesound=9007;
% codes.freeflash=9008;
% codes.freevibration=9009;

for zrepeat=1:1%howmanytimes;

if typeoffreeoutcome==1 |  typeoffreeoutcome==9021%reward
    s.RewardTime=freeouthowlong;
    Volt                        = 4.0;
    pad                         = 0; %0.01;  % pad 4 volts on either side with zeros
    Wave_time                   = s.RewardTime+pad;
    t.Dacrate                   = 1000;
    reward_Voltages             = [zeros(1,round(t.Dacrate*pad/2)) Volt*ones(1,round(t.Dacrate*s.RewardTime)) zeros(1,round(t.Dacrate*pad/2))];
    t.ndacsamples               = floor(t.Dacrate*Wave_time);
    t.dacBuffAddr               = 6e6;
    t.chnl                      = 0;
    Datapixx('RegWrRd');
    DacData=Volt*ones(1,round(t.Dacrate*s.RewardTime));
    DacData(length(DacData):1000)=0;
    Datapixx('WriteDacBuffer', DacData);
    Datapixx('RegWrRd');
    Datapixx('SetDacSchedule', t.chnl, [1000,1], 1000); % 1000 times per second, and our demo has 1000 frames.
    Datapixx('StartDacSchedule');
    Datapixx('RegWrRd');
    strobe(c.codes.freereward);
    strobe(typeoffreeoutcome);
    time_return=GetSecs - t.trstart;
elseif typeoffreeoutcome==2 %punishment
    s.RewardTime=freeouthowlong;
    Volt                        = 4.0;
    pad                         = 0; %0.01;  % pad 4 volts on either side with zeros
    Wave_time                   = s.RewardTime+pad;
    t.Dacrate                   = 1000;
    reward_Voltages             = [zeros(1,round(t.Dacrate*pad/2)) Volt*ones(1,round(t.Dacrate*s.RewardTime)) zeros(1,round(t.Dacrate*pad/2))];
    t.ndacsamples               = floor(t.Dacrate*Wave_time);
    t.dacBuffAddr               = 6e6;
    t.chnl                      = 1;
    Datapixx('RegWrRd');
    DacData=Volt*ones(1,round(t.Dacrate*s.RewardTime));
    DacData(length(DacData):1000)=1;
    Datapixx('WriteDacBuffer', DacData);
    Datapixx('RegWrRd');
    Datapixx('SetDacSchedule', 0, [1000,1], 1000, t.chnl); % 1000 times per second, and our demo has 1000 frames.
    Datapixx('StartDacSchedule');
    Datapixx('RegWrRd');
    strobe(c.codes.freeairpuff);
    strobe(typeoffreeoutcome);
    time_return=GetSecs - t.trstart;
elseif typeoffreeoutcome==3 %sound
    freq          = 10000;                % Sampling rate. samples/second
    rightFreq     = 300;                  % A low-frequency tone to signal "WRONG"
    wrongFreq     = 150;                  % A high-frequency tone to signal "RIGHT"
    nTF=            round(freeouthowlong*10*1000); % The tone-duration.
    lrMode        = 0;                    % Mono sound on both channels.
    wrongbuffadd  = 0;                    % Start-address of the first sound's buffer.
    risefallProp                    = 1/4;                              % proportion of sound for rise/fall
    plateauProp                     = 1-2*risefallProp;                 % proportion of sound for plateau
    mu1                             = round(risefallProp*nTF);        % Gaussian mean expressed in samples
    sigma1                          = round(nTF/12);                  % Gaussian SD in samples, effectively the rate of rise/fall.
    tempWindow                      = [normpdf(1:mu1,mu1,sigma1),...                                % RISE
        ones(1,round(plateauProp*nTF))*normpdf(mu1,mu1,sigma1),...    % PLATEAU (scaled to meet the rise/fall)
        fliplr(normpdf(1:mu1,mu1,sigma1))];                             % FALL
    % Additively scale the window to ensure that it starts and ends at zero.
    tempWindow                      = tempWindow - min(tempWindow);
    % Multiplicatively scale the window to put the plateau at one.
    tempWindow                      = tempWindow/max(tempWindow);
    % Make the two sounds, one at 150hz ("righttone"), one at 300hz ("wrongtone").
    wrongtone     = tempWindow.*sin((1:nTF)*2*pi*wrongFreq/freq);
    righttone     = tempWindow.*sin((1:nTF)*2*pi*rightFreq/freq);
    noisetone     = tempWindow.*((rand(1,nTF)-0.5)*2);
    % Normalize the windowed sounds (keep them between -1 and 1.
    wrongtone     = wrongtone/max(abs(wrongtone));
    righttone     = righttone/max(abs(righttone));
    noisetone     = noisetone/max(abs(noisetone));
    
    noisebuffadd = Datapixx('WriteAudioBuffer', noisetone, 0);
    Datapixx('RegWrRd');
    Datapixx('SetAudioVolume', 0.25);       % Not too loud
    Datapixx('RegWrRd');
    Datapixx('WriteAudioBuffer', noisetone, noisebuffadd);
    %Datapixx('WriteAudioBuffer', wrongtone, noisebuffadd);
    Datapixx('SetAudioSchedule', 0, freq, nTF, lrMode, noisebuffadd, nTF);
    Datapixx('StartAudioSchedule');
    Datapixx('RegWrRd');
    time_return=GetSecs - t.trstart;
    strobe(c.codes.freesound);
    strobe(typeoffreeoutcome);
    
elseif typeoffreeoutcome==4 %flash
    Screen('FillRect', c.window, convertColorToL48D(9));
    Screen('DrawLines', c.window, t.GridXY,[], convertColorToL48D( t.gridc), c.middleXY);
    Screen('FillRect', c.window, convertColorToL48D(t.ecolor), [s.EyeX s.EyeY s.EyeX s.EyeY] + [-1 -1 1 1]*c.EyePtR + repmat(c.middleXY,1,2));
    strobe(c.codes.freeflash);
    time_return1 = Screen('Flip', c.window, GetSecs + 0.00);
    time_return= time_return1 -t.trstart;
    
%     temp=1
%     while temp==1
%         if GetSecs >=time_return1+freeouthowlong;
%             Screen('FillRect', c.window, convertColorToL48D(2));
%             Screen('DrawLines', c.window, t.GridXY,[], convertColorToL48D( t.gridc), c.middleXY);
%           %  Screen('FillRect', c.window, convertColorToL48D(t.ecolor), [s.EyeX s.EyeY s.EyeX s.EyeY] + [-1 -1 1 1]*c.EyePtR + repmat(c.middleXY,1,2));
%             Screen('Flip', c.window, GetSecs + 0.00);
%             temp=2;
%         end
%     end
    
elseif typeoffreeoutcome==5 %vibration
    s.RewardTime=freeouthowlong;
    Volt                        = 4.0;
    pad                         = 0; %0.01;  % pad 4 volts on either side with zeros
    Wave_time                   = s.RewardTime+pad;
    t.Dacrate                   = 1000;
    reward_Voltages             = [zeros(1,round(t.Dacrate*pad/2)) Volt*ones(1,round(t.Dacrate*s.RewardTime)) zeros(1,round(t.Dacrate*pad/2))];
    t.ndacsamples               = floor(t.Dacrate*Wave_time);
    t.dacBuffAddr               = 6e6;
    t.chnl                      = 2;
    Datapixx('RegWrRd');
    DacData=Volt*ones(1,round(t.Dacrate*s.RewardTime));
    DacData(length(DacData):1000)=0;
    Datapixx('WriteDacBuffer', DacData);
    Datapixx('RegWrRd');
    Datapixx('SetDacSchedule', t.chnl, [1000,1], 1000); % 1000 times per second, and our demo has 1000 frames.
    Datapixx('StartDacSchedule');
    Datapixx('RegWrRd');
    strobe(c.codes.freevibration);
    time_return=GetSecs - t.trstart;

    
    
    
elseif typeoffreeoutcome==34 %flash and sound
freq          = 10000;                % Sampling rate. samples/second
rightFreq     = 300;                  % A low-frequency tone to signal "WRONG"
wrongFreq     = 150;                  % A high-frequency tone to signal "RIGHT"
nTF=            round(freeouthowlong*10*1000); % The tone-duration.
lrMode        = 0;                    % Mono sound on both channels.
wrongbuffadd  = 0;                    % Start-address of the first sound's buffer.
risefallProp                    = 1/4;                              % proportion of sound for rise/fall
plateauProp                     = 1-2*risefallProp;                 % proportion of sound for plateau
mu1                             = round(risefallProp*nTF);        % Gaussian mean expressed in samples
sigma1                          = round(nTF/12);                  % Gaussian SD in samples, effectively the rate of rise/fall.
tempWindow                      = [normpdf(1:mu1,mu1,sigma1),...                                % RISE
    ones(1,round(plateauProp*nTF))*normpdf(mu1,mu1,sigma1),...    % PLATEAU (scaled to meet the rise/fall)
    fliplr(normpdf(1:mu1,mu1,sigma1))];                             % FALL
% Additively scale the window to ensure that it starts and ends at zero.
tempWindow                      = tempWindow - min(tempWindow);
% Multiplicatively scale the window to put the plateau at one.
tempWindow                      = tempWindow/max(tempWindow);
% Make the two sounds, one at 150hz ("righttone"), one at 300hz ("wrongtone").
wrongtone     = tempWindow.*sin((1:nTF)*2*pi*wrongFreq/freq);
righttone     = tempWindow.*sin((1:nTF)*2*pi*rightFreq/freq);
noisetone     = tempWindow.*((rand(1,nTF)-0.5)*2);
% Normalize the windowed sounds (keep them between -1 and 1.
wrongtone     = wrongtone/max(abs(wrongtone));
righttone     = righttone/max(abs(righttone));
noisetone     = noisetone/max(abs(noisetone));
noisebuffadd = Datapixx('WriteAudioBuffer', wrongtone, 0);
Datapixx('RegWrRd');
Datapixx('SetAudioVolume', 0.25);       % Not too loud
Datapixx('RegWrRd');
Datapixx('WriteAudioBuffer', noisetone, noisebuffadd);
Datapixx('SetAudioSchedule', 0, freq, nTF, lrMode, noisebuffadd, nTF);
Datapixx('StartAudioSchedule');
    Screen('FillRect', c.window, convertColorToL48D(9));
    Screen('DrawLines', c.window, t.GridXY,[], convertColorToL48D( t.gridc), c.middleXY);
   % Screen('FillRect', c.window, convertColorToL48D(t.ecolor), [s.EyeX s.EyeY s.EyeX s.EyeY] + [-1 -1 1 1]*c.EyePtR + repmat(c.middleXY,1,2));
    strobe(c.codes.freeflashsound);
    strobe(typeoffreeoutcome);
    time_return1 = Screen('Flip', c.window, GetSecs + 0.00);
    time_return=time_return1-t.trstart;
%     temp=1;
%     while temp==1
%         if GetSecs >=time_return1+freeouthowlong;
%             Screen('FillRect', c.window, convertColorToL48D(2));
%             Screen('DrawLines', c.window, t.GridXY,[], convertColorToL48D( t.gridc), c.middleXY);
%           %  Screen('FillRect', c.window, convertColorToL48D(t.ecolor), [s.EyeX s.EyeY s.EyeX s.EyeY] + [-1 -1 1 1]*c.EyePtR + repmat(c.middleXY,1,2));
%             Screen('Flip', c.window, GetSecs + 0.00);
%             temp=2;
%         end
%     end
Datapixx('RegWrRd');
% end



elseif typeoffreeoutcome==35 %flash and sound happen on the left
freq          = 10000;                % Sampling rate. samples/second
rightFreq     = 300;                  % A low-frequency tone to signal "WRONG"
wrongFreq     = 150;                  % A high-frequency tone to signal "RIGHT"
nTF=            round(freeouthowlong*10*1000); % The tone-duration.
wrongbuffadd  = 0;                    % Start-address of the first sound's buffer.
risefallProp                    = 1/4;                              % proportion of sound for rise/fall
plateauProp                     = 1-2*risefallProp;                 % proportion of sound for plateau
mu1                             = round(risefallProp*nTF);        % Gaussian mean expressed in samples
sigma1                          = round(nTF/12);                  % Gaussian SD in samples, effectively the rate of rise/fall.
tempWindow                      = [normpdf(1:mu1,mu1,sigma1),...                                % RISE
    ones(1,round(plateauProp*nTF))*normpdf(mu1,mu1,sigma1),...    % PLATEAU (scaled to meet the rise/fall)
    fliplr(normpdf(1:mu1,mu1,sigma1))];                             % FALL
% Additively scale the window to ensure that it starts and ends at zero.
tempWindow                      = tempWindow - min(tempWindow);
% Multiplicatively scale the window to put the plateau at one.
tempWindow                      = tempWindow/max(tempWindow);
% % Make the two sounds, one at 150hz ("righttone"), one at 300hz ("wrongtone").
%  wrongtone     = tempWindow.*sin((1:nTF)*2*pi*wrongFreq/freq);
% % righttone     = tempWindow.*sin((1:nTF)*2*pi*rightFreq/freq);
% noisetone     = tempWindow.*((rand(1,nTF)-0.5)*2);
% % Normalize the windowed sounds (keep them between -1 and 1.
% wrongtone     = wrongtone/max(abs(wrongtone));
% %righttone     = righttone/max(abs(righttone));
% noisetone     = noisetone/max(abs(noisetone));
% noisebuffadd = Datapixx('WriteAudioBuffer', noisetone, 0);
% Datapixx('RegWrRd');
% Datapixx('SetAudioVolume', 0.25);       % Not too loud
% Datapixx('RegWrRd');
% Datapixx('WriteAudioBuffer', noisetone, noisetone);
% Datapixx('SetAudioSchedule', 0, freq, nTF, lrMode, noisebuffadd, nTF);
% Datapixx('StartAudioSchedule');

wrongtone     = tempWindow.*sin((1:nTF)*2*pi*wrongFreq/freq);
righttone     = tempWindow.*sin((1:nTF)*2*pi*rightFreq/freq);
noisetone     = tempWindow.*((rand(1,nTF)-0.5)*2);
% Normalize the windowed sounds (keep them between -1 and 1.
wrongtone     = wrongtone/max(abs(wrongtone));
righttone     = righttone/max(abs(righttone));
noisetone     = noisetone/max(abs(noisetone));
noisebuffadd = Datapixx('WriteAudioBuffer', wrongtone, 0);
Datapixx('RegWrRd');
Datapixx('SetAudioVolume', 0.25);       % Not too loud
Datapixx('RegWrRd');
Datapixx('WriteAudioBuffer', noisetone, noisebuffadd);
%Datapixx('SetAudioSchedule', scheduleOnset, scheduleRate, maxScheduleFrames [, lrMode=mono] [, bufferBaseAddress=hex2dec('16e6')] [, numBufferFrames=maxScheduleFrames]);
Datapixx('SetAudioSchedule', 0, freq, nTF,lrMode, noisebuffadd, nTF);
Datapixx('StartAudioSchedule');

if left==1
    targXY                = 30*[cosd(180), sind(180)];
else
    targXY                = 30*[cosd(0), sind(0)];
end

SquareDimensions=[-30 -300 30 300];

PtargXY     = [sign(targXY(1))*deg2pix(abs(targXY(1)),c) -sign(targXY(2))*deg2pix(abs(targXY(2)),c)]; % target point xy
Screen('FillRect', c.window, convertColorToL48D(9),repmat(PtargXY+c.middleXY,1,2) + 2*SquareDimensions,20);
Screen('DrawLines', c.window, t.GridXY,[], convertColorToL48D( t.gridc), c.middleXY);
Screen('FillRect', c.window, convertColorToL48D(t.ecolor), [s.EyeX s.EyeY s.EyeX s.EyeY] + [-1 -1 1 1]*c.EyePtR + repmat(c.middleXY,1,2));
strobe(c.codes.freeflashsound);
strobe(typeoffreeoutcome);
time_return1 = Screen('Flip', c.window, GetSecs + 0.00);
time_return=time_return1-t.trstart;
temp=1;
% while temp==1
%     if GetSecs >=time_return1+freeouthowlong;
%         Screen('FillRect', c.window, convertColorToL48D(2),repmat(PtargXY+c.middleXY,1,2) + 2*SquareDimensions,20);
%         Screen('DrawLines', c.window, t.GridXY,[], convertColorToL48D( t.gridc), c.middleXY);
%         Screen('FillRect', c.window, convertColorToL48D(t.ecolor), [s.EyeX s.EyeY s.EyeX s.EyeY] + [-1 -1 1 1]*c.EyePtR + repmat(c.middleXY,1,2));
%         Screen('Flip', c.window, GetSecs + 0.00);
%         temp=2;
%     end
% end
Datapixx('RegWrRd');
end




time_return_final=time_return;
end

endtime=GetSecs;
end %endof the helper function


function pixels             =   deg2pix(degrees,c) % PPD pixels/degree
% deg2pix convert degrees of visual angle into pixels
pixels = round(tand(degrees)*c.viewdist*c.screenhpix/c.screenh);

end


function strobe(word)
Datapixx('SetDoutValues',fix(word),hex2dec('007fff'))    % set word in first 15 bits
Datapixx('RegWr');
Datapixx('SetDoutValues',2^16,hex2dec('010000'))   % set STRB to 1 (true)
Datapixx('RegWr');
Datapixx('SetDoutValues',0,hex2dec('017fff'))      % reset strobe and all 15 bits to 0.
Datapixx('RegWr');
end



