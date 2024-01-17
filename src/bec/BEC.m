classdef BEC
    %BEC A class represents quasi 1-D BECs.
    
    properties
        RadialExpensionVelocity
        ThermalExpensionVelocity
        AspectRatio
        AxialTrapFrequency
    end
    
    properties (SetAccess = private)
        Atom
    end
    
    properties (Dependent)
       DensityWaveVelocity
       HealingLength
       SpinWaveVelocity
       SpinHealingLength
       ChemicalPotential
       PeakDensity
       Temperature
    end
    
    methods
        function obj = BEC(atom)
            %BEC Construct an instance of this class
            %   Detailed explanation goes here
            obj.Atom = atom;
        end
        
        function c_n = get.DensityWaveVelocity(obj)
            v_exp = obj.RadialExpensionVelocity;
            c_n = v_exp/sqrt(2);
        end
        
        function c_s = get.SpinWaveVelocity(obj)
            a = obj.Atom.ScatteringLength;
            c_n = obj.DensityWaveVelocity;
            a11 = a(1);
            a12 = a(2);
            gamma = sqrt((a11-a12)/(a11+a12));
            c_s = gamma*c_n;
        end
        
        function mu = get.ChemicalPotential(obj)
            hbaroverm = obj.Atom.HbarOverMass;
            v_exp = obj.RadialExpensionVelocity;
            mu = 1/2*v_exp^2/hbaroverm;
        end
        
    end
end

