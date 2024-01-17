function isCreated = createFolder(folderPath)
%Check if folder exist and then create folder
if exist(folderPath,'dir')==0
    mkdir(folderPath)
    isCreated = 1;
else
    isCreated = 0;
end
end

