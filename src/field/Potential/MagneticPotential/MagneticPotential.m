classdef MagneticPotential < Potential & matlab.mixin.Heterogeneous
    %OPTICALPOTENTIAL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        MagneticField MagneticField
    end

    properties (Dependent)
        
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
                obj.StateIndex = atom.(obj.Manifold).StateList.Index(end);
            end
        end

        function func = spaceFuncLowField(obj)
            stateIdx = obj.StateIndex;
            stateList = obj.Atom.(obj.Manifold).StateList;
            mF = stateList.MF(stateIdx);
            gF = stateList.gF(stateIdx);
            muB = Constants.SI("muB");
            h = Constants.SI("hbar") * 2 * pi;
            prefactor = mF * gF * muB / h;
            bSpaceFunc = obj.MagneticField.spaceFunc;
            func = @(r) prefactor * vecnorm(bSpaceFunc(r));
        end

        function func = spaceFuncHighField(obj)
            stateIdx = obj.StateIndex;
            stateList = obj.Atom.(obj.Manifold).StateList;
            mJ = stateList.MJ(stateIdx);
            gJ = stateList.gJ(stateIdx);
            mI = stateList.MI(stateIdx);
            gI = stateList.gI(stateIdx);
            muB = Constants.SI("muB");
            h = Constants.SI("hbar") * 2 * pi;
            prefactor = (mJ * gJ + mI * gI) * muB / h;
            bSpaceFunc = obj.MagneticField.spaceFunc;
            func = @(r) prefactor * vecnorm(bSpaceFunc(r));
        end

    end
end

