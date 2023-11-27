

FileList = dir(fullfile(dirs.data, ['ProbRwdPunish_' date '*' ]));

for file_i = 1:size(FileList,1)
    datafile = fullfile(dirs.data, FileList(file_i).name);
    data{file_i} = load(datafile);
    
end

data_vars = fieldnames(data{1}.PDS);

data_out.PDS = struct();
for var_i = 1:length(data_vars)
    data_out.PDS.(data_vars{var_i}) = [];
    
    if strcmp(data_vars{var_i},'offerInfo')
        for file_i = 1:size(FileList,1)
                data_out.PDS.(data_vars{var_i}){1} = [data_out.PDS.(data_vars{var_i}){1}, data{file_i}.PDS.(data_vars{var_i}){1}];
        end
        
    else
    
    for file_i = 1:size(FileList,1)
        try
            data_out.PDS.(data_vars{var_i}) = [data_out.PDS.(data_vars{var_i}), data{file_i}.PDS.(data_vars{var_i})];
        catch
            data_out.PDS.(data_vars{var_i}) = [data_out.PDS.(data_vars{var_i}); data{file_i}.PDS.(data_vars{var_i})];
        end
    end
    
    end
end