classdef AtomNumber < BecAnalysis
    %OD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
       Raw
       Thermal
       Condensate
    end

    properties (Dependent)
        Total
    end

    properties (Constant)
        Unit = 10^6;
    end

    properties (SetObservable)
        YLim = [0,30];
    end

    properties (Hidden,Transient)
        RawLine matlab.graphics.primitive.Line
        ThermalLine matlab.graphics.primitive.Line
        CondensateLine matlab.graphics.primitive.Line
        TotalLine matlab.graphics.primitive.Line
    end
    
    methods
        function obj = AtomNumber(becExp)
            %OD Construct an instance of this class
            %   Detailed explanation goes here
            obj@BecAnalysis(becExp)
            obj.Chart(1) = Chart(...
                name = "Atom number",...
                num = 29, ...
                fpath = fullfile(becExp.DataAnalysisPath,"AtomNumber"),...
                loc = "northeast",...
                size = [0.3069,0.3995]...
                );
        end
        
        function initialize(obj)
            becExp = obj.BecExp;
            fig = obj.Chart(1).initialize;
            nSub = becExp.Roi.NSub;
            nSub(nSub == 0) = 1;

            %% Initialize data
            obj.Raw = zeros(1,1,nSub);
            obj.Thermal = zeros(1,1,nSub);
            obj.Condensate = zeros(1,1,nSub);

            %% Initialize figures
            if ~ishandle(fig)
                return
            end

            % Listener for plot y limit
            addlistener(obj,'YLim','PostSet',@obj.handlePropEvents);

            % Initialize axis
            ax = gca;
            ax.Box = "on";
            ax.XGrid = "on";
            ax.YGrid = "on";
            ax.XLabel.String = obj.BecExp.XLabel;
            ax.XLabel.Interpreter = "latex";
            ax.YLabel.String = "${N}_{\mathrm{atom}}~[\times 10^{" + string(log(obj.Unit)/log(10)) + "}]$";
            ax.YLabel.Interpreter = "latex";
            ax.FontSize = 12;
            ax.YLim = obj.YLim;
            co = ax.ColorOrder;
            mOrder = markerOrder();

            % Initialize raw plots
            for ii = 1:nSub
                obj.RawLine(ii) = line(ax,1,1);
                obj.RawLine(ii).Marker = mOrder(ii);
                obj.RawLine(ii).MarkerFaceColor = co(1,:);
                obj.RawLine(ii).MarkerEdgeColor = co(1,:)*.5;
                obj.RawLine(ii).MarkerSize = 8;
                obj.RawLine(ii).LineWidth = 2;
                obj.RawLine(ii).Color = co(1,:);
            end
            legendStrRaw = arrayfun(@(x) "Raw " + x,1:nSub);
            
            % Initialize thermal and condensate plots
            if ismember("DensityFit",becExp.AnalysisMethod)
                hold(ax,'on')
                switch becExp.DensityFit.FitMethod
                    case {"GaussianFit1D","BosonicGaussianFit1D"}
                        for ii = 1:nSub
                            obj.ThermalLine(ii) = line(ax,1,1);
                            obj.ThermalLine(ii).Marker = mOrder(ii);
                            obj.ThermalLine(ii).MarkerFaceColor = co(2,:);
                            obj.ThermalLine(ii).MarkerEdgeColor = co(2,:)*.5;
                            obj.ThermalLine(ii).MarkerSize = 8;
                            obj.ThermalLine(ii).LineWidth = 2;
                            obj.ThermalLine(ii).Color = co(2,:);    
                        end
                        if isempty(becExp.Roi.SubRoi)
                            legendStr = ["Raw","Thermal"];
                        else
                            legendStrThermal = arrayfun(@(x) "Thermal " + x,1:nSub);
                            legendStr = [legendStrRaw,legendStrThermal];
                        end
                        lg = legend(ax,legendStr(:));
                end
                hold(ax,'off')
            else
                lg = legend(ax,"Raw");
            end
            
            if numel(lg.String) >= 8
                lg.NumColumns = 2;
                lg.FontSize = 8;
                lg.Location = "best";
            end

        end

        function updateData(obj,runIdx)
            becExp = obj.BecExp;
            nSub = becExp.Roi.NSub;
            nSub(nSub == 0) = 1;
            px = becExp.Acquisition.PixelSizeReal;

            %% Update Raw data
            if isempty(becExp.Roi.SubRoi)
                obj.Raw(runIdx) = sum(becExp.Ad.AdData(:,:,runIdx),"all") * px^2;
            else
                subData = becExp.Roi.selectSub(becExp.Ad.AdData(:,:,runIdx));
                for ii = 1:nSub
                    obj.Raw(1,runIdx,ii) = sum(subData{ii},"all") * px^2;
                end
            end

            %% Update thermal and condensate data
            if ismember("DensityFit",obj.BecExp.AnalysisMethod)
                for ii = 1:nSub
                    switch obj.BecExp.DensityFit.FitMethod
                        case "GaussianFit1D"
                            obj.Thermal(1,runIdx,ii) = 2 * pi * prod(becExp.DensityFit.ThermalCloudSize(:,runIdx,ii)) * ...
                                becExp.DensityFit.ThermalCloudCentralDensity(1,runIdx,ii);
                        case "BosonicGaussianFit1D"
                            obj.Thermal(1,runIdx,ii) = pi * prod(becExp.DensityFit.ThermalCloudSize(:,runIdx,ii)) * ...
                                becExp.DensityFit.ThermalCloudCentralDensity(1,runIdx,ii) * ...
                                boseFunction(1,3) / boseFunction(1,2);
                    end
                end
            end
        end

        function updateFigure(obj,~)
            if ishandle(obj.Chart(1).Figure)
                fig = figure(obj.Chart(1).Figure);
            else
                return
            end

            %% Parameters. Use sorted list for plotting
            becExp = obj.BecExp;
            nSub = becExp.Roi.NSub;
            nSub(nSub == 0) = 1;
            paraListSorted = becExp.ScannedParameterListSorted;
            runListSorted = becExp.RunListSorted;

            %% Update raw plots
            for ii = 1:nSub
                obj.RawLine(ii).XData = paraListSorted;
                obj.RawLine(ii).YData = obj.Raw(1,runListSorted,ii) / obj.Unit;
            end

            %% Update thermal and condensate plots
            if ismember("DensityFit",becExp.AnalysisMethod)
                for ii = 1:nSub
                    switch becExp.DensityFit.FitMethod
                        case {"GaussianFit1D","BosonicGaussianFit1D"}
                            obj.ThermalLine(ii).XData = paraListSorted;
                            obj.ThermalLine(ii).YData = obj.Thermal(1,runListSorted,ii) / obj.Unit;
                    end
                end
            end
            
            %% Update lengend position
            lg = findobj(fig,"Type","Legend");
            lg.Location = "best";
        end
        
        function val = get.Total(obj)
            val = obj.Thermal + obj.Condensate;
        end
    end

    methods (Static)
        function handlePropEvents(src,evnt)
            switch src.Name
                case 'YLim'
                    obj = evnt.AffectedObject;
                    for ii = 1:numel(obj.Chart)
                        if ishandle(obj.Chart(ii).Figure)
                            fig = obj.Chart(ii).Figure;
                            ax = fig.CurrentAxes;
                            ax.YLim = obj.YLim;
                        end
                    end
            end
        end
    end
end

