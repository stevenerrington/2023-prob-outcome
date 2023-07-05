function [option_info] = get_choice_info(PDS, trialInfo)

option_info = [];

for trl_i = 1:length(PDS.trialnumber)
    
    if ~isnan(trialInfo.choiceSelected(trl_i))
        option_info.option1_rwd_amt(trl_i,1) = PDS.offerInfo{1, 1}.choice_rwdamount(trl_i);
        option_info.option1_rwd_prob(trl_i,1) = PDS.offerInfo{1, 1}.choice_rwdprob(trl_i);
        option_info.option1_rwd_ev(trl_i,1) = option_info.option1_rwd_amt(trl_i,1).*option_info.option1_rwd_prob(trl_i,1);
        
        option_info.option1_punish_amt(trl_i,1) = PDS.offerInfo{1, 1}.choice_punishamount(trl_i);
        option_info.option1_punish_prob(trl_i,1) = PDS.offerInfo{1, 1}.choice_punishprob(trl_i);
        option_info.option1_punish_ev(trl_i,1) = option_info.option1_punish_amt(trl_i,1).*option_info.option1_punish_prob(trl_i,1);

        option_info.option2_rwd_amt(trl_i,1) = PDS.offerInfo{1, 2}.choice_rwdamount(trl_i);
        option_info.option2_rwd_prob(trl_i,1) = PDS.offerInfo{1, 2}.choice_rwdprob(trl_i);
        option_info.option2_rwd_ev(trl_i,1) = option_info.option2_rwd_amt(trl_i,1).*option_info.option2_rwd_prob(trl_i,1);
       
        option_info.option2_punish_amt(trl_i,1) = PDS.offerInfo{1, 2}.choice_punishamount(trl_i);
        option_info.option2_punish_prob(trl_i,1) = PDS.offerInfo{1, 2}.choice_punishprob(trl_i);
        option_info.option2_punish_ev(trl_i,1) = option_info.option2_punish_amt(trl_i,1).*option_info.option2_punish_prob(trl_i,1);

    else
        option_info.option1_rwd_amt(trl_i,1) = NaN;
        option_info.option1_rwd_prob(trl_i,1) = NaN;
        option_info.option1_rwd_ev(trl_i,1) = NaN;
        option_info.option1_punish_amt(trl_i,1) = NaN;
        option_info.option1_punish_prob(trl_i,1) = NaN;
        option_info.option1_punish_ev(trl_i,1) = NaN;
        option_info.option2_rwd_amt(trl_i,1) = NaN;
        option_info.option2_rwd_prob(trl_i,1) = NaN;
        option_info.option2_rwd_ev(trl_i,1) = NaN;
        option_info.option2_punish_amt(trl_i,1) = NaN;
        option_info.option2_punish_prob(trl_i,1) = NaN;
        option_info.option2_punish_ev(trl_i,1) = NaN;
        
    end
end

option_info.option_selected = trialInfo.choiceSelected-1;
option_info = struct2table(option_info);

