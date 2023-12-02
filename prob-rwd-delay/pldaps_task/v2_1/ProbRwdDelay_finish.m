function [PDS ,c ,s] = ProbRwdDelay_finish(PDS ,c ,s)
%% Cleanup
Screen('Close')
warning on;

%% Update Online Plots
if c.repeatflag ~=1
% try
%         [c, s, PDS]         = plotupdate_v03(c, s, PDS);% 
% catch
%     disp('ERROR - Plot update failed!');
% end
end

end
