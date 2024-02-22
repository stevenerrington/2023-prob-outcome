function outstruct = gen_online_beh_multi(PDS)

% Dependencies: gen_PDS_datatable, get_p_array, get_probability_matrix,
% figuren, nsubplot
delay_datatable = gen_PDS_datatable(PDS);

reward_list = [0 -5 5 10];
delay_list = [10 5 -5 0];

[p_array, p_array_label] = get_p_array(reward_list,delay_list,delay_datatable);

[p_attrib_1_chosen, ~, ~, label] = ...
    get_probability_matrix(reward_list, delay_list,delay_datatable);

% [~, p_array_order] = sort(p_array); % Sort low to high
% p_array_order = [2, 6, 14, 10, 3, 7, 15, 11, 1, 5, 13, 9, 4, 8, 16, 12]; % for 4 (delay) x 4 (rwd) design
% 
% p_array = p_array(p_array_order);
% p_array_label = p_array_label(p_array_order);


outstruct.p_array = p_array;
outstruct.p_array_label = p_array_label;
outstruct.p_attrib_1_chosen = p_attrib_1_chosen;
outstruct.label = label;
outstruct.datatable = delay_datatable;



