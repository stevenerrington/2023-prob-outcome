function [choice_info_clean, validTrials, nonvalidTrials]  = clean_choice_info(choice_info)

validTrials = ~isnan(choice_info.option_selected);
nonvalidTrials = isnan(choice_info.option_selected);
choice_info_clean = choice_info(validTrials,:);

end