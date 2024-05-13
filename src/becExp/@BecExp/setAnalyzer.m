function setAnalyzer(obj)
obj.Analyzer = addlistener(obj,'NewRunFinished',@(src,event) onChanged(src,event,obj));
obj.Analyzer.Enabled = false;
    function onChanged(~,~,obj)
        obj.IsAcquiring = true;
        obj.NCompletedRun = obj.NCompletedRun + 1;
        if obj.NCompletedRun > obj.NRun
            obj.NRun = obj.NCompletedRun;
        end
        currentRunNumber = obj.NCompletedRun;
        obj.displayLog("Run #" + string(currentRunNumber) + " is acquired.")

        %% Rename images and write TempData if not Auto acquire
        if ~obj.IsAutoAcquire
            pause(0.1)
            [~,dataPath,ext] = fileparts(obj.TempDataPath);
            [~,idx] = sort(str2double(string((regexp(dataPath,'[^\_]*$','match')))));
            ext = ext(idx);
            obj.TempDataPath = obj.TempDataPath(idx);
            nn = num2str(currentRunNumber);
            dataPrefix = fullfile(obj.DataPath,obj.DataPrefix) + "_" + nn;
            newDataPath = [dataPrefix + "_atom" + ext(1);...
                dataPrefix + "_light" + ext(2);...
                dataPrefix + "_dark" + ext(3)];
            arrayfun(@(ii) renameFile(obj.TempDataPath(ii),newDataPath(ii)),[1 2 3]);
            obj.TempData = obj.readRun(currentRunNumber);
        end

        %% Fetch Cicero log data and write into CiceroData
        obj.fetchCiceroLog(currentRunNumber);
        ciceroData = obj.readCiceroLog(currentRunNumber);
        if isempty(obj.CiceroData)
            obj.CiceroData = ciceroData;
        else
            f = fields(obj.CiceroData);
            for ii = 1:numel(f)
                obj.CiceroData.(f{ii}) = [obj.CiceroData.(f{ii}),ciceroData.(f{ii})];
            end
        end

        %% Fetch Hardware log data
        obj.fetchHardwareLog(currentRunNumber);

        %% Update Hardware
        obj.updateHardware

        %% Show Images
        obj.displayLog("Updating the figures.")
        for ii = 1:numel(obj.AnalysisMethod)
            obj.(obj.AnalysisMethod(ii)).update(currentRunNumber)
        end

        obj.IsAcquiring = false;
    end
end
