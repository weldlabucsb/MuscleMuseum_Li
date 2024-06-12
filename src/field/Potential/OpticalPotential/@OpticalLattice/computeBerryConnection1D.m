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

