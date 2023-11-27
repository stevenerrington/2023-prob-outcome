function rwd_punish_values = get_unique_rwdpunish(choice_info)


option_all_unique_punish_amt = unique([choice_info.option1_punish_amt; choice_info.option2_punish_amt]);
option_all_unique_punish_prob = unique([choice_info.option1_punish_prob; choice_info.option2_punish_prob]);
option_all_unique_rwd_amt = unique([choice_info.option1_rwd_amt; choice_info.option2_rwd_amt]);
option_all_unique_rwd_prob = unique([choice_info.option1_rwd_prob; choice_info.option2_rwd_prob]);

% Punishment %%%%%%%%%
% Find the unique expected values
option_1_unique_punish_amt = unique(choice_info.option1_punish_amt);
option_2_unique_punish_amt = unique(choice_info.option2_punish_amt);

option_1_unique_punish_prob = unique(choice_info.option1_punish_prob);
option_2_unique_punish_prob = unique(choice_info.option2_punish_prob);

% Reward %%%%%%%%%
% Find the unique expected values
option_1_unique_rwd_amt = unique(choice_info.option1_rwd_amt);
option_2_unique_rwd_amt = unique(choice_info.option2_rwd_amt);
option_1_unique_rwd_prob = unique(choice_info.option1_rwd_prob);
option_2_unique_rwd_prob = unique(choice_info.option2_rwd_prob);

% Tidy values/remove NaN's
option_1_unique_punish_amt = option_1_unique_punish_amt(~isnan(option_1_unique_punish_amt));
option_2_unique_punish_amt = option_2_unique_punish_amt(~isnan(option_2_unique_punish_amt));
option_1_unique_punish_prob = option_1_unique_punish_prob(~isnan(option_1_unique_punish_prob));
option_2_unique_punish_prob = option_2_unique_punish_prob(~isnan(option_2_unique_punish_prob));

option_1_unique_rwd_amt = option_1_unique_rwd_amt(~isnan(option_1_unique_rwd_amt));
option_2_unique_rwd_amt = option_2_unique_rwd_amt(~isnan(option_2_unique_rwd_amt));
option_1_unique_rwd_prob = option_1_unique_rwd_prob(~isnan(option_1_unique_rwd_prob));
option_2_unique_rwd_prob = option_2_unique_rwd_prob(~isnan(option_2_unique_rwd_prob));

option_all_unique_punish_amt = option_all_unique_punish_amt(~isnan(option_all_unique_punish_amt));
option_all_unique_punish_prob = option_all_unique_punish_prob(~isnan(option_all_unique_punish_prob));
option_all_unique_rwd_amt = option_all_unique_rwd_amt(~isnan(option_all_unique_rwd_amt));
option_all_unique_rwd_prob = option_all_unique_rwd_prob(~isnan(option_all_unique_rwd_prob));

%% Tidy for output
rwd_punish_values.option_1.rwd.amt = option_1_unique_rwd_amt;
rwd_punish_values.option_2.rwd.amt = option_2_unique_rwd_amt;
rwd_punish_values.option_all.rwd.amt = unique([option_1_unique_rwd_amt, option_2_unique_rwd_amt]);

rwd_punish_values.option_1.rwd.prob = option_1_unique_rwd_prob;
rwd_punish_values.option_2.rwd.prob = option_2_unique_rwd_prob;
rwd_punish_values.option_all.rwd.prob = unique([option_1_unique_rwd_prob, option_2_unique_rwd_prob]);

rwd_punish_values.option_1.punish.amt = option_1_unique_punish_amt;
rwd_punish_values.option_2.punish.amt = option_2_unique_punish_amt;
rwd_punish_values.option_all.punish.amt = unique([option_1_unique_punish_amt, option_2_unique_punish_amt]);

rwd_punish_values.option_1.punish.prob = option_1_unique_punish_prob;
rwd_punish_values.option_2.punish.prob = option_2_unique_punish_prob;
rwd_punish_values.option_all.punish.prob = unique([option_1_unique_punish_prob, option_2_unique_punish_prob]);

rwd_punish_values.option_all.rwd.ev = unique(rwd_punish_values.option_all.rwd.amt'.*rwd_punish_values.option_all.rwd.prob);
rwd_punish_values.option_all.punish.ev = unique(rwd_punish_values.option_all.punish.amt'.*rwd_punish_values.option_all.punish.prob);



rwd_punish_values.all.punish.prob = option_all_unique_punish_prob;
rwd_punish_values.all.punish.amt = option_all_unique_punish_amt;
rwd_punish_values.all.rwd.prob = option_all_unique_rwd_prob;
rwd_punish_values.all.rwd.amt = option_all_unique_rwd_amt;

