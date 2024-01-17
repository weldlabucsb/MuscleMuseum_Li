function deleteFile(fileName)
%DELETEFILE Summary of this function goes here
%   Detailed explanation goes here
if isfile(fileName)
    delete(fileName)
end
end

