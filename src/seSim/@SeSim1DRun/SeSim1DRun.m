classdef SeSim1DRun < TimeSimRun & SpaceSimRun
    %SESIM1DRUN Summary of this class goes here
    %   Single-particle time-dependent Schrodinger equation simulation in 
    %   1D.
    
    properties
        Mass (1,1) double % mass of the particle
        Potential function_handle
    end

    properties (SetAccess = protected)
        KineticPropagator
    end
    
    methods
        function obj = SeSim1DRun(seSim1D,options)
            %SESIM1DRUN Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                seSim1D SeSim1D = SeSim1D.empty  
                options.totalTime double
                options.timeStep double
                options.spaceOrigin double
                options.spaceRange double
                options.nSpaceStep double
                options.mass double
                options.initialCondition InitialCondition
                options.boundaryCondition string = "Periodic"
                options.potential function_handle
            end
            obj@TimeSimRun(seSim1D)
            obj@SpaceSimRun(seSim1D)
            obj.Dimension = 1;

            field = string(fieldnames(options));
            for ii = 1:numel(field)
                if ~isempty(options.(field(ii)))
                    obj.(capitalizeFirst(field(ii))) = options.(field(ii));
                end
            end

            % Kinetic energy propagator
            k = obj.SpaceAngularFrequencyList.';
            hbar = Constants.SI("hbar");
            m = obj.Mass;
            dt = obj.TimeStep;
            obj.KineticPropagator = exp(-1i * hbar / 2 / m * k.^2 * dt);
        end

        function start(obj)
            tList = obj.TimeList;
            nt = obj.NTimeStep;
            dt = obj.TimeStep;
            psi = obj.InitialCondition.WaveFunction;
            V = obj.Potential;
            Uk = obj.KineticPropagator;
            x = obj.SpaceList;

            figure
            % Strang splitting
            for tt = 1:nt
                t = tList(tt);
                V1 = (V(t) + 4 * V(t + 1/4*dt) + V(t + 1/2*dt))/6;
                V2 = (V(t + 1/2*dt) + 4 * V(t + 3/4*dt) + V(t + dt))/6;
                UV1 = exp(-1i * 2 * pi * V1 * dt / 2);
                UV2 = exp(-1i * 2 * pi * V2 * dt / 2);
                psi = UV1 .* psi;
                psi = ifft(Uk.*fft(psi));
                psi = UV2 .* psi;
                if mod(tt,1e2) == 0
                    plot(x,abs(psi).^2,x,abs(obj.InitialCondition.WaveFunction).^2)
                    drawnow
                end
            end
           
        end
        
    end
end

