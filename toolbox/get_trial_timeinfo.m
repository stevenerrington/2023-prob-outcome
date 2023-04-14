function [trialEventTimes, trialInfo] = get_trial_timeinfo(PDS)

% Setup table of key event times
trialEventTimes = table();
trialEventTimes.i = PDS.trialnumber';
trialEventTimes.trialStart = PDS.trialstarttime;
trialEventTimes.fixOn      = trialEventTimes.trialStart+PDS.timefpon';
trialEventTimes.choice1_on = trialEventTimes.trialStart+PDS.timetargeton';
trialEventTimes.choice2_on = trialEventTimes.trialStart+PDS.timetargeton2';
trialEventTimes.punish = trialEventTimes.trialStart+PDS.timepunish';
trialEventTimes.reward = trialEventTimes.trialStart+PDS.timereward';
trialEventTimes.trialEnd = trialEventTimes.trialStart+PDS.trialover';

trialInfo = table();
trialInfo.i = PDS.trialnumber';
trialInfo.choice_order = PDS.whichtoshowfirst';
trialInfo.choiceSelected = PDS.chosenwindow';
trialInfo.delivered_punish = PDS.magnitude_punish';
trialInfo.delivered_punish = PDS.magnitude_reward';

trialInfo.choiceA_rwd_prob = PDS.offerInfo{1, 1}.choice_rwdprob';
trialInfo.choiceA_rwd_amt = PDS.offerInfo{1, 1}.choice_rwdamount';
trialInfo.choiceA_punish_prob = PDS.offerInfo{1, 1}.choice_punishprob';
trialInfo.choiceA_punish_amt = PDS.offerInfo{1, 1}.choice_punishamount';

trialInfo.choiceB_rwd_prob = PDS.offerInfo{1, 2}.choice_rwdprob';
trialInfo.choiceB_rwd_amt = PDS.offerInfo{1, 2}.choice_rwdamount';
trialInfo.choiceB_punish_prob = PDS.offerInfo{1, 2}.choice_punishprob';
trialInfo.choiceB_punish_amt = PDS.offerInfo{1, 2}.choice_punishamount';

for trl_i = 1:length(trialEventTimes.i)
    switch trialInfo.choiceSelected(trl_i)
        case 1
            trialInfo.choiceSelect_rwd_reveal(trl_i,1) = PDS.offerInfo{1, 1}.reveal_rwdprob(trl_i);
            trialInfo.choiceSelect_punish_reveal(trl_i,1) = PDS.offerInfo{1, 1}.reveal_punishprob(trl_i);

        case 2
            trialInfo.choiceSelect_rwd_reveal(trl_i,1) = PDS.offerInfo{1, 2}.reveal_rwdprob(trl_i);
            trialInfo.choiceSelect_punish_reveal(trl_i,1) = PDS.offerInfo{1, 2}.reveal_punishprob(trl_i);
    end
end

trialInfo.choiceSelect_rwd_amount = PDS.magnitude_reward';
trialInfo.choiceSelect_punish_amount = PDS.magnitude_punish';


end