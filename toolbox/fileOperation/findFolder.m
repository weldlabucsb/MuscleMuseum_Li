function folderListing = findFolder(parentPath)
%FINDFOLDER return a list of folders in the parentPath
%   Detailed explanation goes here
listing = dir(parentPath);
folderListing = listing(~ismember({listing.name},{'.','..'})&[listing.isdir]);
end

