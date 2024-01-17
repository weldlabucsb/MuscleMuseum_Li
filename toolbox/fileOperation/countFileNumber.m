function nFile = countFileNumber(parentPath,extension)
%COUNTFILENUMBER This function counts the number of files in the parentPath
arguments
    parentPath string
    extension string = string.empty
end

% If parentPath is not a folder, return empty results.
if ~isfolder(parentPath)
    nFile = 0;
    return
end

% Get file list.
if isempty(extension)
    fileList = dir(parentPath);
    fileList = fileList(~[fileList.isdir]);
else
    fileList = dir(fullfile(parentPath,"*"+extension));
end

% Count
nFile = numel(fileList);

end

