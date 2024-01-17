classdef BecExp < Trial
    %BECEXP Summary of this class goes here
    %   Detailed explanation goes here
    properties
        Roi Roi
        Acquisition Acquisition
        AnalysisMethod string
    end

    properties(Hidden)
        IsAutoAcquire logical = false %If we want to automatically set the camera through MATLAB
        IsHoldRefresh logical = false
    end

    properties (Hidden,Transient)
        ExistedCiceroLogNumber %Count the number of log files that are already in the Origin folder.
    end

    properties (SetAccess = private, Hidden)
        CiceroLogOrigin {mustBeFolder} = "."
        CiceroLogPath string
        CiceroLogTime datetime
        DeletedRunParameterList
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

    methods
        function obj = BecExp(trialName,options)
            %BECEXP Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                trialName string
                options.isLocalTest logical = false
            end
            if options.isLocalTest
                becExpConfigName = "BecExpLocalTestConfig";
            else
                becExpConfigName = "BecExpConfig";
            end
            obj@Trial(trialName,becExpConfigName);

            % Atom setting
            try
                obj.Atom = Alkali(obj.ConfigParameter.AtomName);
            catch
                obj.Atom = Divalent(obj.ConfigParameter.AtomName);
            end

            % Acquisition settings
            obj.Acquisition = Acquisition(obj.ConfigParameter.AcquisitionName);
            obj.Acquisition.ImagePath = obj.DataPath;
            obj.Acquisition.ImageFormat = obj.DataFormat;
            obj.Acquisition.ImagePrefix = obj.DataPrefix;
            obj.Roi = Roi(obj.ConfigParameter.RoiName,imageSize = obj.Acquisition.ImageSize);

            % Analysis settings
            obj.AnalysisMethod = rmmissing(["Od";"Imaging";"Ad";... %Od and Imaging as default analyses
                strtrim(split(obj.AnalysisMethod,";"))]);
            obj.AnalysisMethod = obj.AnalysisMethod';
            obj.setAnalyzer;

            analysisMethod = obj.AnalysisMethod;
            for ii = 1:numel(analysisMethod)
                addprop(obj,analysisMethod(ii));
                obj.(analysisMethod(ii)) = eval(analysisMethod(ii) + "(obj)");
            end
            obj.Od.CLim = [0,obj.ConfigParameter.OdCLim];
            obj.Od.Colormap = obj.ConfigParameter.OdColormap;
            obj.Od.FringeRemovalMask = obj.ConfigParameter.FringeRemovalMask;
            obj.Od.FringeRemovalMethod = obj.ConfigParameter.FringeRemovalMethod;
            obj.Imaging.ImagingStage = obj.ConfigParameter.ImagingStage;
            obj.Ad.AdMethod = obj.ConfigParameter.AdMethod;

            obj.update;
            obj.displayLog("Object construction done.")
        end
        
        function paraList = get.ScannedParameterList(obj)
            switch obj.ScannedParameter
                case "RunIndex"
                    paraList = 1:obj.NCompletedRun;
                case "CiceroLogTime"
                    if ~isempty(obj.CiceroLogTime)
                        paraList = obj.CiceroLogTime;
                    else
                        paraList = datetime.empty;
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
            if isempty(obj.ScannedParameterUnit) || ismissing(obj.ScannedParameterUnit)
                xLabel = obj.ScannedParameter;
            else
                xLabel = obj.ScannedParameter + "~[$\mathrm{" + obj.ScannedParameterUnit + "}$]";
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
        start(obj)
        pause(obj)
        resume(obj)
        stop(obj)
        show(obj)
        refresh(obj)
        mData = readRun(obj,runIdx)
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

