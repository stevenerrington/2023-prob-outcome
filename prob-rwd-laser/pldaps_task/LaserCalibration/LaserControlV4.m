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

s1 = serial('/dev/cu.wchusbserial2020', 'BaudRate', 9600);
fclose(s1)
s1 = serial('/dev/cu.wchusbserial2020', 'BaudRate', 9600);
fopen(s1)

%instrfind

%%
while  s1.BytesAvailable==0 %wait for bits (from evil laser) and then, go on to fwrite to ping it with 'P'
end
fwrite(s1,'P'); %this is the handshake with laser.



%%
load('/Users/ilyamonosov/Documents/MATLAB/ProbRwdPunish/LaserCalibration/pulseMatrix.mat')
startChar = s.startChar;
endChar = s.endChar;
laserOnChar = s.laserOnChar;
operateOnChar = s.operateOnChar;
calChar = s.calChar;
setChar = s.setChar ;
pulseChar = s.pulseChar; 
%%
clear ParamSetCalib
durations=1; %1 is a 2ms pulse
spotsize=0; % 0 means 4mm which is the smallest spot size
% energy = [0 0.5 0.75 1];
energy = [0 0.5 1 1.5];
for iParamSet = 1:length(energy)
   ParamSetCalib(iParamSet).x = [startChar,calChar,durations, energy(iParamSet)/0.25-1,0,endChar];
end
%%

% YYF: I was trying to test something out again and when I opened this
% script this section was empty - not sure how laser was being turned on
% without it so I added it back but commented it out in case there's
% something I'm missing and it was removed for a reason

%%% <------ OK, Yangyang. by To

clear StrControl
%%% laser on
StrControl=sprintf('%X', 'L111'); 
fwrite(s1, sscanf('CC', '%x'), 'uint8')
fwrite(s1, sscanf(StrControl(1:2), '%x'), 'uint8')
fwrite(s1, sscanf(StrControl(3:4), '%x'), 'uint8')
fwrite(s1, sscanf(StrControl(5:6), '%x'), 'uint8')
fwrite(s1, sscanf(StrControl(7:8), '%x'), 'uint8')
fwrite(s1, sscanf('B9', '%x'), 'uint8')





%%wait for 10 seconds
%% operate on
clear StrControl
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


% % % % % % % for x=1:1000000000000000
% % % % % % %     pause(6);
% % % % % % %     %%   %operate on
% % % % % % %     StrControl=sprintf('%X', 'O111');
% % % % % % %     fwrite(s1, sscanf('CC', '%x'), 'uint8')
% % % % % % %     fwrite(s1, sscanf(StrControl(1:2), '%x'), 'uint8')
% % % % % % %     fwrite(s1, sscanf(StrControl(3:4), '%x'), 'uint8')
% % % % % % %     fwrite(s1, sscanf(StrControl(5:6), '%x'), 'uint8')
% % % % % % %     fwrite(s1, sscanf(StrControl(7:8), '%x'), 'uint8')
% % % % % % %     fwrite(s1, sscanf('B9', '%x'), 'uint8')
% % % % % % % end



% % 
% % %% pulse set
% iPulse=1
% LaserPulse=[startChar,setChar,durations,energy(iPulse)/0.25-1,spotsize,endChar]
% fwrite(s1, sscanf('CC', '%x'), 'uint8')
% fwrite(s1, LaserPulse(2), 'uint8')
% fwrite(s1, LaserPulse(3), 'uint8')
% fwrite(s1, LaserPulse(4), 'uint8')
% fwrite(s1, LaserPulse(5), 'uint8')
% fwrite(s1, sscanf('B9', '%x'), 'uint8')
% data = char(fread(s1, s1.bytesavailable))
% pause(3)
% 
% %% pulse go
% PulseString=[startChar,pulseChar,049,049,049,endChar]
% fwrite(s1, sscanf('CC', '%x'), 'uint8')
% fwrite(s1, PulseString(2), 'uint8')
% fwrite(s1, PulseString(3), 'uint8')
% fwrite(s1, PulseString(4), 'uint8')
% fwrite(s1, PulseString(5), 'uint8')
% fwrite(s1, sscanf('B9', '%x'), 'uint8')
% data = char(fread(s1, s1.bytesavailable))
%     
% %     

% % % % % % % endlaser=[startChar,laserOnChar,030,030,030,endChar];
% % % % % % % fwrite(s1, sscanf('CC', '%x'), 'uint8')
% % % % % % % fwrite(s1, endlaser(2), 'uint8')
% % % % % % % fwrite(s1, endlaser(3), 'uint8')
% % % % % % % fwrite(s1, endlaser(4), 'uint8')
% % % % % % % fwrite(s1, endlaser(5), 'uint8')
% % % % % % % fwrite(s1, sscanf('B9', '%x'), 'uint8')
% % % % % % % 
% % % % % % % 
% % % % % % % 
% % % % % % % 
% % % % % % % dvxz
