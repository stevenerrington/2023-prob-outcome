function dirs = get_dirs_probrwdpunish(user)

switch user
    case 'wustl'
        dirs.root = 'C:\Users\Steven\Documents\GitHub\2023-probrwdpunish';
        dirs.toolbox = 'C:\Users\Steven\Documents\GitHub\toolbox\';
        dirs.data = 'Y:\MONKEYDATA\Slayer2\ProbRwdPunish';

    case 'mac'
        dirs.root = '/Users/stevenerrington/Desktop/Projects/2023-probrwdpunish';
        dirs.toolbox = '/Users/stevenerrington/Desktop/Projects/toolbox';        
        dirs.toolbox = '/Users/stevenerrington/Box Sync/Research/2023-probrwdpunish/data';    
        
    case 'home'
        dirs.root = 'D:\projects\2023-probrwdpunish';
        dirs.toolbox = 'C:\toolbox';
        dirs.data = 'Y:\MONKEYDATA\Slayer2\ProbRwdPunish';
end

addpath(genpath(dirs.root));
addpath(genpath(dirs.toolbox));

end

