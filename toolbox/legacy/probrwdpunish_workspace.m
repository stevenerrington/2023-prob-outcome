[p_choice_feature] = get_pchoice_feature(choice_info);
[option_info] = get_option_info_glm(data.PDS, trialInfo);
glmModel = get_task_glm(option_info);