function renameFile(oldName,newName)
%RENAMEFILE Summary of this function goes here
%   Detailed explanation goes here
[folder,oldName,ext] = fileparts(oldName);
[~,newName,~] = fileparts(newName);
cmd1 = "pushd " + '"' + folder + '"';
cmd2 = "rename " + '"' + oldName + ext + '" "' + newName + ext + '"';
cmd = cmd1 + " & " + cmd2;
system(cmd);
end

