classdef InitialCondition < dynamicprops
    %INITIALCONDITION Summary of this class goes here
    %   Detailed explanation goes here

    properties (SetAccess = protected)
        SimulationName
    end

    methods
        function obj = InitialCondition(simName)
            %INITIALCONDITION Construct an instance of this class
            %   Detailed explanation goes here
            if isstring(simName)
                obj.SimulationName = simName;
            else
                obj.SimulationName = string(class(simName));
            end
            obj.setProperties;
        end

        function obj = setProperties(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            switch obj.SimulationName
                case {"MeSim","MeSimRun"}
                    pWF = addprop(obj,"WaveFunction");
                    pDM = addprop(obj,"DensityMatrix");
                    addprop(obj,"Position");
                    addprop(obj,"Velocity");

                    obj.Position = [0;0;0];
                    obj.Velocity = [0;0;0];
                    pWF.SetMethod = @setWaveFunction;
                    pDM.SetMethod = @setDensityMatrix;
                case {"SeSim1D","SeSim1DRun"}
                    addprop(obj,"WaveFunctionFunc");
                    pWF = addprop(obj,"WaveFunction");
                    pWF.SetMethod = @setWaveFunction;
            end
            function obj = setWaveFunction(obj,val)
                if ~isvector(val)
                    error("Wave function must be a vector.")
                end
                val = val(:);
                val = val/norm(val);
                obj.WaveFunction = val;
                if isprop(obj,"DensityMatrix")
                    if isempty(obj.DensityMatrix)
                        obj.DensityMatrix = (val)*(val)';
                    end
                end
            end
            
            function obj = setDensityMatrix(obj,val)
                if ~ishermitian(val)
                    error("Density matrix must be a Hermitian matrix.")
                end
                obj.DensityMatrix = val/trace(val);
            end
        end
    end
end

