function [PDS, c, s] = datatoworkspace(PDS, c, s)
assignin('base','c',c)
assignin('base','PDS',PDS)
assignin('base','s',s)
end