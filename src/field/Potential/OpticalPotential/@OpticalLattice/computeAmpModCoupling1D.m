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

