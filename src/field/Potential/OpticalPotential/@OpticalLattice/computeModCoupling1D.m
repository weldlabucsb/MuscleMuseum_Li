function A = computeModCoupling1D(obj,q,n,x)
%COMPUTEMODCOUPLING1D Summary of this function goes here
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
A = zeros(nBand,nBand,nq);
dx = x(2) - x(1);
lambda = obj.Laser.Wavelength;
kL = obj.Laser.AngularWavenumber;
xIdx = x < lambda/4 & x > -lambda/4;

cc = cos(kL.*x).^2;
cc = cc(xIdx);
cc = cc.';

for qq = 1:nq
    for mm = 1:nBand
        for nn = 1:nBand
            uu = conj(u(:,qq,mm)) .* u(:,qq,nn);
            uu = uu(xIdx);
            A(mm,nn,qq) = sum(uu .* cc) * dx;
        end
    end
end

end

