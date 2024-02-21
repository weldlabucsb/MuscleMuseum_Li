classdef OpticalLattice < OpticalPotential
    %OPTICALLATTICE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        DepthKd
        DepthSpec
        RadialFrequencySlosh
    end

    properties (Dependent)
        LatticeSpacing % in meters
        DepthLaser % in Hz, calculated from laser power and waists
        AxialFrequencyLaser % in Hz, linear frequency, calculated from laser power and waists
        AxialFrequencyKd % in Hz, linear frequency, calculated from KD depth
        AxialFrequencySpec % in Hz, linear frequency, calculated from spectrum depth
        RadialFrequencyLaser % in Hz, linear frequency, calculated from laser power and waists
        RadialFrequencyKd % in Hz, linear frequency, calculated from KD depth
        RadialFrequencySpec % in Hz, linear frequency, calculated from spectrum depth
        Depth % in Hz, best value
        AxialFrequency % in Hz, best value
        RadialFrequency % in Hz, best value
    end

    methods
        function obj = OpticalLattice(atom,laser,name,options)
            %OPTICALLATTICE Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                atom (1,1) Atom
                laser Laser
                name string = string.empty
                options.manifold string = "DGround"
                options.stateIndex double = []
            end
            obj@OpticalPotential(atom,laser,name);
            obj.Manifold = options.manifold;
            if ~isempty(options.stateIndex)
                obj.StateIndex = options.stateIndex;
            else
                % By default, pick the lowest magnetic trappable state
                obj.StateIndex = atom.(obj.Manifold).StateList.Index(end);
            end
        end

        function a0 = get.LatticeSpacing(obj)
            a0 = obj.Laser.Wavelength / 2;
        end

        function v0 = get.DepthLaser(obj)
            v0 =  4 * abs(obj.ScalarPolarizabilityGround * abs(obj.Laser.ElectricFieldAmplitude)^2 / 4);
        end

        function fZ = get.AxialFrequencyLaser(obj)
            fZ = obj.computeAxialFrequency(obj.DepthLaser);
        end

        function fZ = get.AxialFrequencyKd(obj)
            fZ = obj.computeAxialFrequency(obj.DepthKd);
        end

        function fZ = get.AxialFrequencySpec(obj)
            fZ = obj.computeAxialFrequency(obj.DepthSpec);
        end

        function fRho = get.RadialFrequencyLaser(obj)
            fRho = obj.computeRadialFrequency(obj.DepthLaser);
        end

        function fRho = get.RadialFrequencyKd(obj)
            fRho = obj.computeRadialFrequency(obj.DepthKd);
        end

        function fRho = get.RadialFrequencySpec(obj)
            fRho = obj.computeRadialFrequency(obj.DepthSpec);
        end

        function fZ = computeAxialFrequency(obj,depth)
            lambda = obj.Laser.Wavelength;
            m = obj.Atom.mass;
            v0 =  2 * pi * Constants.SI("hbar") * depth;
            fZ = sqrt(v0 / m / lambda^2);
        end

        function fRho = computeRadialFrequency(obj,depth)
            if class(obj.Laser) == "GaussianBeam"
                w0 = sqrt(prod(obj.Laser.Waist));
                m = obj.Atom.mass;
                v0 = 2 * pi * Constants.SI("hbar") * depth;
                fRho = sqrt(4 * v0 / m / w0^2) / 2 / pi;
            else
                fRho = NaN;
            end
        end

        function v0 = get.Depth(obj)
            if ~isempty(obj.DepthSpec)
                v0 = obj.DepthSpec;
            elseif ~isempty(obj.DepthKd)
                v0 = obj.DepthKd;
            else
                v0 = obj.DepthLaser;
            end
        end

        function fZ = get.AxialFrequency(obj)
            if ~isempty(obj.DepthSpec)
                fZ = obj.AxialFrequencySpec;
            elseif ~isempty(obj.DepthKd)
                fZ = obj.AxialFrequencyKd;
            else
                fZ = obj.AxialFrequencyLaser;
            end
        end

        function fRho = get.RadialFrequency(obj)
            if ~isempty(obj.RadialFrequencySlosh)
                fRho = obj.RadialFrequencySlosh;
            elseif ~isempty(obj.DepthSpec)
                fRho = obj.RadialFrequencySpec;
            elseif ~isempty(obj.DepthKd)
                fRho = obj.RadialFrequencyKd;
            else
                fRho = obj.RadialFrequencyLaser;
            end
        end

        function func = spaceFunc(obj)
            V0 = obj.Depth;
            k = obj.Laser.AngularWavevector.';
            func = @(r) -V0 .* (cos(k * r)).^2;
        end

        function [E,u] = computeBand1D(obj,q,n,x)
            % Calculate Bloch state for quasimomentum q and band index n.
            % q: Sampling quasimomentum [p/hbar] in unit of 1/meter.
            % n: Band index. Start from zero. So n = 0 means the s band.
            % x: Optional. The sampling 1D spatial grids in unit of meter.
            % E: Band energy given as a nmax * length(q) matrix, where nmax
            % is the band index cutoff = 2*(max(n)+1)+49.
            % u: Bloch state in real space. If x is given, u is a matrix of
            % dimension length(x) * length(q) * length(n). If not, u is a
            % cell of function handles with dimension length(q) *
            % length(n).
            arguments
                obj OpticalLattice
                q double {mustBeVector}
                n double {mustBeVector,mustBeInteger,mustBeNonnegative}
                x double = []
            end
            v0 = obj.Depth / obj.RecoilEnergy; % Dimensionless lattice depth.
            kL = obj.Laser.AngularWavenumber;
            q = q / kL; % Dimensionless quasi-momentum.
            n = n + 1; % For easier indexing.
            nmax = 2 * max(n)+49; % Band index cutoff.
            j = 1-nmax:2:nmax-1;
            Vmat = -v0/4*gallery('tridiag',nmax,1,0,1); % I added a minus sign here
            E = zeros(nmax,length(q)); % Band energy
            ck = zeros(nmax,nmax,length(q)); % Bloch states in the plane wave basis.
            for qIdx = 1:length(q)
                Tmat = sparse(1:nmax,1:nmax,(q(qIdx)+j).^2,nmax,nmax);
                [ck(:,:,qIdx),tempE] = eig(full(Vmat+Tmat));
                E(:,qIdx) = diag(tempE);
            end

            if nargout == 2
                k = (1-nmax:2:nmax-1) * kL;
                q = q * kL;
                if isempty(x)
                    uFunc = cell(numel(q),numel(n));
                    for nIdx = 1:numel(n)
                        for qIdx = 1:numel(q)
                            uFunc{qIdx,nIdx} = @(x) 0;
                            vn = ck(:,n(nIdx),qIdx);
                            for ii = 1:nmax
                                uFunc{qIdx} = @(x) uFunc{qIdx}(x) + vn(ii)*exp(1i*(k(ii)+q(qIdx))*x);
                            end
                        end
                    end
                    u = uFunc;
                else
                    if ~isvector(x)
                        error("x must be a vector")
                    end
                    u = zeros(numel(x),numel(q),numel(n));
                    x = x(:); % Make sure x is a column vecter.
                    dx = abs(x(2) - x(1));
                    for nIdx = 1:numel(n)
                        for qIdx = 1:numel(q)
                            vn = ck(:,n(nIdx),qIdx);
                            for ii = 1:nmax
                                u(:,qIdx,nIdx) = u(:,qIdx,nIdx) + vn(ii)*exp(1i*(k(ii)+q(qIdx))*x);
                            end
                        end
                    end
                    u = u ./ sqrt(sum(abs(u).^2,1) * dx); % Normalization
                end
            end
        end

        function pop = computeBandPopulation1D(obj,psi,x,n)
            % Calculate band population for wavefunction psi.
            % psi: The wavefunctions. It is recommended to input the
            % conjugate of psi. psi is assumed to be a npsi * length(x)
            % matrix, where npsi the number of wavefunctions we want to
            % compute band population.
            % x: The sampling 1D spatial grids in unit of meter. Must be
            % the same size as the wave function.
            % n: Maximum band index. By default we calculate up to the d
            % band.
            % pop: Output band population as a npsi * n+1 matrix.
            arguments
                obj OpticalLattice
                psi double 
                x double {mustBeVector}
                n double {mustBeInteger,mustBeNonnegative} = 2
            end

            % Input validation
            if ~ismatrix(psi)
                error("Incorrect dimension of psi.")
            elseif size(psi,1) == numel(x)
                psi = psi'; % The spatial dimension of psi must be the second dimension.
            elseif size(psi,2) ~= numel(x)
                error("Incorrect dimension of psi.")
            end

            dx = x(2) - x(1); % Spatial grid size
            kL = obj.Laser.AngularWavenumber;
            dk = 2 * pi / numel(x) / dx; % Momentum grid size
            q = -kL:dk:kL; % Sampling quasi-momentum
            [~,u] = obj.computeBand1D(q,0:n,x);
            pop = zeros(size(psi,1),n+1);
            for nIdx = 1:(n+1)
                pop(:,nIdx) = sum(abs(psi * u(:,:,nIdx) * dx).^2,2);
            end
        end

    end
end

