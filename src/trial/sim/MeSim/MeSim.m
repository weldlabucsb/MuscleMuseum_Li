classdef MeSim < TimeSim
    %SIMULATION Summary of this class goes here
    %   Detailed explanation goes here

    properties(SetAccess = private)
        Atom Atom
        Manifold (1,1) string
        RotatingFrequency (1,1) double
    end

    methods

        function obj = MeSim(trialName,options1,options2)
            arguments
                trialName string
                options1.atom Atom
                options1.rotatingFrequency double
                options1.totalTime double
                options1.timeStep double
                options1.manifold string
                options1.output string
                options2.laser cell
                options2.magneticField cell
                options2.transformation cell
                options2.initialCondition InitialCondition
            end
            obj@TimeSim(trialName,"MeSimConfig");

            %Change parameters if they are manually set
            field1 = string(fieldnames(options1));
            for ii = 1:numel(field1)
                if ~isempty(options1.(field1(ii)))
                    obj.(capitalizeFirst(field1(ii))) = options1.(field1(ii));
                end
            end

            if ~isempty(obj.Output)
                output = rmmissing(["Time";strtrim(split(obj.Output,";"))]);
            else
                error("No output variable specified")
            end
            load("Config.mat","MeSimOutput")
            output = MeSimOutput(ismember(MeSimOutput.VariableName,output),:);
            if ~isempty(output(output.VariableName == "Population",:))
                output(output.VariableName == "Population",:).Size = obj.Atom.(obj.Manifold).NNState;
            end
            obj.Output = output;

            %Initialize parameters for each run
            field2 = string(fieldnames(options2));
            if isempty(field2)
                error("Must specify Initial conditions")
            end
            nPara = cellfun(@numel,struct2cell(options2));
            obj.NRun = max(nPara);
            if any(nPara(nPara~=obj.NRun)>1)
                error("Parameter lengths do not match")
            else
                scannedParaIdx = find(nPara==obj.NRun);
            end
            options0.atom = obj.Atom;
            options0.rotatingFrequency = obj.RotatingFrequency;
            options0.totalTime = obj.TotalTime;
            options0.timeStep = obj.TimeStep;
            options0.manifold = obj.Manifold;
            for ii = 1:obj.NRun
                options = options0;
                for jj = 1:numel(field2)
                    if any(jj == scannedParaIdx)
                        if iscell(options2.(field2(jj)))
                            options.(field2(jj)) = options2.(field2(jj)){ii};
                        else
                            options.(field2(jj)) = options2.(field2(jj))(ii);
                        end
                    else
                        if iscell(options2.(field2(jj))) && ~isempty(options2.(field2(jj)))
                            options.(field2(jj)) = options2.(field2(jj)){1};
                        elseif ~isempty(options2.(field2(jj)))
                            options.(field2(jj)) = options2.(field2(jj));
                        end
                    end
                end
                varargin = struct2pairs(options);
                obj.SimRun(ii) = MeSimRun(obj,varargin{:});
                obj.SimRun(ii).RunIndex = ii;
            end
            obj.update
        end

        function updateDatabase(obj)
            sData = struct(obj);
            tData = struct2table(sData,AsArray=true);
            rf = rowfilter('SerialNumber');
            rf = rf.SerialNumber == obj.SerialNumber;
            pgUpdate(obj.Writer,obj.DatabaseTableName,tData,rf);
        end

        function writeDatabase(obj)
            sData = struct(obj);
            tData = struct2table(sData,AsArray=true);
            pgWrite(obj.Writer,obj.DatabaseTableName,tData);
        end

        function [sp,sigmaNorm] = showCrossSection(obj)
            sigma0 = obj.Atom.CyclerCrossSection;
            Isat = obj.Atom.CyclerSaturationIntensity;
            intensity = zeros(1,obj.NRun);
            sr = zeros(1,obj.NRun);
            for ii = 1:obj.NRun
                intensity(ii) = obj.SimRun(ii).Laser(1).Intensity;
                sr(ii) = loadVar(obj.SimRun(ii).RunPath,"AverageScatteringRate");
            end
            sp = intensity/Isat;
            sigma = Constants.SI('hbar') * 2 * pi * obj.Atom.CyclerFrequency * sr ./ intensity;
            close(figure(2000))
            figure(2000)
            sigmaNorm = sigma/sigma0;
            plot(sp,sigmaNorm,'.')
            xlabel("Saturation parameter",Interpreter="latex")
            ylabel("$\sigma / \sigma_0$",Interpreter="latex")
            render
        end

    end

    methods (Hidden)
        function  setConfigProperty(obj,s)
            %This method compares the properties of the handle object 'obj' with
            %the fields of a structure 'struct'. Then it sets the properties to the
            %values of the fields. The obj must inherit the set method from
            %matlab.mixin.SetGetExactNames
            mc = metaclass(obj); %use metaclass to access non-public properties
            propList = {mc.PropertyList.Name};
            fieldList = fieldnames(s);
            [~,ia,ib] = intersect(propList,fieldList);
            structcell = struct2cell(s);
            set(obj,propList(ia)',structcell(ib)')
        end
    end

end

