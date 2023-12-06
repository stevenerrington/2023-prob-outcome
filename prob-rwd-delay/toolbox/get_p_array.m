function [p_array, label] = get_p_array(reward_list,delay_list,delay_datatable)
count = 0;

p_array = [];
label = {};

for delay_i = 1:length(delay_list)
    for reward_i = 1:length(reward_list)
        count = count + 1;

         label{count} = ['Reward: ' int2str(reward_list(reward_i)) ' | Delay: ' int2str(delay_list(delay_i))];


        % Find trials with options that meet the current loop criteria (rwd
        % and delay magnitude)
        trial_index = []; trial_index = ...
            find((delay_datatable.offer1_rwd == reward_list(reward_i) & delay_datatable.offer1_delay == delay_list(delay_i)) |...
            (delay_datatable.offer2_rwd == reward_list(reward_i) & delay_datatable.offer2_delay == delay_list(delay_i)));

        % Find the probability that the option with the loop attributes was
        % selected
        p_array(count) = ...
            mean(delay_datatable.chosen_rwd(trial_index) == reward_list(reward_i) &...
            delay_datatable.chosen_delay(trial_index)  == delay_list(delay_i));


    end
end