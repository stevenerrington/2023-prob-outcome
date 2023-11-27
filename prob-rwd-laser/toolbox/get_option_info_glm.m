function [option_info] = get_option_info_glm(PDS, trialInfo)

option_info = [];

for trl_i = 1:length(PDS.trialnumber)
    
    if ~isnan(trialInfo.choiceSelected(trl_i))
        switch trialInfo.choiceSelected(trl_i)
            case 1
                option_info.selected_rwd_amt(trl_i,1) = PDS.offerInfo{1, 1}.choice_rwdamount(trl_i);
                option_info.selected_rwd_prob(trl_i,1) = PDS.offerInfo{1, 1}.choice_rwdprob(trl_i);
                option_info.selected_punish_amt(trl_i,1) = PDS.offerInfo{1, 1}.choice_punishamount(trl_i);
                option_info.selected_punish_prob(trl_i,1) = PDS.offerInfo{1, 1}.choice_punishprob(trl_i);
    
                option_info.nonselected_rwd_amt(trl_i,1) = PDS.offerInfo{1, 2}.choice_rwdamount(trl_i);
                option_info.nonselected_rwd_prob(trl_i,1) = PDS.offerInfo{1, 2}.choice_rwdprob(trl_i);
                option_info.nonselected_punish_amt(trl_i,1) = PDS.offerInfo{1, 2}.choice_punishamount(trl_i);
                option_info.nonselected_punish_prob(trl_i,1) = PDS.offerInfo{1, 2}.choice_punishprob(trl_i);
                       
            case 2
                option_info.selected_rwd_amt(trl_i,1) = PDS.offerInfo{1, 2}.choice_rwdamount(trl_i);
                option_info.selected_rwd_prob(trl_i,1) = PDS.offerInfo{1, 2}.choice_rwdprob(trl_i);
                option_info.selected_punish_amt(trl_i,1) = PDS.offerInfo{1, 2}.choice_punishamount(trl_i);
                option_info.selected_punish_prob(trl_i,1) = PDS.offerInfo{1, 2}.choice_punishprob(trl_i);
    
                option_info.nonselected_rwd_amt(trl_i,1) = PDS.offerInfo{1, 1}.choice_rwdamount(trl_i);
                option_info.nonselected_rwd_prob(trl_i,1) = PDS.offerInfo{1, 1}.choice_rwdprob(trl_i);
                option_info.nonselected_punish_amt(trl_i,1) = PDS.offerInfo{1, 1}.choice_punishamount(trl_i);
                option_info.nonselected_punish_prob(trl_i,1) = PDS.offerInfo{1, 1}.choice_punishprob(trl_i);
        
        end
    else
        option_info.selected_rwd_amt(trl_i,1) = NaN;
        option_info.selected_rwd_prob(trl_i,1) = NaN;
        option_info.selected_punish_amt(trl_i,1) = NaN;
        option_info.selected_punish_prob(trl_i,1) = NaN;
        option_info.nonselected_rwd_amt(trl_i,1) = NaN;
        option_info.nonselected_rwd_prob(trl_i,1) = NaN;
        option_info.nonselected_punish_amt(trl_i,1) = NaN;
        option_info.nonselected_punish_prob(trl_i,1) = NaN;
        
    end
end

option_info.option_selected = trialInfo.choiceSelected-1;
option_info = struct2table(option_info);