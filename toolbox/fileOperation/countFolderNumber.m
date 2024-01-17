function nFolder = countFolderNumber(parentPath)
%FINDFOLDERNUMBER This function counts the number of folders in the parentPath
listing = dir(parentPath);
nFolder = nnz(~ismember({listing.name},{'.','..'})&[listing.isdir]);
end

