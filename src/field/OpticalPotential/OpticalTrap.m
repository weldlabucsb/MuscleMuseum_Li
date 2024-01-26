classdef OpticalTrap < OpticalPotential
    %OPTICALTRAP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Dependent)
        Depth % in Hz
        AxialFrequency % in Hz, linear frequency
        RadialFrequency % in Hz, linear frequency
    end
    
    methods
        function obj = OpticalTrap(atom,laser)
            %OPTICALTRAP Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                atom (1,1) Atom
                laser (1,1) GaussianBeam
            end
            obj@OpticalPotential(atom,laser);
        end
        
        function v0 = get.Depth(obj)
            v0 =  abs(obj.ScalarPolarizabilityGround * abs(obj.Laser.ElectricFieldAmplitude)^2 / 4);
        end
        function fZ = get.AxialFrequency(obj)
            zR = obj.Laser.RayleighRange;
            m = obj.Atom.mass;
            v0 =  2 * pi * Constants.SI("hbar") * obj.Depth;
            fZ = sqrt(2 * v0 / m / zR^2) / 2 / pi;
        end
        function fRho = get.RadialFrequency(obj)
            w0 = sqrt(prod(obj.Laser.Waist));
            m = obj.Atom.mass;
            v0 = 2 * pi * Constants.SI("hbar") * obj.Depth;
            fRho = sqrt(4 * v0 / m / w0^2) / 2 / pi;
        end
    end
end

