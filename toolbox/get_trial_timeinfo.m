function [trialEventTimes, trialInfo] = get_trial_timeinfo(PDS)

% Setup table of key event times
trialEventTimes = table();
trialEventTimes.i = PDS.trialnumber';
trialEventTimes.trialStart = PDS.trialstarttime;
trialEventTimes.fixOn      = trialEventTimes.trialStart+PDS.timefpon';
trialEventTimes.choice1_on = trialEventTimes.trialStart+PDS.timetargeton';
trialEventTimes.choice2_on = trialEventTimes.trialStart+PDS.timetargeton2';
trialEventTimes.punish = trialEventTimes.trialStart+PDS.TimeofPunish';
trialEventTimes.reward = trialEventTimes.trialStart+PDS.timereward';
trialEventTimes.trialEnd = trialEventTimes.trialStart+PDS.trialover';

trialInfo = table();
trialInfo.i = PDS.trialnumber';
trialInfo.choice_order = PDS.whichtoshowfirst';
trialInfo.choiceSelected = PDS.chosenwindow';
trialInfo.delivered_punish = PDS.PunishStrength_';

trialInfo.choiceA_rwd_prob = PDS.Offer1_Choice_RwdProb';
trialInfo.choiceA_rwd_amt = PDS.Offer1_Choice_RwdAmt';
trialInfo.choiceA_punish_prob = PDS.Offer1_Choice_PunishProb';
trialInfo.choiceA_punish_amt = PDS.Offer1_Choice_PunishAmt';

trialInfo.choiceB_rwd_prob = PDS.Offer2_Choice_RwdProb';
trialInfo.choiceB_rwd_amt = PDS.Offer2_Choice_RwdAmt';
trialInfo.choiceB_punish_prob = PDS.Offer2_Choice_PunishProb';
trialInfo.choiceB_punish_amt = PDS.Offer2_Choice_PunishAmt';

for trl_i = 1:length(trialEventTimes.i)
    switch trialInfo.choiceSelected(trl_i)
        case 1
            trialInfo.choiceSelect_rwd_reveal(trl_i,1) = PDS.Offer1_Reveal_RwdProb(trl_i);
            trialInfo.choiceSelect_punish_reveal(trl_i,1) = PDS.Offer1_Reveal_PunishProb(trl_i);
        case 2
            trialInfo.choiceSelect_rwd_reveal(trl_i,1) = PDS.Offer2_Reveal_RwdProb(trl_i);
            trialInfo.choiceSelect_punish_reveal(trl_i,1) = PDS.Offer2_Reveal_PunishProb(trl_i);
    end
end

end