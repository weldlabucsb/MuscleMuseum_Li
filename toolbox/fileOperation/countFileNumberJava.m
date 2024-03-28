function nFile = countFileNumberJava(parentPath,extension)
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

fileList = java.io.File(parentPath);
fileList = string(fileList.list);
[~,~,fExt] = fileparts(fileList);
fileList(fExt=="") = [];
fExt(fExt=="") = [];

if ~isempty(extension)
    fileList(fExt ~= extension) = [];
end

% Count
nFile = numel(fileList);

end

