classdef (Abstract) OpticalPotential < Potential & matlab.mixin.Heterogeneous
    %OPTICALPOTENTIAL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Laser Laser
    end

    properties (Dependent)
        RecoilMomentum double
        RecoilVelocity double
        RecoilEnergy double % in Hz
        RecoilTemperature double % in K
        ScalarPolarizabilityGround double % in Hz/(V/m)^2
    end
    
    methods
        function obj = OpticalPotential(atom,laser,name)
            %OPTICALPOTENTIAL Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                atom (1,1) Atom
                laser Laser
                name string = string.empty
            end
            obj@Potential(atom,name);
            obj.Laser = laser;
        end

        function pr = get.RecoilMomentum(obj)
            pr = Constants.SI("hbar")*obj.Laser.AngularWavenumber;
        end
        function vr = get.RecoilVelocity(obj)
            vr = obj.RecoilMomentum./obj.Atom.mass;
        end
        function er = get.RecoilEnergy(obj)
            er = 1/2*obj.Atom.mass*((obj.RecoilVelocity).^2) ./ Constants.SI("hbar")/2/pi;
        end
        function tr = get.RecoilTemperature(obj)
            tr = 2*obj.RecoilEnergy.*Constants.SI("hbar")*2*pi./Constants.SI("kB"); %Notice the factor of 2
        end
        function alpha0 = get.ScalarPolarizabilityGround(obj)
            omegaD1 = 2 * pi * obj.Atom.D1.Frequency;
            omegaD2 = 2 * pi * obj.Atom.D2.Frequency;
            omegaL = obj.Laser.AngularFrequency;
            dipoleD1 = obj.Atom.D1.ReducedDipoleMatrixElement;
            dipoleD2 = obj.Atom.D2.ReducedDipoleMatrixElement;
            hbar = Constants.SI("hbar");

            alpha0 = 2/3/hbar * (omegaD1 * abs(dipoleD1)^2 / (omegaD1^2 - omegaL^2) +...
                omegaD2 * abs(dipoleD2)^2 / (omegaD2^2 - omegaL^2));
            alpha0 = alpha0 / hbar / 2 / pi;
        end
    end
end

