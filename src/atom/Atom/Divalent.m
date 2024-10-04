classdef Divalent < Atom    
    properties(Dependent)
        
    end
    
    methods
        function obj = Divalent(atomName)
            obj@Atom(atomName)
            if obj.Type ~= "Divalent"
                error("Wrong input [atomName]. [atomName] must be an divalent atom")
            end
        end
       

    end
end

