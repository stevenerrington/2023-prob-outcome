function [PDS ,c ,s] = savedata(PDS ,c ,s)

% disp('Saving Data...')
% save(['../Output/VisSac_' datestr(now, 'dd-mm-yyyy_HH:MM') '.mat'],'PDS','c','s','-mat');
% multiPagePDF(findall(0,'Type', 'Figure'), ['VisSac_' datestr(now, 'dd-mm-yyyy_HH:MM')]);
% disp('Save Complete!')

disp('Saving Data...')
save(['../Output/' c.output_prefix '_' datestr(now, 'dd_mm_yyyy_HH_MM') '.mat'],'PDS','c','s','-mat');
%multiPagePDF(findall(0,'Type', 'Figure'), ['VisSac_' datestr(now, 'dd-mm-yyyy_HH:MM')]);
disp('Save Complete!')