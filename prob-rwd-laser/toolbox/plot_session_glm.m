function glm_out = plot_session_glm(choice_info)

clear rawbehav
rawbehav.choices=[choice_info.option1_rwd_ev,...
    choice_info.option1_punish_ev,...
    choice_info.option2_rwd_ev,...
    choice_info.option2_punish_ev,...
    choice_info.option_selected+1];

bbd.monk.sva{1} = aatradeoff_subjective_value_analysis_v04(rawbehav.choices);
modan = bbd.monk.sva{1}.model;
bfit = bbd.monk.sva{1}.model.analysis{1}.behav_full_fit;
figuren; eglm_plot_fit(bfit);

glm_out = bbd.monk.sva{1};

end