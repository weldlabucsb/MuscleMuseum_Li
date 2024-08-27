classdef DiffusionProfile < handle
    %FORCEPROFILE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        RabiFrquency
        Detuning
        VMax
        NVelocity
        DiffusionList
        Atom ArtificialAtom
    end

    properties(Dependent)
        VelocityList
        DiffusionUnit
        VelocityUnit
    end

    methods
        function obj = DiffusionProfile(Omega,Delta,atom,vMax,Nv)
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

        function DList = Run(obj)
            atom = obj.Atom;
            Gamma = atom.NatuaralLinewidth;
            omega = obj.RabiFrquency/Gamma;
            delta = obj.Detuning/Gamma;
            v = obj.VelocityList/obj.VelocityUnit;
            DList = arrayfun(@(x) diffu(omega,delta,x),v);
            obj.DiffusionList = DList * obj.DiffusionUnit;
        end

        function Show2(obj)
            vList = obj.VelocityList / obj.VelocityUnit;
            DList = obj.DiffusionList / obj.DiffusionUnit;
            figure
            plot(vList,DList)
            xlabel('Velocity [$\Gamma/k$]','Interpreter','latex')
            ylabel('Diffusion [$\hbar^2 k^2 \Gamma$]','Interpreter','latex')
            render
        end

        function Show(obj)
            vList = obj.VelocityList;
            DList = obj.DiffusionList;
            DList = DList * 10^6;
            figure
            plot(vList,DList)
            xlabel('Velocity [$\mathrm{m/s}$]','Interpreter','latex')
            ylabel('$\mathrm{Diffusion}/\mathrm{mass}^2$ [$\mathrm{m^2/s^3}$]','Interpreter','latex')
            render
        end

        function vList = get.VelocityList(obj)
            vMax = obj.VMax;
            Nv = obj.NVelocity;
            vList = linspace(-vMax,vMax,Nv);
        end

        function DUnit = get.DiffusionUnit(obj)
            atom = obj.Atom;
            Gamma = atom.NatuaralLinewidth;
            k = atom.WaveNumber;
            hboverm = atom.HbarOverMass;
            DUnit = (hboverm * k)^2 * Gamma;
        end

        function vUnit = get.VelocityUnit(obj)
            atom = obj.Atom;
            Gamma = atom.NatuaralLinewidth;
            k = atom.WaveNumber;
            vUnit = Gamma/k;
        end

    end
end

