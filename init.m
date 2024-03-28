%% Set Path
disp(newline + "Setting path...")
addpath(genpath_exclude(pwd,{'.git','testData','sampleData','.gitignore'}));
disp("Done.")

%% Check MATLAB version
disp(newline + "Checking MATLAB version...")
vers = version('-release');
if string(vers) == "2023b" || str2double(vers(1:4))>2023
    warning(['MuscleMuseum is only compatible with MATLAB 2023a or earlier versions. ' ...
        'Newer MATLAB releases may break the database functions of this package.'])
else
    disp("MATLAB version [" + string(vers) + "] is good.")
end

%% Check MATLAB packages
disp(newline + "Checking MATLAB packages...")
packageList = getPackageList;
requiredPackageList = ["Data Acquisition Toolbox","Curve Fitting Toolbox","Parallel Computing Toolbox"];
missedPackageList = requiredPackageList(~ismember(requiredPackageList,packageList));
if ~isempty(missedPackageList)
    warning("Packages " + strjoin("["+ missedPackageList + "]",", ") + " are missing. Please " + ...
        "install those packages.")
else
    disp("Required MATLAB packages are installed.")
end

%% Set Python
setPython;

%% Set Configuration
setConfig;

%% Set DataBase
setDatabase;

%% Set Color Order
disp(newline + "Setting color order...")
newcolors = slanCL(617,1:80);
set(groot, "defaultaxescolororder", newcolors)
disp("Done.")

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