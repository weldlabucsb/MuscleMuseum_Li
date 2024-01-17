function newestFolderList = sortNewestFolder(parentPath)
%findNewestFolder sort the folders in the parentPath according the created
%time
%   Detailed explanation goes here
folderListing = findFolder(parentPath);
[~,idx]   = sort([folderListing.datenum]);
newestFolderList = flip(folderListing(idx));
end

