function dirs = get_dirs_probrwdpunish(user)

switch user
    case 'wustl'
        dirs.root = 'C:\Users\Steven\Documents\GitHub\2023-probrwdpunish';
        dirs.toolbox = 'C:\Users\Steven\Documents\GitHub\toolbox\';

    case 'mac'
        dirs.root = '/Users/stevenerrington/Desktop/Projects/2023-probrwdpunish';
        dirs.toolbox = '/Users/stevenerrington/Desktop/Projects/toolbox';        
end

addpath(genpath(dirs.root));
addpath(genpath(dirs.toolbox));

end

