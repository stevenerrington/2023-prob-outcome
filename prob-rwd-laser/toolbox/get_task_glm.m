function glmModel = get_task_glm(option_info)

glm_eq_function = ['option_selected ~ selected_rwd_amt*selected_rwd_prob + selected_punish_amt*selected_punish_prob' ...
    ' + nonselected_rwd_amt*nonselected_rwd_prob + nonselected_punish_amt*nonselected_punish_prob'...
    '+ nonselected_rwd_amt*nonselected_rwd_prob*nonselected_punish_amt*nonselected_punish_prob'...
    '+ selected_rwd_amt*selected_rwd_prob*selected_punish_amt*selected_punish_prob'];


% Fit the GLM model
glmModel = fitglm(option_info,glm_eq_function,'Distribution', 'binomial');

%% 














