classdef ForceProfile < handle
    %FORCEPROFILE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        RabiFrquency
        Detuning
        VMax
        NVelocity
        ForceList
        Atom ArtificialAtom
    end

    properties(Dependent)
        VelocityList
        ForceUnit
        VelocityUnit
    end

    methods
        function obj = ForceProfile(Omega,Delta,atom,vMax,Nv)
            %FORCEPROFILE Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                Omega
                Delta
                atom
                vMax = 20;
                Nv = 4000;
            end

            obj.RabiFrquency = Omega;
            obj.Detuning = Delta;
            obj.Atom = atom;
            obj.NVelocity = Nv;
            obj.VMax = vMax;
            obj.Run;
        end

        function fList = Run(obj)
            atom = obj.Atom;
            Gamma = atom.NatuaralLinewidth;
            omega = obj.RabiFrquency/Gamma;
            delta = obj.Detuning/Gamma;
            v = obj.VelocityList/obj.VelocityUnit;
            fList = arrayfun(@(x) force(omega,delta,x),v);
            obj.ForceList = fList * obj.ForceUnit;
        end

        function Show2(obj)
            vList = obj.VelocityList / obj.VelocityUnit;
            fList = obj.ForceList / obj.ForceUnit;
            figure
            plot(vList,fList)
            xlabel('Velocity [$\Gamma/k$]','Interpreter','latex')
            ylabel('Force [$\hbar k \Gamma$]','Interpreter','latex')
            render
        end

        function Show(obj)
            vList = obj.VelocityList;
            fList = obj.ForceList;
            fList = fList * 10^6;
            figure
            plot(vList,fList)
            xlabel('Velocity [$\mathrm{m/s}$]','Interpreter','latex')
            ylabel('Force/mass [$\mathrm{m/s^2}$]','Interpreter','latex')
            render
        end

        function vList = get.VelocityList(obj)
            vMax = obj.VMax;
            Nv = obj.NVelocity;
            vList = linspace(-vMax,vMax,Nv);
        end

        function fUnit = get.ForceUnit(obj)
            atom = obj.Atom;
            Gamma = atom.NatuaralLinewidth;
            k = atom.WaveNumber;
            hboverm = atom.HbarOverMass;
            fUnit = hboverm * k * Gamma;
        end

        function vUnit = get.VelocityUnit(obj)
            atom = obj.Atom;
            Gamma = atom.NatuaralLinewidth;
            k = atom.WaveNumber;
            vUnit = Gamma/k;
        end

    end
end

