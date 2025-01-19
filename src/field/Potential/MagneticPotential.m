classdef MagneticPotential < Potential & matlab.mixin.Heterogeneous
    %OPTICALPOTENTIAL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        MagneticField MagneticField
    end

    properties (Dependent)
        EnergyFactor
        EnergyFactorLowField
        EnergyFactorHighField
    end
    
    methods
        function obj = MagneticPotential(atom,magneticField,name,options)
            %OPTICALPOTENTIAL Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                atom (1,1) Atom
                magneticField MagneticField
                name string = string.empty
                options.manifold string = "DGround"
                options.stateIndex double = []
            end
            obj@Potential(atom,name);
            obj.MagneticField = magneticField;
            obj.Manifold = options.manifold;
            if ~isempty(options.stateIndex)
                obj.StateIndex = options.stateIndex;
            else
                % By default, pick the lowest magnetic trappable state
                sL = atom.(obj.Manifold).StateList;
                F = min(sL.F);
                obj.StateIndex = sL(sL.F==F & sL.MF == F,:).Index;
            end
        end

        function eFactL = get.EnergyFactorLowField(obj)
            stateIdx = obj.StateIndex;
            stateList = obj.Atom.(obj.Manifold).StateList;
            mF = stateList.MF(stateIdx);
            gF = stateList.gF(stateIdx);
            muB = Constants.SI("muB");
            h = Constants.SI("hbar") * 2 * pi;
            eFactL = mF * gF * muB / h;
        end

        function eFactH = get.EnergyFactorHighField(obj)
            stateIdx = obj.StateIndex;
            stateList = obj.Atom.(obj.Manifold).StateList;
            mJ = stateList.MJ(stateIdx);
            gJ = stateList.gJ(stateIdx);
            mI = stateList.MI(stateIdx);
            gI = stateList.gI(stateIdx);
            muB = Constants.SI("muB");
            h = Constants.SI("hbar") * 2 * pi;
            eFactH = (mJ * gJ + mI * gI) * muB / h;
        end

        function eFact = get.EnergyFactor(obj)
            energyList = obj.Atom.(obj.Manifold).StateList.Energy;
            hfs = max(energyList) - min(energyList);
            bias = vecnorm(obj.MagneticField.Bias);
            eFactL = obj.EnergyFactorLowField;
            eFactH = obj.EnergyFactorHighField;
            if abs(bias * eFactL) < hfs / 10
                eFact = eFactL;
            else
                eFact = eFactH;
            end
        end

        function func = spaceFuncLowField(obj)
            prefactor = obj.EnergyFactorLowField;
            bSpaceFunc = obj.MagneticField.spaceFunc;
            func = @(r) prefactor * vecnorm(bSpaceFunc(r));
        end

        function func = spaceFuncHighField(obj)
            prefactor = obj.EnergyFactorHighField;
            bSpaceFunc = obj.MagneticField.spaceFunc;
            func = @(r) prefactor * vecnorm(bSpaceFunc(r));
        end

    end
end

