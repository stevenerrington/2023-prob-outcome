% % % % % 
% % % % % %%% DRIVER INFO
% % % % % %% HL-340    https://learn.sparkfun.com/tutorials/how-to-install-ch340-drivers/all
% % % % % 
% % % % % %this gets the address after the driver is installed
% % % % % %ls /dev/cu*
% % % % % 
% % % % % 
% % % % % %/dev/cu.Bluetooth-Incoming-Port	/dev/cu.wchusbserial20310
% % % % % 



try
    instrreset
    fclose(s1)
    clear s1
end

s1 = serial('/dev/cu.wchusbserial20310', 'BaudRate', 9600);
fopen(s1)
%instrfind

while  s1.BytesAvailable==0 %wait for bits (from evil laser) and then, go on to fwrite to ping it with 'P'
end
fwrite(s1,'P'); %this is the handshake with laser.


load('/Users/monosovlab/Desktop/pulseMatrix.mat')
startChar = s.startChar;
endChar = s.endChar;
laserOnChar = s.laserOnChar;
operateOnChar = s.operateOnChar;
calChar = s.calChar;
setChar = s.setChar ;
pulseChar = s.pulseChar; 

% unique_paramSet = unique(pulse_params,'rows');
% for iParamSet = 1:size(unique_paramSet,1)
%    ParamSetCalib(iParamSet).x = [startChar,calChar,unique_paramSet.duration_msec_(iParamSet)-1,unique_paramSet.energy_joules_(iParamSet)/0.25-1,unique_paramSet.spotSize_mm_(iParamSet)-4,endChar]
% end

clear ParamSetCalib
durations=1; %1 is a 2ms pulse
spotsize=0; % 0 means 4mm which is the smallest spot size
energy=[1 1.5 1.75 2];
for iParamSet = 1:length(energy)
   ParamSetCalib(iParamSet).x = [startChar,calChar,energy(iParamSet)/0.25-1,0,endChar];
end


clear StrControl
%%% laser on
StrControl=sprintf('%X', 'L111'); 
fwrite(s1, sscanf('CC', '%x'), 'uint8')
fwrite(s1, sscanf(StrControl(1:2), '%x'), 'uint8')
fwrite(s1, sscanf(StrControl(3:4), '%x'), 'uint8')
fwrite(s1, sscanf(StrControl(5:6), '%x'), 'uint8')
fwrite(s1, sscanf(StrControl(7:8), '%x'), 'uint8')
fwrite(s1, sscanf('B9', '%x'), 'uint8')

pause(6);

clear StrControl
%%   %operate on
StrControl=sprintf('%X', 'O111'); 
fwrite(s1, sscanf('CC', '%x'), 'uint8')
fwrite(s1, sscanf(StrControl(1:2), '%x'), 'uint8')
fwrite(s1, sscanf(StrControl(3:4), '%x'), 'uint8')
fwrite(s1, sscanf(StrControl(5:6), '%x'), 'uint8')
fwrite(s1, sscanf(StrControl(7:8), '%x'), 'uint8')
fwrite(s1, sscanf('B9', '%x'), 'uint8')


%% calibrate
for i=1:size(ParamSetCalib,2)

fwrite(s1, sscanf('CC', '%x'), 'uint8')
fwrite(s1, ParamSetCalib(i).x(2), 'uint8')
fwrite(s1, ParamSetCalib(i).x(3), 'uint8')
fwrite(s1, ParamSetCalib(i).x(4), 'uint8')
fwrite(s1, ParamSetCalib(i).x(5), 'uint8')
fwrite(s1, sscanf('B9', '%x'), 'uint8')
%data = char(fread(s1, s1.bytesavailable))
%%
pause
end


% for x=1:1000000000000000
%     pause(6);
%     %%   %operate on
%     StrControl=sprintf('%X', 'O111');
%     fwrite(s1, sscanf('CC', '%x'), 'uint8')
%     fwrite(s1, sscanf(StrControl(1:2), '%x'), 'uint8')
%     fwrite(s1, sscanf(StrControl(3:4), '%x'), 'uint8')
%     fwrite(s1, sscanf(StrControl(5:6), '%x'), 'uint8')
%     fwrite(s1, sscanf(StrControl(7:8), '%x'), 'uint8')
%     fwrite(s1, sscanf('B9', '%x'), 'uint8')
% end




%% pulse set
iPulse=1
LaserPulse=[startChar,setChar,durations,unique_paramSet.energy_joules_(iPulse)/0.25-1,unique_paramSet.spotSize_mm_(iPulse)-4,endChar]
fwrite(s1, sscanf('CC', '%x'), 'uint8')
fwrite(s1, LaserPulse(2), 'uint8')
fwrite(s1, LaserPulse(3), 'uint8')
fwrite(s1, LaserPulse(4), 'uint8')
fwrite(s1, LaserPulse(5), 'uint8')
fwrite(s1, sscanf('B9', '%x'), 'uint8')
data = char(fread(s1, s1.bytesavailable))
pause(3)

%% pulse go
PulseString=[startChar,pulseChar,049,049,049,endChar]
fwrite(s1, sscanf('CC', '%x'), 'uint8')
fwrite(s1, PulseString(2), 'uint8')
fwrite(s1, PulseString(3), 'uint8')
fwrite(s1, PulseString(4), 'uint8')
fwrite(s1, PulseString(5), 'uint8')
fwrite(s1, sscanf('B9', '%x'), 'uint8')
data = char(fread(s1, s1.bytesavailable))
    
    

endlaser=[startChar,laserOnChar,030,030,030,endChar];
fwrite(s1, sscanf('CC', '%x'), 'uint8')
fwrite(s1, endlaser(2), 'uint8')
fwrite(s1, endlaser(3), 'uint8')
fwrite(s1, endlaser(4), 'uint8')
fwrite(s1, endlaser(5), 'uint8')
fwrite(s1, sscanf('B9', '%x'), 'uint8')




dvxz
