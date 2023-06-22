function rwd_punish_values = get_unique_rwdpunish(option_info)

% Punishment %%%%%%%%%
% Find the unique expected values
option_1_unique_punish_amt = unique(option_info.option1_punish_amt);
option_2_unique_punish_amt = unique(option_info.option2_punish_amt);

option_1_unique_punish_prob = unique(option_info.option1_punish_prob);
option_2_unique_punish_prob = unique(option_info.option2_punish_prob);

% Reward %%%%%%%%%
% Find the unique expected values
option_1_unique_rwd_amt = unique(option_info.option1_rwd_amt);
option_2_unique_rwd_amt = unique(option_info.option2_rwd_amt);
option_1_unique_rwd_prob = unique(option_info.option1_rwd_prob);
option_2_unique_rwd_prob = unique(option_info.option2_rwd_prob);

% Tidy values/remove NaN's
option_1_unique_punish_amt = option_1_unique_punish_amt(~isnan(option_1_unique_punish_amt));
option_2_unique_punish_amt = option_2_unique_punish_amt(~isnan(option_2_unique_punish_amt));
option_1_unique_punish_prob = option_1_unique_punish_prob(~isnan(option_1_unique_punish_prob));
option_2_unique_punish_prob = option_2_unique_punish_prob(~isnan(option_2_unique_punish_prob));

option_1_unique_rwd_amt = option_1_unique_rwd_amt(~isnan(option_1_unique_rwd_amt));
option_2_unique_rwd_amt = option_2_unique_rwd_amt(~isnan(option_2_unique_rwd_amt));
option_1_unique_rwd_prob = option_1_unique_rwd_prob(~isnan(option_1_unique_rwd_prob));
option_2_unique_rwd_prob = option_2_unique_rwd_prob(~isnan(option_2_unique_rwd_prob));

%% Tidy for output
rwd_punish_values.option_1.rwd.amt = option_1_unique_rwd_amt;
rwd_punish_values.option_2.rwd.amt = option_2_unique_rwd_amt;

rwd_punish_values.option_1.rwd.prob = option_1_unique_rwd_prob;
rwd_punish_values.option_2.rwd.prob = option_2_unique_rwd_prob;

rwd_punish_values.option_1.punish.amt = option_1_unique_punish_amt;
rwd_punish_values.option_2.punish.amt = option_2_unique_punish_amt;

rwd_punish_values.option_1.punish.prob = option_1_unique_punish_prob;
rwd_punish_values.option_2.punish.prob = option_2_unique_punish_prob;
