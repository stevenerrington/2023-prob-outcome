clear all; close all;

addpath(fullfile('.','ethan_dependencies'));

addpath(fullfile('.','test'));

addpath('/Users/Ilya/Dropbox/HELPER/HELPER_GENERAL/'); %so it works on my mac or PC
addpath('C:\Users\Ilya Monosov\Dropbox\HELPER\HELPER_GENERAL'); %so it works on my mac or PC


DDD = dir(['P*.mat']);

AllChoices=[];
for xyz = 1:length(DDD)
    clear choices;
    filename = DDD(xyz).name(1:end-4);
    load([filename '.mat'],'PDS'); %load session
    Of1choice_rwdamount=PDS.offerInfo{1}.choice_rwdamount;
    Of1choice_rwdprob=PDS.offerInfo{1}.choice_rwdprob;
    Of1choice_punishamount=PDS.offerInfo{1}.choice_punishamount;
    Of1choice_punishprob=PDS.offerInfo{1}.choice_punishprob;

    Of2choice_rwdamount=PDS.offerInfo{2}.choice_rwdamount;
    Of2choice_rwdprob=PDS.offerInfo{2}.choice_rwdprob;
    Of2choice_punishamount=PDS.offerInfo{2}.choice_punishamount;
    Of2choice_punishprob=PDS.offerInfo{2}.choice_punishprob;

    choices=[Of1choice_rwdamount
        Of1choice_rwdprob
        Of1choice_punishamount
        Of1choice_punishprob
        Of2choice_rwdamount
        Of2choice_rwdprob
        Of2choice_punishamount
        Of2choice_punishprob
        PDS.chosenwindow
        ]';

    choices((find(isnan(choices(:,end))==1)+1),end)=NaN;
    choices=choices(find(choices(:,end)>-1),:);

    AllChoices=[AllChoices; choices];
end
 
choices=AllChoices;
save choices.mat choices


Of1Er_reward=times(Of1choice_rwdprob,Of1choice_rwdamount)
Of1Er_punish=times(Of1choice_punishprob,Of1choice_punishamount)

Of2Er_reward=times(Of2choice_rwdprob,Of2choice_rwdamount)
Of2Er_punish=times(Of2choice_punishprob,Of2choice_punishamount)



rawbehav.choices=[Of1Er_reward
    Of1Er_punish
    Of2Er_reward
    Of2Er_punish
    PDS.chosenwindow]';


bbd.monk.sva{1} =aatradeoff_subjective_value_analysis_v04(rawbehav.choices);
 modan = bbd.monk.sva{1}.model;
 bfit = modan.analysis{2}.behav_full_fit;
 
 
  figuren; eglm_plot_fit(bfit);
  
  
  
  
  
