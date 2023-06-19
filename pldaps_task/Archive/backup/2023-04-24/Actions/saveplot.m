function [PDS ,c ,s] = saveplot(PDS ,c ,s)

display('Saving Online Plot Window')
set(0, 'CurrentFigure', c.onplotwin);

myprint(['../Output/VisSac_' date '_' c.trialnumber '.pdf'])
display('Figure-Save Complete!')
end