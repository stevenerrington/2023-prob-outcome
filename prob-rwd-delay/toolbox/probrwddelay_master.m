clear all; clc

monkey = 'Zepp'; % 'Zepp" or 'Slayer'

% Define file directory
mat_dir = ['/Users/stevenerrington/Desktop/ProbRwdDelay Data/' monkey '/'];
mat_files = dir_mat_files(mat_dir);

% Restructure data across multiple 
data_table = [];

for file_i = 1:length(mat_files)
    load(fullfile(mat_dir,mat_files{file_i}))
    clear outstruct; c;
    outstruct = gen_online_beh_multi(PDS);

    data_table = [data_table; outstruct.datatable];
    p_array(file_i,:) = outstruct.p_array;
    p_attrib_1_chosen(file_i,:,:) = outstruct.p_attrib_1_chosen;
end

%% Probability plots
plot_probrwddelay_prob (outstruct, p_array, p_attrib_1_chosen)

%% GLM
% Run GLM
glm_out = probrwddelay_glm(data_table, 'conceptual');

% Plot GLM weights
figuren;
eglm_plot_fit(glm_out)
%plot_probrwddelay_glm_raw(glm_out)
%plot_probrwddelay_glm_raw_uncorr(glm_out)
