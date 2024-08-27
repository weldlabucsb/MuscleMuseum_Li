classdef OpticalLattice < OpticalPotential
    %OPTICALLATTICE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        DepthKd
        DepthSpec
        RadialFrequencySlosh
    end

    properties (SetAccess = protected)
        SpaceList
        QuasiMomentumList
        BandIndexMax
        BandIndexMaxFourier = 101
        BandEnergy
        BlochState
        BlochStateFourier
        BlochStatePeriodic
        BerryConnection
        AmpModCoupling
    end

    properties (Constant)
        BandIndexMaxFourierDefault = 101
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
        DepthLu % in Er, best value
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

        function v0 = get.Depth(obj)
            if ~isempty(obj.DepthSpec)
                v0 = obj.DepthSpec;
            elseif ~isempty(obj.DepthKd)
                v0 = obj.DepthKd;
            else
                v0 = obj.DepthLaser;
            end
        end

        function v0 = get.DepthLu(obj)
            v0 = obj.Depth/obj.RecoilEnergy;
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

    end

    methods

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

        function func = spaceFunc(obj)
            V0 = obj.Depth;
            k = obj.Laser.AngularWavevector.';
            k0 = norm(k);
            kHat = k ./ k0;
            if class(obj.Laser) == "GaussianBeam"
                w0 = sqrt(prod(obj.Laser.Waist));
                zR = obj.Laser.RayleighRange;
                func = @(r) V(r);
            else
                func = @(r) -V0 .* (cos(k * r)).^2;
            end
            function Vout = V(r)
                z = kHat * r;
                r2 = vecnorm(r - kHat.' * z).^2;
                wz = w0 * sqrt(1 + (z./zR).^2);
                Vout = -V0 .* (w0./wz).^2 .* exp(-2 .* r2 ./ wz.^2) .* ...
                    cos(k0 * z .* (1 + 1/2 * r2 ./ zR^2 .* w0^2 ./ wz.^2)).^2;
            end
        end

        function updateIntensity(obj)
            v0 = obj.Depth;
            alpha = obj.ScalarPolarizabilityGround;
            obj.Laser.Intensity = abs(v0 / alpha) / 2 / Constants.SI("Z0");
        end

        function [E,Fjn,phi,u] = computeBand1D(obj,q,n,x)
            % Calculate Bloch state for quasimomentum q and band index n.
            % q: Sampling quasimomentum [p/hbar] in unit of 1/meter.
            % n: Band index. Start from zero. So n = 0 means the s band.
            % x: Optional. The sampling 1D spatial grids in unit of meter.
            % E: Band energy given as a length(n) * length(q) matrix, where nmax
            % is the band index cutoff = 2*(max(n)+1)+49. In Hz.
            % Fjn: Bloch states in Fourier space. Fjn is a matrix of dimension
            % nmax * length(n) * length(q). The first dimension denotes band indexes.
            % phi: Bloch states in real space. If x is given, phi is a matrix of
            % dimension length(x) * length(q) * length(n). If not, phi is a
            % cell of function handles with dimension length(q) *
            % length(n).
            % u: the periodic part of phi.
            arguments
                obj OpticalLattice
                q double {mustBeVector}
                n double {mustBeVector,mustBeInteger,mustBeNonnegative}
                x double = []
            end
            Er = obj.RecoilEnergy;
            v0 = obj.DepthLu; % Dimensionless lattice depth.
            kL = obj.Laser.AngularWavenumber;
            lambda = 2 * pi / kL;
            q = q / kL; % Dimensionless quasi-momentum.
            n = n + 1; % For easier indexing.
            nMax = max(2 * max(n)+49,obj.BandIndexMaxFourierDefault); % Band index cutoff. Making sure its an odd number
            nCenterIdx = round(nMax / 2);
            [~,qCenterIdx] = min(abs(q));
            j = 1-nMax:2:nMax-1;
            Vmat = -v0/4*gallery('tridiag',nMax,1,2,1); % I added a minus sign here
            E = zeros(nMax,length(q)); % Band energy
            Fjn = zeros(nMax,nMax,length(q)); % Bloch states in the plane wave basis.
            for qIdx = 1:length(q)
                Tmat = sparse(1:nMax,1:nMax,(q(qIdx)+j).^2,nMax,nMax);
                [Fjn(:,:,qIdx),tempE] = eig(full(Vmat+Tmat));
                E(:,qIdx) = diag(tempE);
            end
            E = E(n,:) * Er; % United in Hz
            Fjn = Fjn * sqrt(2 / lambda); % Normalization

            % Phase convention. Making sure the eigenstates are continuously varying along q
            if numel(q) >= 3
                for nIdx = 1:nMax
                    m = sum(abs(diff((squeeze(Fjn(:,nIdx,:))),1,2))>0.1 * sqrt(2 / lambda),1);
                    % m = m > 2 ;
                    m(1) = 0;
                    if all(m==0)
                        continue
                    else
                        flipPos = find(m,1);
                        flipPos(abs(flipPos - qCenterIdx) <= 1) = [];
                        if ~isempty(flipPos)
                            Fjn(:,nIdx,flipPos+1:end) = -Fjn(:,nIdx,flipPos+1:end);
                        end
                    end
                end
            end
            Fjn = Fjn(:,n,:);

            if nargout >= 3
                k = (1-nMax:2:nMax-1) * kL;
                q = q * kL;
                if isempty(x)
                    phiFunc = cell(numel(q),numel(n));
                    uFunc = cell(numel(q),numel(n));
                    for nIdx = 1:numel(n)
                        for qIdx = 1:numel(q)
                            phiFunc{qIdx,nIdx} = @(x) 0;
                            uFunc{qIdx,nIdx} = @(x) 0;
                            vn = Fjn(:,nIdx,qIdx);
                            for ii = 1:nMax
                                phiFunc{qIdx,nIdx} = @(x) phiFunc{qIdx,nIdx}(x) + vn(ii)*exp(1i*(k(ii)+q(qIdx))*x);
                                if nargout == 4
                                    uFunc{qIdx,nIdx} = @(x) uFunc{qIdx,nIdx}(x) + vn(ii)*exp(1i*k(ii)*x);
                                end
                            end
                        end
                    end
                    phi = phiFunc;
                    if nargout == 4
                        u = uFunc;
                    end
                else
                    if ~isvector(x)
                        error("x must be a vector")
                    end
                    phi = zeros(numel(x),numel(q),numel(n));
                    u = zeros(numel(x),numel(q),numel(n));
                    x = x(:); % Make sure x is a column vecter.
                    nx = numel(x);
                    dx = abs(x(2) - x(1));
                    cellIdx = x < lambda/4 & x >= -lambda/4;
                    [~,centerIdx] = min(abs(x));

                    k = repmat(k,nx,1);
                    for nIdx = 1:numel(n)
                        for qIdx = 1:numel(q)
                            vn = Fjn(:,nIdx,qIdx).';
                            vn = repmat(vn,nx,1);

                            temp = vn.* exp(1i*(k+q(qIdx)).* x);
                            phi(:,qIdx,nIdx) = sum(temp,2);
                            % for ii = 1:nmax
                            % phi(:,qIdx,nIdx) = phi(:,qIdx,nIdx) + vn(ii)*exp(1i*(k(ii)+q(qIdx))*x);
                            % if nargout == 3
                            %     u(:,qIdx,nIdx) = u(:,qIdx,nIdx) + vn(ii)*exp(1i*k(ii)*x);
                            % end
                            % end
                            % if mod(n(nIdx),2) == 0
                            %     dPhi = squeeze(gradient(phi(:,qIdx,nIdx)));
                            %     dPhi0 = dPhi(centerIdx);
                            %     phi(:,qIdx,nIdx) = phi(:,qIdx,nIdx) ./ exp(1i * angle(dPhi0));
                            % else
                            %     phi0 = squeeze(phi(centerIdx,qIdx,nIdx));
                            %     phi(:,qIdx,nIdx) = phi(:,qIdx,nIdx) ./ exp(1i * angle(phi0));
                            % end
                            if nargout == 4
                                u(:,qIdx,nIdx) = phi(:,qIdx,nIdx) ./ exp(1i * q(qIdx) * x);
                            end
                        end
                    end
                    phi = phi ./ sqrt(sum(abs(phi).^2,1) * dx); % Normalization
                    if nargout == 4
                        u = u ./ sqrt(sum(abs(u(cellIdx,:,:)).^2,1) * dx);
                    end
                end
            end
        end

        function X = computeBerryConnection1D(obj,q,n)
            %COMPUTEBOCOUPLING1D Summary of this function goes here
            %   Detailed explanation goes here
            arguments
                obj OpticalLattice
                q double = []
                n double = []
            end
            if ~isempty(q)
                [~,Fjn] = obj.computeBand1D(q,n);
            elseif ~isempty(obj.BlochStateFourier)
                Fjn = obj.BlochStateFourier;
                q = obj.QuasiMomentumList;
            else
                error("Must specify q,n")
            end

            % Compute gradient of Fjn along q
            dq = abs(q(2) - q(1));
            [~,~,dFdq] = gradient(Fjn,1,1,dq);

            % Compute Berry connection
            sz = size(Fjn);
            nq = sz(3);
            nBand = sz(2);
            X = zeros(nBand,nBand,nq);
            for qq = 1:nq
                BB = squeeze(dFdq(:,:,qq));
                AA = squeeze(Fjn(:,:,qq))';
                X(:,:,qq) = AA * BB;
                % for mm = 1:nBand
                % for nn = 1:nBand
                % FF = conj(Fjn(:,mm,qq)) .* dFdq(:,nn,qq);
                % X(mm,nn,qq) = sum(FF);
                % end
                % end
            end

            lambda = obj.Laser.Wavelength;
            X = 1i * lambda / 2 * X;
        end

        function A = computeAmpModCoupling1D(obj,q,n)
            %COMPUTEMODCOUPLING1D Summary of this function goes here
            %   Detailed explanation goes here
            arguments
                obj OpticalLattice
                q double = []
                n double = []
            end
            if ~isempty(q)
                [~,Fjn] = obj.computeBand1D(q,n);
            elseif ~isempty(obj.BlochStateFourier)
                Fjn = obj.BlochStateFourier;
            else
                error("Must specify q,n")
            end

            % Parameters
            sz = size(Fjn);
            nq = sz(3);
            nBand = sz(2);
            lambda = obj.Laser.Wavelength;

            % Matrices for computing
            FjnShift = circshift(Fjn,1) + circshift(Fjn,-1);
            idenMat = eye(nBand,nBand);

            % Compute coupling
            A = zeros(nBand,nBand,nq);
            for qq = 1:nq
                AA = squeeze(Fjn(:,:,qq))';
                BB = squeeze(FjnShift(:,:,qq));
                A(:,:,qq) = lambda / 8 * AA * BB + idenMat;
            end

        end

        function plotBand1D(obj,n)
            %PLOTBAND1D Summary of this function goes here
            %   Detailed explanation goes here
            arguments
                obj OpticalLattice
                n double {mustBeInteger,mustBeNonnegative} = 0:3
            end

            kL = obj.Laser.AngularWavenumber;
            Er = obj.RecoilEnergy;

            if obj.BandIndexMax >= max(n)
                E = obj.BandEnergy;
                E = E(n+1,:);
                qList = obj.QuasiMomentumList;
            else
                nGrid = 2000;
                qList = linspace(-kL,kL,nGrid);
                E = obj.computeBand1D(qList,n);
            end

            close(figure(13548))
            figure(13548)
            plot(qList / kL,E / Er)
            xlabel("$q/k_{\mathrm{L}}$",Interpreter="latex")
            ylabel("$E/E_{\mathrm{R}}$",Interpreter="latex")
            title("$V_0 = " + num2str(obj.Depth/Er) +"E_{\mathrm{R}}$",'Interpreter','latex')

            % draw band letters at the mean band position
            letters={'S','P','D','F','G','H','I','J','K',...
                'L','M','N','O','P','Q','R'};
            co = colororder;
            for nn=1:numel(n)
                yy=mean(E(nn,:))/Er;
                tL=text(0.85,yy+1,['$' letters{mod(n(nn),7)+1} '$'],...
                    'units','data','fontsize',15,...
                    'horizontalalignment','left',...
                    'color',co(mod(nn-1,7)+1,:),'interpreter','latex',...
                    'verticalalignment','middle');
                tL.Units='pixels';
                tL.Position(1)=tL.Position(1)+10;
                tL.Units='data';
            end
            render
        end

        function plotBandTransition1D(obj,freq,n)
            %PLOTBANDTRANSITION1D Summary of this function goes here
            %   Detailed explanation goes here
            arguments
                obj OpticalLattice
                freq double {mustBeScalarOrEmpty}
                n double {mustBeInteger,mustBeNonnegative} = 0:3
            end
            obj.plotBand1D(n);
            freqList = freq * (1:4);
            kL = obj.Laser.AngularWavenumber;
            Er = obj.RecoilEnergy;
            ax = gca;
            ax.Title.String = ax.Title.String + ", $\omega=" + num2str(freq/1e3) + "~\mathrm{kHz}$";
            hold on
            for ii = n
                for jj = n
                    if jj <= ii
                        continue
                    end
                    qRes = -obj.computeTransitionQuasiMomentum1D(freqList,ii,jj);
                    for kk = 1:4
                        if ~isnan(qRes(kk))
                            E = obj.computeBand1D(qRes(kk),[ii,jj]);
                            p1 = plot([1,1]*qRes(kk)/kL,...
                                E/Er,...
                                'k-','linewidth',1);
                            switch kk
                                case 1
                                    p1.LineStyle='-';
                                    p1.LineWidth=3;
                                case 2
                                    p1.LineStyle='--';
                                    p1.LineWidth=2;
                                case 3
                                    p1.LineStyle='-.';
                                    p1.LineWidth=1;
                                otherwise
                                    p1.LineStyle = ':';
                                    p1.LineWidth=.2;
                            end
                        end
                    end
                end
            end
            hold off

        end

        function plotAmpModCoupling1D(obj,n,isPlotDiagonal)
            %PLOTAMPMODCOUPLING1D Summary of this function goes here
            %   Detailed explanation goes here
            arguments
                obj OpticalLattice
                n double {mustBeVector,mustBeInteger,mustBeNonnegative} = 0:2
                isPlotDiagonal logical = false
            end
            if isscalar(n)
                error("dim(n) must be larger than 1.")
            end

            kL = obj.Laser.AngularWavenumber;

            % compute coupling
            if obj.BandIndexMax >= max(n)
                qList = obj.QuasiMomentumList;
                A = obj.AmpModCoupling;
                A = A(n+1,n+1,:);
            else
                nGrid = 2000;
                qList = linspace(-kL,kL,nGrid);
                A = obj.computeAmpModCoupling1D(qList,n);
            end

            % initialize legend
            nBand = numel(n);
            if isPlotDiagonal
                lg = cell(1,(nBand * (nBand  +1) / 2));
            else
                lg = cell(1,(nBand * (nBand  - 1) / 2));
            end

            % plot absolute value
            ll = 1;
            letters={'S','P','D','F','G','H','I','J','K',...
                'L','M','N','O','P','Q','R'};
            close(figure(21542))
            figure(21542)
            hold on
            for mm = 1:nBand
                for nn = 1:nBand
                    if nn >= mm
                        if ~isPlotDiagonal
                            if mm == nn
                                continue
                            end
                        end
                        plot(qList / kL,squeeze(abs(A(mm,nn,:))))
                        lg{ll} = ['$',letters{n(mm)+1},'\leftrightarrow ',letters{n(nn)+1},'$'];
                        ll = ll + 1;
                    end
                end
            end
            hold off
            xlabel("$q/k_{\mathrm{L}}$",Interpreter="latex")
            ylabel("$|A|$",Interpreter="latex")
            legend(lg{:},'interpreter','latex')
            box on
            title("$V_0 = " + num2str(obj.Depth/obj.RecoilEnergy) + "E_{\mathrm{R}}$",'Interpreter','latex')
            render

            % plot phase
            close(figure(21543))
            figure(21543)
            hold on
            for mm = 1:nBand
                for nn = 1:nBand
                    if nn >= mm
                        if ~isPlotDiagonal
                            if mm == nn
                                continue
                            end
                        end
                        plot(qList / kL,squeeze(angle(A(mm,nn,:))))
                    end
                end
            end
            hold off
            xlabel("$q/k_{\mathrm{L}}$",Interpreter="latex")
            ylabel("$\mathrm{arg}(A)$",Interpreter="latex")
            legend(lg{:},'interpreter','latex')
            box on
            title("$V_0 = " + num2str(obj.Depth/obj.RecoilEnergy) + "E_{\mathrm{R}}$",'Interpreter','latex')
            render

        end

        function plotBerryConnection1D(obj,n,isPlotDiagonal)
            %PLOTAMPMODCOUPLING1D Summary of this function goes here
            %   Detailed explanation goes here
            arguments
                obj OpticalLattice
                n double {mustBeVector,mustBeInteger,mustBeNonnegative} = 0:2
                isPlotDiagonal logical = false
            end
            if isscalar(n)
                error("dim(n) must be larger than 1.")
            end

            kL = obj.Laser.AngularWavenumber;
            lambda = obj.Laser.Wavelength;

            % compute Berry connection
            if obj.BandIndexMax >= max(n)
                qList = obj.QuasiMomentumList;
                X = obj.BerryConnection;
                X = X(n+1,n+1,:);
            else
                nGrid = 2000;
                qList = linspace(-kL,kL,nGrid);
                X = obj.computeBerryConnection1D(qList,n);
            end

            % initialize legend
            nBand = numel(n);
            if isPlotDiagonal
                lg = cell(1,(nBand * (nBand  +1) / 2));
            else
                lg = cell(1,(nBand * (nBand  - 1) / 2));
            end

            % plot absolute value
            ll = 1;
            letters={'S','P','D','F','G','H','I','J','K',...
                'L','M','N','O','P','Q','R'};
            close(figure(12325))
            figure(12325)
            hold on
            for mm = 1:nBand
                for nn = 1:nBand
                    if nn >= mm
                        if ~isPlotDiagonal
                            if mm == nn
                                continue
                            end
                        end
                        plot(qList / kL,squeeze(abs(X(mm,nn,:))) / (lambda/2))
                        lg{ll} = ['$',letters{n(mm)+1},'\leftrightarrow ',letters{n(nn)+1},'$'];
                        ll = ll + 1;
                    end
                end
            end
            hold off
            xlabel("$q/k_{\mathrm{L}}$",Interpreter="latex")
            ylabel("$|X| / (\lambda/2)$",Interpreter="latex")
            legend(lg{:},'interpreter','latex')
            box on
            title("$V_0 = " + num2str(obj.Depth/obj.RecoilEnergy) + "E_{\mathrm{R}}$",'Interpreter','latex')
            render

            % plot phase
            close(figure(12326))
            figure(12326)
            hold on
            for mm = 1:nBand
                for nn = 1:nBand
                    if nn >= mm
                        if ~isPlotDiagonal
                            if mm == nn
                                continue
                            end
                        end
                        plot(qList / kL,squeeze(angle(X(mm,nn,:))))
                    end
                end
            end
            hold off
            xlabel("$q/k_{\mathrm{L}}$",Interpreter="latex")
            ylabel("$\mathrm{arg}(X)$",Interpreter="latex")
            legend(lg{:},'interpreter','latex')
            box on
            title("$V_0 = " + num2str(obj.Depth/obj.RecoilEnergy) + "E_{\mathrm{R}}$",'Interpreter','latex')
            render

        end

        function pop = computeBandPopulation1D(obj,psicj,n,x)
            % Calculate band population for wavefunction psi.
            % psicj: The wavefunctions. It is recommended to input the
            % conjugate of psi. psicj is assumed to be a npsi * length(x)
            % matrix, where npsi the number of wavefunctions we want to
            % compute band population.
            % n: Maximum band index. By default we calculate up to the d
            % band.
            % x: The sampling 1D spatial grids in unit of meter. Must be
            % the same size as the wave function.
            % pop: Output band population as a npsi * n+1 matrix.
            arguments
                obj OpticalLattice
                psicj double
                n double {mustBeInteger,mustBeNonnegative} = 2
                x double {mustBeVector} = []
            end

            %% Input validation
            if ~ismatrix(psicj)
                error("Incorrect dimension of psi.")
            elseif isempty(x)
                if ~isempty(obj.SpaceList)
                    nx = numel(obj.SpaceList);
                else
                    error("Need to specify x.")
                end
            else
                nx = numel(x);
            end
            if size(psicj,1) == nx
                psicj = psicj'; % The spatial dimension of psi must be the second dimension.
            elseif size(psicj,2) ~= nx
                error("Incorrect dimension of psi.")
            end

            %% Get bands
            if ~isempty(x)
                dx = x(2) - x(1); % Spatial grid size
                kL = obj.Laser.AngularWavenumber;
                dk = 2 * pi / numel(x) / dx; % Momentum grid size
                q = -kL:dk:kL; % Sampling quasi-momentum
                [~,~,phi] = obj.computeBand1D(q,0:n,x);
            else
                phi = obj.BlochStateList;
                if n > max(obj.BandIndexMax)
                    error("n is too large. Change BandIndexMax or reset n.")
                end
            end

            %% Compute population
            pop = zeros(size(psicj,1),n+1);
            for nIdx = 1:(n+1)
                pop(:,nIdx) = sum(abs(psicj * phi(:,:,nIdx) * dx).^2,2);
            end

        end

        function pop = computeBandPopulationFourier1D(obj,ucj,q,n)
            % Calculate band population for wavefunction u.
            % ucj: The conjugate of the Fourier space wave function u.
            % ucj is assumed to be a nu * nFourierComponent
            % matrix, where nu the number of wavefunctions we want to
            % compute band population.
            % q: The sampling quasi-momentum in unit of 1/meter.
            % n: Maximum band index. By default we calculate up to the d
            % band.
            % pop: Output band population as a nu * (n+1) * nq matrix.
            arguments
                obj OpticalLattice
                ucj double
                q double {mustBeVector} = 0
                n double {mustBeInteger,mustBeNonnegative} = 2
            end

            %% Input validation
            if ~ismatrix(ucj)
                error("Incorrect dimension of ucj.")
            else
                nMax = size(ucj,2);
            end

            if numel(q) > 1
                if numel(q) ~= size(ucj,1)
                    error("Incorrect dimension of q")
                end
            end

            %% Get bands
            [~,Fjn] = obj.computeBand1D(q,0:(nMax - 49)/2 - 1);

            %% Renormalize ucj
            lambda = obj.Laser.Wavelength;
            ucj = ucj ./ sqrt(sum(ucj .* conj(ucj),2));
            ucj = ucj * sqrt(2 / lambda);

            %% Compute population
            pop = zeros(size(ucj,1),n+1);
            if numel(q) == 1
                for nIdx = 1:(n+1)
                    pop(:,nIdx) = abs(ucj * Fjn(:,nIdx)).^2;
                end
            else
                for nIdx = 1:(n+1)
                    for qIdx = 1:numel(q)
                        pop(qIdx,nIdx) = abs(ucj(qIdx,:) * Fjn(:,nIdx,qIdx)).^2;
                    end
                end
            end
            pop = pop * lambda^2 / 4;

        end

        function freq = computeTransitionFrequency1D(obj,q,n1,n2)
            % Compute transition frequencies between Bloch states.
            % q: Quasimomentum [p/hbar] in unit of 1/meter. q can be a 1 * N array
            % n1: The band index 1. Start from zero. So n = 0 means the s band.
            % n2: The band index 2.
            % freq: The transition frequencies. If q is an array, freq is also an
            % array with the same size.
            arguments
                obj OpticalLattice
                q double {mustBeVector}
                n1 double {mustBeVector,mustBeInteger,mustBeNonnegative}
                n2 double {mustBeVector,mustBeInteger,mustBeNonnegative}
            end
            E = obj.computeBand1D(q,[n1,n2]);
            freq = abs(E(2,:) - E(1,:));
        end

        function qRes = computeTransitionQuasiMomentum1D(obj,freq,n1,n2)
            % Compute transition quasi-momentum between Bloch states for specific freq.
            % q: Quasimomentum [p/hbar] in unit of 1/meter. q can be a 1 * N array
            % n1: The band index 1. Start from zero. So n = 0 means the s band.
            % n2: The band index 2.
            % freq: The transition frequencies. If q is an array, freq is also an
            % array with the same size.
            arguments
                obj OpticalLattice
                freq double {mustBeVector}
                n1 double {mustBeVector,mustBeInteger,mustBeNonnegative}
                n2 double {mustBeVector,mustBeInteger,mustBeNonnegative}
            end
            if obj.BandIndexMax < max(n1,n2)
                nq = 2^12;
                kL = obj.Laser.AngularWavenumber;
                q = linspace(-kL,kL,nq+1);
                q(end) = [];
                E = obj.computeBand1D(q,0:max([n1,n2]));
            else
                E = obj.BandEnergy;
                q = obj.QuasiMomentumList;
            end

            qIdx = q<=0;
            q = q(qIdx);
            E = E(:,qIdx);
            dE = abs(E(n2+1,:) - E(n1+1,:));
            bandDist = max(dE);
            bandGap = min(dE);
            tol = bandDist / 1e8;
            qRes = zeros(1,numel(freq));
            for ii = 1:numel(freq)
                if freq(ii) > bandDist || freq(ii) < bandGap
                    qRes(ii) = NaN;
                else
                    [~,resIdx] = sort(abs(freq(ii) - dE));
                    resIdx = resIdx(1:2);
                    q1 = q(resIdx(1));
                    q2 = q(resIdx(2));
                    E1err = abs(dE(resIdx(1)) - freq(ii));
                    E2err = abs(dE(resIdx(2)) - freq(ii));
                    err = tol * 10;
                    while err > tol
                        qResTemp = (q1 + q2) / 2;
                        EE = obj.computeBand1D(qResTemp,0:max([n1,n2]));
                        Emid = abs(EE(n2+1,:) - EE(n1+1,:));
                        err = abs(Emid - freq(ii));
                        if E1err > E2err
                            q1 = qResTemp;
                            E1err = err;
                        else
                            q2 = qResTemp;
                            E2err = err;
                        end
                    end
                    qRes(ii) = qResTemp;
                end
            end
            qRes = -qRes;


        end

        function computeAll1D(obj,nq,n)
            %COMPUTEALL1D Summary of this function goes here
            %   Detailed explanation goes here
            arguments
                obj OpticalLattice
                nq double {mustBeInteger,mustBePositive} = 1e4
                n double {mustBeVector,mustBeInteger,mustBeNonnegative} = 3
            end
            kL = obj.Laser.AngularWavenumber;
            q = linspace(-kL,kL,nq + 1);
            q(end) = [];
            obj.QuasiMomentumList = q;
            obj.BandIndexMax = n;

            [E,Fjn] = computeBand1D(obj,q,0:n);
            obj.BandIndexMaxFourier = size(Fjn,1);
            obj.BandEnergy = E;
            obj.BlochStateFourier = Fjn;
            obj.AmpModCoupling = obj.computeAmpModCoupling1D;
            obj.BerryConnection = obj.computeBerryConnection1D;
            % obj.removeGauge;
            % obj.BerryConnection = obj.computeBerryConnection1D;


        end

        function removeGauge(obj)
            %REMOVEGAUGE Summary of this function goes here
            %   Detailed explanation goes here
            X = obj.BoCouplingList;
            q = obj.QuasiMomentumList;
            x = obj.SpaceList;
            sz = size(X);
            nBand = sz(1);
            nq = sz(3);
            dq = q(2) - q(1);
            dx = x(2) - x(1);
            lambda = obj.Laser.Wavelength;
            cellIdx = x < lambda/4 & x >= -lambda/4;
            phase = zeros(nBand,nq);
            for nIdx = 1:nBand
                Xnn = X(nIdx,nIdx,:);
                phase(nIdx,:) = cumtrapz(q,Xnn);
            end
            phase = exp(1i * phase);

            phi = obj.BlochStateList;
            u = obj.BlochStatePeriodicList;

            for nIdx = 1:nBand
                for qq = 1:nq
                    phi(:,qq,nIdx) = phi(:,qq,nIdx) * phase(nIdx,qq);
                    u(:,qq,nIdx) = u(:,qq,nIdx) * phase(nIdx,qq);
                end
            end
            phi = phi ./ sqrt(sum(abs(phi).^2,1) * dx);
            u = u ./ sqrt(sum(abs(u(cellIdx,:,:)).^2,1) * dx);

            obj.BlochStateList = phi;
            obj.BlochStatePeriodicList = u;

        end

        function H = HamiltonianAmpModFourier1D(obj,q,wf)
            %HAMILTONIANMOD Summary of this function goes here
            %   Detailed explanation goes here
            arguments
                obj OpticalLattice
                q double
                wf Waveform
            end
            nMax = obj.BandIndexMaxFourier;
            V0 = obj.Depth / obj.RecoilEnergy;
            kL = obj.Laser.AngularWavenumber;
            jVec = 1-nMax:2:nMax-1;
            trigMat = -gallery('tridiag',nMax,1,2,1);
            modFunc = wf.TimeFunc;
            Hp = diag((jVec + q / kL).^2);
            HV0 = trigMat * V0 / 4;
            H = @(t) HFunc(t);
            function Htotal = HFunc(t)
                HV = HV0 * (1 + modFunc(t));
                Htotal = Hp + HV;
            end
        end

        function computeFloquetAmpMod1D(obj,wf)
            %COMPUTEFLOQUETAMPMOD1D Summary of this function goes here
            %   Detailed explanation goes here
            arguments
                obj OpticalLattice
                wf Waveform
            end
        end

    end
end

