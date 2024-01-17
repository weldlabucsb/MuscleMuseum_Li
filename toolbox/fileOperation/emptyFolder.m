function emptyFolder(folderPath)
%EMPTYFOLDER Summary of this function goes here
%   Detailed explanation goes here
if ~isfolder(folderPath)
    return;
end
% Get a list of all files in the folder with the desired file name pattern.
theFiles = dir(folderPath);
for k = 3 : numel(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(folderPath, baseFileName);
    if isfile(fullFileName)
        delete(fullFileName)
    elseif isfolder(fullFileName)
        rmdir(fullFileName,'s')
    end
end
end

