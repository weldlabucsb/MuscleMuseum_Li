classdef BecExp < Trial
    %BECEXP Summary of this class goes here
    %   Detailed explanation goes here
    properties
        Roi Roi
        SubRoi Roi
        Acquisition Acquisition
        AnalysisMethod string
        CloudCenter double % Cloud center [y_0,x_0] from previous measurement, in pixels
    end

    properties(Hidden)
        IsAutoAcquire logical = false %If we want to automatically set the camera through MATLAB
        IsHoldRefresh logical = false
    end

    properties (Hidden,Transient)
        ExistedCiceroLogNumber %Count the number of log files that are already in the Origin folder.
    end

    properties (SetAccess = private, Hidden)
        CiceroLogOrigin = "."
        CiceroLogPath string
        CiceroLogTime datetime
        DeletedRunParameterList
        ParameterUnitConfig
    end

    properties(SetAccess = private)
        CiceroData struct
        Atom Atom
    end

    properties (Dependent,Hidden)
        ScannedParameterList
        RunListSorted
        ScannedParameterListSorted
        XLabel
    end

    properties (Constant,Hidden)
        AnalysisOrder = {"Od";"Imaging";"Ad";...
            "DensityFit";["AtomNumber";"Tof";"CenterFit";"KapitzaDirac"]}
    end

    methods
        function obj = BecExp(trialName,options)
            %BECEXP Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                trialName string
                options.isLocalTest logical = false
                options.config = struct.empty
            end
            if isempty(options.config)
                if options.isLocalTest
                    config = "BecExpLocalTestConfig";
                else
                    config = "BecExpConfig";
                end
            else
                config = options.config;
            end
            obj@Trial(trialName,config);
            obj.ParameterUnitConfig = loadVar("Config.mat","BecExpParameterUnit");

            % Atom setting
            try
                obj.Atom = Alkali(obj.ConfigParameter.AtomName);
            catch
                obj.Atom = Divalent(obj.ConfigParameter.AtomName);
            end

            % Acquisition settings
            load("Config.mat", "AcquisitionConfig");
            % obj.Acquisition =
            % Acquisition(obj.ConfigParameter.AcquisitionName); %Generalize
            % for different subclasses with different acquisition methods
            AcqMethod=AcquisitionConfig.AcqObjType(AcquisitionConfig.Name==obj.ConfigParameter.AcquisitionName);
            obj.Acquisition=feval(AcqMethod, obj.ConfigParameter.AcquisitionName);
            obj.Acquisition.ImagePath = obj.DataPath;
            obj.Acquisition.ImageFormat = obj.DataFormat;
            obj.Acquisition.ImagePrefix = obj.DataPrefix;
            obj.Roi = Roi(obj.ConfigParameter.RoiName,imageSize = obj.Acquisition.ImageSize);

            % Cloud center
            if ~ismissing(obj.ConfigParameter.CloudCenterReference)
                load("CloudCenterData.mat","CloudCenter")
                if ismember(obj.ConfigParameter.CloudCenterReference,CloudCenter.TrialName)
                    obj.CloudCenter = ...
                        CloudCenter(CloudCenter.TrialName == obj.ConfigParameter.CloudCenterReference,:).Center;
                end
            end

            % Analysis settings
            obj.AnalysisMethod = rmmissing(["Od";"Imaging";"Ad";... 
                strtrim(split(obj.AnalysisMethod,";"))]);
            obj.addAnalysis(obj.AnalysisMethod);
            obj.setAnalyzer;

            % Finalize construction
            obj.update;
            obj.displayLog("Object construction done.")
        end
        
        function paraList = get.ScannedParameterList(obj)
            switch obj.ScannedParameter
                case "RunIndex"
                    paraList = double(1:obj.NCompletedRun);
                case "CiceroLogTime"
                    if ~isempty(obj.CiceroLogTime)
                        paraList = obj.CiceroLogTime;
                        paraList = paraList - paraList(1);
                        paraList = seconds(paraList);
                    else
                        paraList = [];
                    end
                otherwise
                    if ~isempty(obj.CiceroData)
                        paraList = obj.CiceroData.(obj.ScannedParameter);
                    else
                        paraList = [];
                    end
            end
        end

        function runListSorted = get.RunListSorted(obj)
            paraList = obj.ScannedParameterList;
            [~,runListSorted] =  sort(paraList);
        end

        function parameterListSorted = get.ScannedParameterListSorted(obj)
            paraList = obj.ScannedParameterList;
            [parameterListSorted,~] =  sort(paraList);
        end

        function xLabel = get.XLabel(obj)
            sP = obj.ScannedParameter;
            sP = strrep(sP,'_','\_');
            if isempty(obj.ScannedParameterUnit) || ismissing(obj.ScannedParameterUnit) ||...
                    obj.ScannedParameterUnit == ""
                xLabel = sP;
            else
                xLabel = sP + "~[$\mathrm{" + obj.ScannedParameterUnit + "}$]";
            end
        end

        function drp = get.DeletedRunParameterList(obj)
            if isempty(obj.DeletedRunParameterList)
                drp = eval(class(obj.ScannedParameterList)+".empty(0,0)");
                return 
            end
            if all(~ismember(obj.DeletedRunParameterList,obj.ScannedParameterList))
                drp = obj.DeletedRunParameterList;
            else
                drp = obj.DeletedRunParameterList(~ismember(obj.DeletedRunParameterList,obj.ScannedParameterList));
            end
        end
    end

    methods
        setAnalyzer(obj)
        addAnalysis(obj,newAnalysisList)
        removeAnalysis(obj,removeAnalysisList)
        sortAnalysis(obj)
        start(obj)
        pause(obj)
        resume(obj)
        stop(obj)
        fastStop(obj)
        show(obj)
        browserShow(obj)
        refresh(obj,anaylsisName)
        mData = readRun(obj,runIdx)
        roiData = readRunRoi(obj,runIdx)
        deleteRun(obj,runIdx)
        sData = readCiceroLog(obj,runIdx)
        fetchCiceroLog(obj,runIdx)
        writeDatabase(obj)
        updateDatabase(obj)
    end

    methods (Hidden)
        setFolder(obj)
        setConfigProperty(obj,struct)
    end
end

