function setPython
%% Find the repo path
configPath = findFunctionPath();
[repoPath,~,~] = fileparts(configPath);
homePath = getHome;

%% Set python search path
setenv("PYTHONPATH",fullfile(repoPath,"toolbox","py"));

%% Copy ARC data file
copyfile(fullfile(repoPath,"toolbox","py","lithium7_literature_dme.csv"),...
    fullfile(homePath,".arc-data","lithium7_literature_dme.csv"))
end