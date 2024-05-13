function X = computeBoCoupling1D(obj,q,n,x)
%COMPUTEBOCOUPLING1D Summary of this function goes here
%   Detailed explanation goes here
arguments
    obj OpticalLattice
    q double = []
    n double = []
    x double = []
end
if ~isempty(q)
    [~,~,u] = obj.computeBand1D(q,n,x);
elseif ~isempty(obj.BlochStatePeriodicList)
    u = obj.BlochStatePeriodicList;
    x = obj.SpaceList;
    q = obj.QuasiMomentumList;
else
    error("Must specify q,n,x")
end

sz = size(u);
nq = sz(2);
nBand = sz(3);
X = zeros(nBand,nBand,nq);
dx = abs(x(2) - x(1));
dq = abs(q(2) - q(1));
lambda = obj.Laser.Wavelength;
xIdx = x < lambda/4 & x >= -lambda/4;
% [~,dudq,~] = gradient(u);
% dudq = dudq / dq;
[dudq,~,~] = gradient(u,dq,dx,1);
% dudqimag = DGradient(imag(u),dq,2);
% dudqreal = DGradient(real(u),dq,2);
% dudq = dudqreal + dudqimag * 1i;



for qq = 1:nq
    for mm = 1:nBand
        for nn = 1:nBand
            uu = conj(u(:,qq,mm)) .* 1i .* dudq(:,qq,nn);
            uu = uu(xIdx);
            X(mm,nn,qq) = sum(uu) * dx;
        end
    end
end

