function folderFullPath = findFolderInPath(folderName)
p = string(strsplit(path,';'));
m = regexp(p,".*"+string(folderName)+"$");
folderFullPath = p(~cellfun(@isempty,m));
end

