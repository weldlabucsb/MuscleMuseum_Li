function index = findFolderIndex(parentPath,prefix,delimiter)
%FINDFOLDERINDEX Summary of this function goes here
%   Detailed explanation goes here
folders = dir(parentPath);
iRealFolder = 0;
for iFolder = 3:numel(folders)
    folderName = folders(iFolder).name;
    folderPath = fullfile(folders(iFolder).folder,folderName);
    if isfolder(folderPath) && contains(folderName,prefix)
        iRealFolder = iRealFolder+1;
        indexPosition = strfind(folderName,delimiter)+1;
        if isempty(indexPosition)
            indexPosition = 1;
        else
            indexPosition = indexPosition(end);
        end
        indexList(iRealFolder) = str2double(folderName(indexPosition:end));
    end
end
if iRealFolder ==0
    index = 1;
else
    index = max(indexList)+1;
end
end

