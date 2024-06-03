function [E,phi,u] = computeBand1D(obj,q,n,x)
% Calculate Bloch state for quasimomentum q and band index n.
% q: Sampling quasimomentum [p/hbar] in unit of 1/meter.
% n: Band index. Start from zero. So n = 0 means the s band.
% x: Optional. The sampling 1D spatial grids in unit of meter.
% E: Band energy given as a nmax * length(q) matrix, where nmax
% is the band index cutoff = 2*(max(n)+1)+49. In Hz.
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
nmax = max(2 * max(n)+49,303); % Band index cutoff.
nCenterIdx = round(nmax / 2);
qCenterIdx = round(numel(q) / 2);
j = 1-nmax:2:nmax-1;
Vmat = -v0/4*gallery('tridiag',nmax,1,0,1); % I added a minus sign here
E = zeros(nmax,length(q)); % Band energy
ck = zeros(nmax,nmax,length(q)); % Bloch states in the plane wave basis.
for qIdx = 1:length(q)
    Tmat = sparse(1:nmax,1:nmax,(q(qIdx)+j).^2,nmax,nmax);
    [ck(:,:,qIdx),tempE] = eig(full(Vmat+Tmat));
    E(:,qIdx) = diag(tempE);
end
E = E * Er;

% Phase convention
for nIdx = 1:nmax
    m = sum(abs(diff((squeeze(ck(:,nIdx,:))),1,2))>0.1,1);
    % m = m > 2 ;
    m(1) = 0;
    if all(m==0)
        continue
    else
        flipPos = find(m,1);
        flipPos(abs(flipPos - qCenterIdx) <= 1) = [];
        if ~isempty(flipPos)
            ck(:,nIdx,flipPos+1:end) = -ck(:,nIdx,flipPos+1:end);
        end
    end
end

obj.FourierComponentList = ck;

if nargout >= 2
    k = (1-nmax:2:nmax-1) * kL;
    q = q * kL;
    if isempty(x)
        phiFunc = cell(numel(q),numel(n));
        uFunc = cell(numel(q),numel(n));
        for nIdx = 1:numel(n)
            for qIdx = 1:numel(q)
                phiFunc{qIdx,nIdx} = @(x) 0;
                uFunc{qIdx,nIdx} = @(x) 0;
                vn = ck(:,n(nIdx),qIdx);
                for ii = 1:nmax
                    phiFunc{qIdx,nIdx} = @(x) phiFunc{qIdx,nIdx}(x) + vn(ii)*exp(1i*(k(ii)+q(qIdx))*x);
                    if nargout == 3
                        uFunc{qIdx,nIdx} = @(x) uFunc{qIdx,nIdx}(x) + vn(ii)*exp(1i*k(ii)*x);
                    end
                end
            end
        end
        phi = phiFunc;
        if nargout == 3
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
                vn = ck(:,n(nIdx),qIdx).';
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
                if nargout == 3
                    u(:,qIdx,nIdx) = phi(:,qIdx,nIdx) ./ exp(1i * q(qIdx) * x);
                end
            end
        end
        phi = phi ./ sqrt(sum(abs(phi).^2,1) * dx); % Normalization
        if nargout ==3
            u = u ./ sqrt(sum(abs(u(cellIdx,:,:)).^2,1) * dx);
        end
    end
end
end
