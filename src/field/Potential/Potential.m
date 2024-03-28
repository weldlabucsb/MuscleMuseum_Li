classdef (Abstract) Potential < handle
    %POTENTIAL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        Atom Atom
        Name string
    end

    properties
        Manifold string
        StateIndex double
    end
    
    methods
        function obj = Potential(atom,name)
            %POTENTIAL Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                atom Atom
                name string
            end
            obj.Atom = atom;
            obj.Name = name;
        end
        
    end
end

