%% Path
addpath(genpath_exclude(pwd,{'.git','testData','sampleData','.gitignore'}));

%% DataBase

%% Python
setPython;

%% Configuration
setConfig;

%% Color Order
newcolors = slanCL(617,1:80);
set(groot, "defaultaxescolororder", newcolors)

clear
close all

%% genpath from jhopkin
function p = genpath_exclude(d,excludeDirs)
	% if the input is a string, then use it as the searchstr
	if ischar(excludeDirs)
		excludeStr = excludeDirs;
	else
		excludeStr = '';
		if ~iscellstr(excludeDirs)
			error('excludeDirs input must be a cell-array of strings');
		end
		
		for i = 1:length(excludeDirs)
			excludeStr = [excludeStr '|^' excludeDirs{i} '$'];
		end
	end

	
	% Generate path based on given root directory
	files = dir(d);
	if isempty(files)
	  return
	end

	% Add d to the path even if it is empty.
	p = [d pathsep];

	% set logical vector for subdirectory entries in d
	isdir = logical(cat(1,files.isdir));
	%
	% Recursively descend through directories which are neither
	% private nor "class" directories.
	%
	dirs = files(isdir); % select only directory entries from the current listing

	for i=1:length(dirs)
		dirname = dirs(i).name;
		%NOTE: regexp ignores '.', '..', '@.*', and 'private' directories by default. 
		if ~any(regexp(dirname,['^\.$|^\.\.$|^\@.*|^private$|' excludeStr ],'start'))
		  p = [p genpath_exclude(fullfile(d,dirname),excludeStr)]; % recursive calling of this function.
		end
	end
end