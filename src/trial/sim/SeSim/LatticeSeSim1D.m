classdef LatticeSeSim1D < SpaceTimeSim
    %SESIM Summary of this class goes here
    %   Detailed explanation goes here

    properties(SetAccess = private)
        Atom Atom
        Manifold (1,1) string
        StateIndex double
        Laser cell
        MagneticField cell
        LatticeModulation cell
        FieldModulation cell
        OpticalLattice OpticalLattice
        MagneticPotential MagneticPotential
        InitialCondition InitialCondition
    end

    properties
        ScannedParameterList
    end

    methods
        function obj = LatticeSeSim1D(trialName,options1,options2)
            arguments
                trialName string
                options1.atom Atom
                options1.manifold string
                options1.stateIndex double
                options1.totalTime double
                options1.timeStep double
                options1.spaceOrigin double = [0;0;0]
                options1.spaceRange double
                options1.spaceStep double
                options1.boundaryCondition string = "Periodic"
                options1.output string
                options2.laser cell
                options2.magneticField cell
                options2.latticeModulation cell
                options2.fieldModulation cell
                options2.initialCondition InitialCondition
            end
            obj@SpaceTimeSim(trialName,"LatticeSeSim1DConfig");

            %% Atom setting
            try
                obj.Atom = Alkali(obj.ConfigParameter.AtomName);
            catch
                obj.Atom = Divalent(obj.ConfigParameter.AtomName);
            end

            %% Change parameters if they are manually set
            field1 = string(fieldnames(options1));
            for ii = 1:numel(field1)
                if ~isempty(options1.(field1(ii)))
                    obj.(capitalizeFirst(field1(ii))) = options1.(field1(ii));
                end
            end
            field2 = string(fieldnames(options2));
            for ii = 1:numel(field2)
                if ~isempty(options2.(field2(ii)))
                    obj.(capitalizeFirst(field2(ii))) = options2.(field2(ii));
                end
            end

            %% Set output parameter
            nSpaceStep = getNSpaceStep(obj.SpaceRange,obj.SpaceStep);
            if ~isempty(obj.Output)
                output = rmmissing(["Time";strtrim(split(obj.Output,";"))]);
            else
                error("No output variable specified")
            end
            load("Config.mat","LatticeSeSim1DOutput")
            output = LatticeSeSim1DOutput(ismember(LatticeSeSim1DOutput.VariableName,output),:);
            if ~isempty(output(output.VariableName == "WaveFunction",:))
                output(output.VariableName == "WaveFunction",:).Size = nSpaceStep;
            end
            obj.Output = output;

            %% Find scanned parameter
            nPara = cellfun(@numel,struct2cell(options2));
            obj.NRun = max(nPara);
            if any(nPara(nPara~=obj.NRun)>1)
                error("Parameter lengths do not match")
            else
                scannedParaIdx = find(nPara==obj.NRun);
                scannedParameterName = string(field2(scannedParaIdx));
                scannedParameterName = scannedParameterName(1);
            end

            %% Construct modulations
            if isempty(obj.LatticeModulation)
                obj.LatticeModulation = {Modulation(...
                    depth = 0, ...
                    duration = 1e-3, ...
                    frequency = 1, ...
                    timing = 0);};
            end
            if isempty(obj.FieldModulation)
                obj.FieldModulation = {Modulation(...
                    depth = 0, ...
                    duration = 1e-3, ...
                    frequency = 1, ...
                    timing = 0);};
            end

            %% Construct OpticalLattice and MagneticPotential
            for ii = 1:obj.NRun
                if ii == 1
                    obj.OpticalLattice(1) = OpticalLattice(obj.Atom,obj.Laser{1},...
                        manifold=obj.Manifold,stateIndex=obj.StateIndex);
                    if ~isempty(obj.MagneticField)
                        obj.MagneticPotential(1) = MagneticPotential(obj.Atom,obj.MagneticField{1},...
                            manifold=obj.Manifold,stateIndex=obj.StateIndex);
                    else
                        obj.MagneticPotential(1) = MagneticPotential(obj.Atom,MagneticField(bias=[0;0;0]),...
                            manifold=obj.Manifold,stateIndex=obj.StateIndex);
                    end
                else
                    if scannedParameterName == "laser"
                        obj.OpticalLattice(ii) = OpticalLattice(obj.Atom,obj.Laser{ii},...
                            manifold=obj.Manifold,stateIndex=obj.StateIndex);
                    elseif scannedParameterName == "magneticField"
                        obj.MagneticPotential(ii) = MagneticPotential(obj.Atom,obj.MagneticField{ii},...
                            manifold=obj.Manifold,stateIndex=obj.StateIndex);
                    end
                end
            end

            %% Set SeSim1DRun parameters
            options.mass = obj.Atom.mass;
            options.totalTime = obj.TotalTime;
            options.timeStep = obj.TimeStep;
            options.spaceOrigin = obj.SpaceOrigin;
            options.spaceRange = obj.SpaceRange;
            options.spaceStep = obj.SpaceStep;
            options.boundaryCondition = obj.BoundaryCondition;

            obj.SimRun = SeSim1DRun.empty;
            for ii = 1:obj.NRun
                varargin = struct2pairs(options);
                obj.SimRun(ii) = SeSim1DRun(obj,varargin{:});
                obj.SimRun(ii).RunIndex = ii;
                if scannedParameterName == "initialCondition" || numel(obj.InitialCondition) == obj.NRun
                    obj.SimRun(ii).InitialCondition = obj.InitialCondition(ii);
                else
                    obj.SimRun(ii).InitialCondition = obj.InitialCondition;
                end
            end

            %% Set the potential function handles
            x = obj.SimRun(1).SpaceList;
            dir = obj.Laser{1}(1).Direction;
            r = dir * x;
            for ii = 1:obj.NRun
                switch scannedParameterName
                    case "laser"
                        lFunc = obj.OpticalLattice(ii).spaceFunc;
                        bFunc = obj.MagneticPotential(1).spaceFuncHighField;
                        lmFunc = {obj.LatticeModulation{1}.timeFunc};
                        fmFunc = {obj.FieldModulation{1}.timeFunc};
                    case "magneticField"
                        lFunc = obj.OpticalLattice(1).spaceFunc;
                        bFunc = obj.MagneticPotential(ii).spaceFuncHighField;
                        lmFunc = {obj.LatticeModulation{1}.timeFunc};
                        fmFunc = {obj.FieldModulation{1}.timeFunc};
                    case "latticeModulation"
                        lFunc = obj.OpticalLattice(1).spaceFunc;
                        bFunc = obj.MagneticPotential(1).spaceFuncHighField;
                        lmFunc = {obj.LatticeModulation{ii}.timeFunc};
                        fmFunc = {obj.FieldModulation{1}.timeFunc};
                    case "fieldModulation"
                        lFunc = obj.OpticalLattice(1).spaceFunc;
                        bFunc = obj.MagneticPotential(1).spaceFuncHighField;
                        lmFunc = {obj.LatticeModulation{1}.timeFunc};
                        fmFunc = {obj.FieldModulation{ii}.timeFunc};
                    case "initialCondition"
                        lFunc = obj.OpticalLattice(1).spaceFunc;
                        bFunc = obj.MagneticPotential(1).spaceFuncHighField;
                        lmFunc = {obj.LatticeModulation{1}.timeFunc};
                        fmFunc = {obj.FieldModulation{1}.timeFunc};
                end
                Vl = lFunc(r).';
                Vb = bFunc(r).';
                Vb = Vb - max(Vb);
                lmFuncSum = @(x) sum(cellfun(@(F) F(x),lmFunc));
                fmFuncSum = @(x) sum(cellfun(@(F) F(x),fmFunc));
                obj.SimRun(ii).Potential = @(t) (1+lmFuncSum(t)) * Vl + (1+fmFuncSum(t)) * Vb;
            end
            obj.update
        end

        function plotBand(obj,runIdx,bandNumber)
            psicj = obj.SimRun(runIdx).readRun("WaveFunction");
            x = obj.SimRun(1).SpaceList;
            t = obj.SimRun(1).TimeListAvg * 1e3;
            pop = obj.OpticalLattice.computeBandPopulation1D(psicj,max(bandNumber),x);
            bandNumber = bandNumber + 1;
            pop = pop(:,bandNumber);
            figure(2943)
            plot(t,pop)
            render
        end

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

        function updateDatabase(obj)
            sData = struct(obj);
            sData.SpaceOrigin = sData.SpaceOrigin.';
            sData.SpaceStep = sData.SpaceStep.';
            sData.SpaceRange = sData.SpaceRange.';
            tData = struct2table(sData,AsArray=true);
            rf = rowfilter('SerialNumber');
            rf = rf.SerialNumber == obj.SerialNumber;
            pgUpdate(obj.Writer,obj.DatabaseTableName,tData,rf);
        end

        function writeDatabase(obj)
            sData = struct(obj);
            sData = rmfield(sData,{'SimRun'});
            sData.SpaceOrigin = sData.SpaceOrigin.';
            sData.SpaceStep = sData.SpaceStep.';
            sData.SpaceRange = sData.SpaceRange.';
            tData = struct2table(sData,AsArray=true);
            pgWrite(obj.Writer,obj.DatabaseTableName,tData);
        end

    end


end

