classdef Divalent < Atom    
    properties(SetAccess=protected)
        Blue TwoJManifoldDivalent
        CyclerSaturationIntensity double
    end
    
    methods
        function obj = Divalent(atomName)
            obj@Atom(atomName)
            if obj.Type ~= "Divalent"
                error("Wrong input [atomName]. [atomName] must be an divalent atom")
            end
            nG = obj.groundStateN();
            obj.Blue = TwoJManifoldDivalent(obj,nG,0,0,0,nG,1,1,0);
        end
    end
end

