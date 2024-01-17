function [latestFilePath,time] = findLatestFile(parentPath,extension)
%FINDLATESTFILE Summary of this function goes here
%   Detailed explanation goes here
arguments
    parentPath string
    extension string = string.empty
end

% If parentPath is not a folder, return empty results.
if ~isfolder(parentPath)
    latestFilePath = string.empty;
    time = datetime.empty; 
    return
end

% Get file list.
if isempty(extension)
    fileList = dir(parentPath);
    fileList = fileList(~[fileList.isdir]);
else
    fileList = dir(fullfile(parentPath,"*"+extension));
end

% Find the latest file
[~,idx] = max([fileList(:).datenum]);
if ~isempty(idx)
    latestFilePath = fullfile(parentPath,fileList(idx).name);
    time = datetime(fileList(idx).datenum,'ConvertFrom','datenum');
else
    latestFilePath = string.empty;
    time = datetime.empty; 
end

end

