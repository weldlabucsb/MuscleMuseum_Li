classdef FokkerPlanck < Simulation
    %FOK Summary of this class goes here
    %   Detailed explanation goes here

    properties
        ForceProfile ForceProfile
        DiffusionProfile DiffusionProfile
        Atom ArtificialAtom
        Laser Gaussian
        VMax
        NVelocity
        NTime
        NRun
        Detuning
        RabiFrequency
        FWHM
        TotalTime
        TimeList
        InitialCondition
    end

    properties(Dependent)
        VelocityList
    end

    methods
        function obj = FokkerPlanck(atom,laser,IC,tMax,Nt,vMax,Nv)
            arguments
                atom
                laser
                IC
                tMax
                Nt = 10000;
                vMax = 20;
                Nv = 4000;
            end
            obj@Simulation('fokkerPlanck')
            obj.Atom = atom;
            obj.Laser = laser;
            obj.VMax = vMax;
            obj.NVelocity = Nv;
            obj.NTime = Nt;

            nRun = numel(laser);
            obj.NRun = nRun;
            obj.Detuning = zeros(1,nRun);
            obj.RabiFrequency = zeros(1,nRun);
            obj.FWHM = zeros(1,nRun);

            for ii = 1:nRun
                obj.Detuning(ii) = laser(ii).Detuning;
                obj.RabiFrequency(ii) = rabi(atom,laser(ii),1);
                obj.InitialCondition = IC;
                obj.TotalTime(ii) = tMax;
            end

            Omega = obj.RabiFrequency;
            Delta = obj.Detuning;
            for ii = 1:nRun
                fP(ii) = ForceProfile(Omega(ii),Delta(ii),atom,vMax,Nv);
                DP(ii) = DiffusionProfile(Omega(ii),Delta(ii),atom,vMax,Nv);
            end

            obj.ForceProfile = fP;
            obj.DiffusionProfile = DP;

            obj.Update;
        end

        function vList = get.VelocityList(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            vmax = obj.VMax;
            Nv = obj.NVelocity;
            vList = linspace(-vmax,vmax,Nv);
        end

        function tList = get.TimeList(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            tmax = obj.TotalTime(1);
            Nt = obj.NTime;
            tList = linspace(0,tmax,Nt);
        end

        function pf = Run(obj,idx)

            %% Simulation parameters
            v = obj.VelocityList;
            v = v';
            dv = v(2)-v(1);
            t = obj.TimeList;
            t = t';

            %% Initial condition

            IC = obj.InitialCondition;

            rawfun = @(x)interp1(IC.vList,IC.pList,x,'linear','extrap');
            p = rawfun(v);
            p = p/sum(p)/dv;
            p(1) = 0;
            p(end) = 0;

            
            

            %% Force profile
            fProfile = obj.ForceProfile;
            flist = fProfile(idx).ForceList;

            ffun = @(x)interp1(v,flist,x,'linear','extrap');

            dfdv = DGradient(flist,dv);

            dffun = @(x)interp1(v,dfdv,x,'linear','extrap');

            %% Diffusion profile
            dProfile = obj.DiffusionProfile;
            Dlist = dProfile(idx).DiffusionList;

            Dfun = @(x)interp1(v,Dlist,x,'linear','extrap');

            dDdv = DGradient(Dlist,dv);

            dDfun = @(x)interp1(v,dDdv,x,'linear','extrap');

            %% Solve FP

            fpe = @(x,t,u,dudx) fp(x,t,u,dudx);
            % fpeic = @(x) fitresult(x);
            fpeic = @(x) interp1(v,p,x,'linear','extrap');
            fpebc = @(xl,ul,xr,ur,t) fpbc(xl,ul,xr,ur,t);

            solution = pdepe(0,fpe,fpeic,fpebc,v,t);
            pf = solution(end,:)';
            save(fullfile(obj.DataPath,[obj.DataPrefix,num2str(idx),'.',obj.DataType]),"pf")

            % Subfunctions

            function [c,f,s] = fp(x,t,u,dudx)
                c = 1;
                s = -ffun(x).*dudx-dffun(x).*u;
                f = (Dfun(x)*dudx+dDfun(x)*u);
            end

            function [pl,ql,pr,qr] = fpbc(xl,ul,xr,ur,t)
                pl = ul;
                ql = 0;
                pr = ur;
                qr = 0;
            end
        end

        function getFWHM(obj)
            for ii = 1:obj.NRun
                load(fullfile(obj.DataPath,['run',num2str(ii)]),'pf')
                obj.FWHM(ii) = fwhm(obj.VelocityList,pf);
            end
        end

        function Show(obj,ii)
            load(fullfile(obj.DataPath,['run',num2str(ii)]),'pf')
            figure
            plot(obj.VelocityList,pf)
            render
        end
    end




end

