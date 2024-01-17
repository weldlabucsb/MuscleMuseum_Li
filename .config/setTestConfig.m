% This is a function to set the configuration file for test
function setTestConfig
setConfig;
%% Find the repo path
configPath = findFunctionPath();
[repoPath,~,~] = fileparts(configPath);

%% Set the main data path
mainPath = fullfile(repoPath,'test','testData');

%%
load Config.mat BecExpConfig
BecExpConfig.ParentPath(:) = fullfile("C:\data","becExp");
BecExpConfig.CiceroLogOrigin(:) = fullfile(mainPath,"testLogFiles");
BecExpConfig.IsAutoAcquire(:) = false;
BecExpConfig.IsAutoDelete(:) = false;
save("Config.mat","BecExpConfig",'-mat','-append')
end