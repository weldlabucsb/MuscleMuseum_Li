classdef MeSimRun < TimeSimRun
    %MESIMRUN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Atom Atom
        Laser Laser
        MagneticField MagneticField
        % LargeGHFS logical = false
        % IsMoving logical = false
        % IsDragged logical = false
        RotatingFrequency double = 0
        Manifold string
        StateList table
        Transformation double = 1
    end

    properties(SetAccess=protected)
        Hamiltonian
        Lindbladian
    end
    
    methods
        function obj = MeSimRun(meSim,options)
            %MESIMRUN Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                meSim MeSim = MeSim.empty
                options.atom Atom
                options.rotatingFrequency double
                options.totalTime double
                options.timeStep double
                options.manifold string
                options.laser Laser
                options.magneticField MagneticField
                options.transformation double = 1
                options.initialCondition InitialCondition
            end
            obj@TimeSimRun(meSim)
            field = string(fieldnames(options));
            for ii = 1:numel(field)
                if ~isempty(options.(field(ii)))
                    obj.(capitalizeFirst(field(ii))) = options.(field(ii));
                end
            end

            % Transformation
            obj.StateList = obj.Atom.(obj.Manifold).StateList;
            if isscalar(obj.Transformation)
                if ~isempty(obj.MagneticField)
                    bias = obj.MagneticField(1).Bias;
                    if bias(1) == 0 && bias(2) ==0 && bias(3) > 0 %check if quantization axis is aligned with the bias magnetic field
                        [obj.StateList,obj.Transformation] = obj.Atom.(obj.Manifold).BiasDressedStateList(obj.MagneticField(1));
                    else
                        error("Bias field is not aligned with the quantization axis")
                    end
                end
            end

            % Hamiltonian
            if ~isempty(obj.MagneticField)
                HamBias = obj.Atom.(obj.Manifold).HamiltonianAtomBiasField(obj.MagneticField(1),obj.Transformation);
            end
            Ha = obj.Atom.(obj.Manifold).HamiltonianAtom(obj.RotatingFrequency,obj.Transformation);
            if ~isempty(obj.Laser)
                HalList = cell(1,numel(obj.Laser));
                for ii = 1:numel(obj.Laser)
                    HalList{ii} = obj.Atom.(obj.Manifold).HamiltonianAtomLaser(obj.Laser(ii),obj.RotatingFrequency,obj.Transformation);
                end
            else
                HalList = {@(r,t) 0};
            end
            function out = H(r,t)
                out = Ha + HamBias;
                for jj = 1:numel(HalList)
                    out = out + HalList{jj}(r,t);
                end
            end
            obj.Hamiltonian = @(r,t) H(r,t);

            % Lindbladian
            Sigma = arrayfun(@(q) obj.Atom.(obj.Manifold).LoweringOperator(q,obj.Transformation),[1,0,-1]',UniformOutput=false);
            nState = obj.Atom.(obj.Manifold).NNState;
            function out = L(rho)
                out = sparse(nState,nState);
                for qq = 1:3
                    out = out + Sigma{qq}*rho*Sigma{qq}'-1/2*(Sigma{qq}'*Sigma{qq}*rho+rho*(Sigma{qq}'*Sigma{qq}));
                end
            end
            obj.Lindbladian = @(rho) L(rho);
        end

        function start(obj)
            tList = obj.TimeList;
            nt = obj.NTimeStep;
            dt = obj.TimeStep;
            rho = obj.InitialCondition.DensityMatrix;
            r = obj.InitialCondition.Position;
            v = obj.InitialCondition.Velocity;
            H = obj.Hamiltonian;
            L = obj.Lindbladian;
            gamma = obj.Atom.(obj.Manifold).NaturalLinewidth *...
                (2*obj.Atom.(obj.Manifold).JExcited+1) / ...
                (2*obj.Atom.(obj.Manifold).JGround+1);
            a0 = 2/3; %RK parameter
            
            srO = obj.StateList.IsExcited;
            srO = 2 * pi * obj.Atom.(obj.Manifold).NaturalLinewidth * double(diag(srO));

            savePeriod = obj.SavePeriod;
            avePeriod = obj.AveragePeriod;
            nDataRowMemory = obj.NDataRowMemory;

            outputVarSize = obj.Output.Size;
            outputVarName = obj.Output.VariableName;
            runtimeName = obj.Output.RuntimeName;
            nDataColumn = sum(outputVarSize);
            dataColumnStartIdx = 1 + [0;cumsum(outputVarSize(1:end-1))];
            dataColumnStopIdx = cumsum(outputVarSize);
            tempExpr = "temp = temp + [" + strjoin(runtimeName,",") + "];";
            temp = zeros(1,nDataColumn);
            data = zeros(floor(savePeriod/avePeriod),nDataColumn);
            for ii = 1:numel(outputVarName)
                expr = outputVarName(ii) + "=double.empty(0,"+num2str(outputVarSize(ii))+");";
                eval(expr)
            end
            save(obj.RunPath,obj.Output.VariableName{:},"-v7.3")
            matObj = matfile(obj.RunPath,'Writable',true);

            for tt = 1:nt
                %Time evolution
                t = tList(tt);
                H1 = H(r,t);
                H2 = H(r,t+a0*dt);
                rhod1 = -1i*2*pi*(H1*rho-rho*H1) + 2*pi*gamma*L(rho);
                dnrho = rho + a0*dt*rhod1;
                rhod2 = -1i*2*pi*(H2*dnrho-dnrho*H2) + 2*pi*gamma*L(dnrho);
                rho = rho +(1-1/(2*a0))*dt*rhod1+1/2/a0*dt*rhod2;
                rho = (rho + rho')/2;
                rho = rho./trace(rho);
                
                %Output
                pop = (abs(diag(rho)))';
                sr = abs(trace(srO*rho));

                if mod(tt,savePeriod) == 0
                    eval(tempExpr);
                    data(nDataRowMemory,:)=temp/avePeriod;
                    s = floor(tt/avePeriod/nDataRowMemory);
                    for ii = 1:numel(outputVarName)
                        matObj.(char(outputVarName(ii)))((s-1)*nDataRowMemory+1:s*nDataRowMemory,:) = ...
                            data(:,dataColumnStartIdx(ii):dataColumnStopIdx(ii));
                    end
                        temp = zeros(1,nDataColumn);
                elseif tt == (nt - mod(nt,avePeriod))
                    eval(tempExpr);
                    if mod(tt,savePeriod) == 0
                        rowIdx = floor(savePeriod/avePeriod);
                    else
                        rowIdx = floor(mod(tt,savePeriod)/avePeriod);
                    end
                    data(rowIdx,:) = temp/avePeriod;
                    data(rowIdx+1:end,:) = [];
                    if mod(tt,savePeriod) == 0
                        s = floor(tt/avePeriod/nDataRowMemory);
                    else
                        s = floor(tt/avePeriod/nDataRowMemory) + 1;
                    end
                    for ii = 1:numel(outputVarName)
                        matObj.(char(outputVarName(ii)))((s-1)*nDataRowMemory+1:(s-1)*nDataRowMemory + size(data,1),:) =...
                            data(:,dataColumnStartIdx(ii):dataColumnStopIdx(ii));
                    end
                        temp = zeros(1,nDataColumn);
                elseif mod(tt,avePeriod) == 0
                    eval(tempExpr);
                    data(floor(mod(tt,savePeriod)/avePeriod),:) = temp/avePeriod;
                    temp = zeros(1,nDataColumn);
                else
                    eval(tempExpr);
                end
            end
            FinalDensityMatrix = rho;
            save(obj.RunPath,"FinalDensityMatrix",'-append')
            obj.finalize
        end

        function finalize(obj)
            output= obj.Output;
            matObj = matfile(obj.RunPath,'Writable',true);
            [nRow,~] = size(matObj,'Time');
            if any(output.VariableName == "Population")
                FinalPopulation = matObj.Population(nRow,:);
                [~,nColumn] = size(matObj,'Population');
                AveragePopulation = zeros(1,nColumn);
                for ii = 1:nColumn
                    AveragePopulation(ii) = mean(matObj.Population(:,ii));
                end
                save(obj.RunPath,"FinalPopulation","AveragePopulation",'-append')
            end
            if any(output.VariableName == "ScatteringRate")
                FinalScatteringRate = matObj.ScatteringRate(nRow,:);
                AverageScatteringRate = mean(matObj.ScatteringRate(:,:));
                save(obj.RunPath,"FinalScatteringRate","AverageScatteringRate",'-append')
            end
        end

        function showPopulation(obj,stateIndex)
            try
                load(obj.RunPath,"Population","Time")
            catch
                error("Population was not saved")
            end
            stateList = obj.StateList;
            Population = Population(:,stateIndex);
            label = {stateList.Label(stateIndex)};
            close(figure(1000))
            figure(1000)
            plot(Time * 1e6,Population)
            xlabel("Time in [$\mu \mathrm{s}$]",Interpreter="latex")
            ylabel("Population",Interpreter="latex")
            legend(label{:})
            render
        end
        function showPopulationGround(obj)
            try
                load(obj.RunPath,"Population","Time")
            catch
                error("Population was not saved")
            end
            stateList = obj.StateList;
            stateIndex = ~stateList.IsExcited;
            Population = Population(:,stateIndex);
            label = {stateList.Label(stateIndex)};
            close(figure(1001))
            figure(1001)
            plot(Time * 1e6,Population)
            xlabel("Time in [$\mu \mathrm{s}$]",Interpreter="latex")
            ylabel("Population",Interpreter="latex")
            legend(label{:})
            render
        end
        function showPopulationExcited(obj)
            try
                load(obj.RunPath,"Population","Time")
            catch
                error("Population was not saved")
            end
            stateList = obj.StateList;
            stateIndex = stateList.IsExcited;
            Population = Population(:,stateIndex);
            label = {stateList.Label(stateIndex)};
            close(figure(1002))
            figure(1002)
            plot(Time * 1e6,Population)
            xlabel("Time in [$\mu \mathrm{s}$]",Interpreter="latex")
            ylabel("Population",Interpreter="latex")
            legend(label{:})
            render
        end
        function showScatteringRate(obj)
            try
                load(obj.RunPath,"ScatteringRate","Time")
            catch
                error("Scattering rate was not saved")
            end
            close(figure(1003))
            figure(1003)
            plot(Time * 1e6, ScatteringRate * 1e-6)
            xlabel("Time in [$\mu \mathrm{s}$]",Interpreter="latex")
            ylabel("Scattering rate in [$\mathrm{MHz}$]",Interpreter="latex")
            render
        end
    end
end

