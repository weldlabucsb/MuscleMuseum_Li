function setPython
disp(newline + "Setting Python...")
%% Find the repo path
configPath = findFunctionPath();
[repoPath,~,~] = fileparts(configPath);
homePath = getHome;

%% Set python search path
setenv("PYTHONPATH",fullfile(repoPath,"toolbox","py"));

%% Check if Python is installed
pe = pyenv;
if isempty(pe.Version)
    warning("Python is not installed. Please install Python that is compatible with your MATLAB version: "...
        + newline + "https://www.mathworks.com/support/requirements/python-compatibility.html" ...
        + newline + "https://www.python.org/downloads/" ...
        + newline + "Please make sure Python can be called from your system prompt.")
    return
else
    disp("Python version: " + pe.Version)
    try
        arc = py.importlib.import_module("arc");
    catch
        warning("ARC is not installed. Please install this Python package from here: " ...
            + newline + "https://arc-alkali-rydberg-calculator.readthedocs.io/en/latest/installation.html")
        return
    end
    disp("ARC is installed.")
    arc.("Lithium7");

    % Copy ARC data file
    copyfile(fullfile(repoPath,"toolbox","py","lithium7_literature_dme.csv"),...
        fullfile(homePath,".arc-data","lithium7_literature_dme.csv"))
    disp("Done.")
end
end