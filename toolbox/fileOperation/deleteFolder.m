function deleteFolder(folderPath)
% Delete folders
if isfolder(folderPath)
    rmdir(folderPath,'s')
end
end

