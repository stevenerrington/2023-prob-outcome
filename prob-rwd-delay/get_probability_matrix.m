function [p_attrib_1_chosen, sum_attrib_1_chosen, sum_attrib_1_offered] = ...
    get_probability_matrix(reward_list,delay_list,delay_datatable)

count_a = 0;

for reward_i = 1:length(reward_list)
    for delay_i = 1:length(delay_list)
        count_a = count_a + 1;
        count_b = 0;

        label{count_a} = ['Reward: ' int2str(reward_list(reward_i)) ' | Delay: ' int2str(delay_list(delay_i))];

        attrib_1 = [reward_list(reward_i), delay_list(delay_i)];

        for reward_j = 1:length(reward_list)
            for delay_j = 1:length(delay_list)
                count_b = count_b + 1;

                attrib_2 = [reward_list(reward_j), delay_list(delay_j)];

                clear offer1_att* offer2_att*

                offer1_attrib1 = find(delay_datatable.offer1_rwd == attrib_1(1) & delay_datatable.offer1_delay == attrib_1(2) &...
                    delay_datatable.offer2_rwd == attrib_2(1) & delay_datatable.offer2_delay == attrib_2(2));
                offer2_attrib1 = find(delay_datatable.offer2_rwd == attrib_1(1) & delay_datatable.offer2_delay == attrib_1(2) &...
                    delay_datatable.offer1_rwd == attrib_2(1) & delay_datatable.offer1_delay == attrib_2(2));

                offer1_attrib1_chosen = sum(delay_datatable.choice(offer1_attrib1) == 1);
                offer2_attrib1_chosen = sum(delay_datatable.choice(offer2_attrib1) == 2);
                
                p_attrib_1_chosen(count_b,count_a) = (sum([offer1_attrib1_chosen,offer2_attrib1_chosen])./...
                    sum([length(offer1_attrib1),length(offer2_attrib1)]))*100;

                sum_attrib_1_chosen(count_b,count_a) = sum([offer1_attrib1_chosen,offer2_attrib1_chosen]);
                sum_attrib_1_offered(count_b,count_a) = sum([length(offer1_attrib1),length(offer2_attrib1)]);

            end
        end
    end
end

