function [E,phi] = computeBand1D(obj,q,n,x)
% Calculate Bloch state for quasimomentum q and band index n.
% q: Sampling quasimomentum [p/hbar] in unit of 1/meter.
% n: Band index. Start from zero. So n = 0 means the s band.
% x: Optional. The sampling 1D spatial grids in unit of meter.
% E: Band energy given as a nmax * length(q) matrix, where nmax
% is the band index cutoff = 2*(max(n)+1)+49. In Hz.
% phi: Bloch functions in real space. If x is given, u is a matrix of
% dimension length(x) * length(q) * length(n). If not, u is a
% cell of function handles with dimension length(q) *
% length(n).
arguments
    obj OpticalLattice
    q double {mustBeVector}
    n double {mustBeVector,mustBeInteger,mustBeNonnegative}
    x double = []
end
Er = obj.RecoilEnergy;
v0 = obj.DepthLu; % Dimensionless lattice depth.
kL = obj.Laser.AngularWavenumber;
q = q / kL; % Dimensionless quasi-momentum.
n = n + 1; % For easier indexing.
nmax = max(2 * max(n)+49,101); % Band index cutoff.
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
        phi = uFunc;
    else
        if ~isvector(x)
            error("x must be a vector")
        end
        phi = zeros(numel(x),numel(q),numel(n));
        x = x(:); % Make sure x is a column vecter.
        dx = abs(x(2) - x(1));
        for nIdx = 1:numel(n)
            for qIdx = 1:numel(q)
                vn = ck(:,n(nIdx),qIdx);
                for ii = 1:nmax
                    phi(:,qIdx,nIdx) = phi(:,qIdx,nIdx) + vn(ii)*exp(1i*(k(ii)+q(qIdx))*x);
                end
            end
        end
        phi = phi ./ sqrt(sum(abs(phi).^2,1) * dx); % Normalization
    end
end
end
