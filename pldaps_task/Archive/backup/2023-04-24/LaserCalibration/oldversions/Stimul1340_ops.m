laser = serialport('COM1',9600);
writeline(laser,'P');

pulse_params = readtable('/Users/monosovlab/Desktop/example_params.xlsx');


startChar = '0xcc';
endChar = '0xb9';
laserOnChar = '0x4c'; 
operateOnChar = '0x4f';
calChar = '0x43';
setChar = '0x50';
pulseChar = '0x47'; 




write(laser,[startChar,laserOnChar,049,049,049,endChar],'uint8') %laser on
pause
write(laser,[startChar,operateOnChar,049,049,049,endChar],'uint8') %operate on

%calibrate all pulses necessary
unique_paramSet = unique(pulse_params,'rows');
for iParamSet = 1:size(unique_paramSet,1)
    pause %press any key to continue once you hear/see the calibration for that energy finish
    write(laser,[startChar,calChar,unique_paramSet.duration_msec_(iParamSet)-1,unique_paramSet.energy_joules_(iParamSet)/0.25-1,unique_paramSet.spotSize_mm_(iParamSet)-4,endChar],'uint8') %calibrate  
end

nPulses = size(pulse_params,1);
for iPulse = 1:nPulses     
    pause(1)
    write(laser,[startChar,setChar,pulse_params.duration(iPulse)-1,pulse_params.energy(iPulse)/0.25-1,pulse_params.spotSize(iPulse)-4,endChar],'uint8') %set pulse
    pause(pulse_params.isi - 1)
    write(laser,[startChar,pulseChar,049,049,049,endChar],'uint8') %send pulse
end

disp('All done. Pain accomplished.')

%%turn laser off, close com port
write(laser,[startChar,laserOnChar,030,030,030,endChar],'uint8') %laser off (i.e., standby mode)
clear laser