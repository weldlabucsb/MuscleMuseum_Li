function setPython
disp(newline + "Setting Python...")
%% Find the repo path
repoPath = findFolderInPath("MuscleMuseum");
if numel(repoPath) == 0
    error("MuscleMuseum is not in MATLAB Path.")
elseif numel(repoPath) >= 2
    error("Multiple MuscleMuseum packages are in MATLAB Path. Please resolve.")
end

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
        py.list({'This','is a','list'});
    catch
        warning("Python is not properly installed. Make sure you download Python from python.org, not from" + ...
            " Microsoft Store. Also please check this page:" + newline + ...
            "https://www.mathworks.com/help/matlab/matlab_external/undefined-variable-py-or-function-py-command.html")
        return
    end
    try
        arc = py.importlib.import_module("arc");
        disp("ARC is installed.")
    catch
        warning("ARC is not installed. Please install this Python package from here: " ...
            + newline + "https://arc-alkali-rydberg-calculator.readthedocs.io/en/latest/installation.html")
        return
    end

    atom = arc.AlkaliAtom;

    % Copy ARC data file with updated numbers
    copyfile(fullfile(repoPath,"src","atom","func","lithium7_literature_dme.csv"),...
        fullfile(py2Mat(atom.dataFolder),"lithium7_literature_dme.csv"))
    disp("Done.")
end
end