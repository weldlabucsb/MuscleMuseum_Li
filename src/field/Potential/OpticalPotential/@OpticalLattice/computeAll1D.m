function computeAll1D(obj,q,n,x)
%COMPUTEALL1D Summary of this function goes here
%   Detailed explanation goes here
arguments
    obj OpticalLattice
    q double {mustBeVector}
    n double {mustBeVector,mustBeInteger,mustBeNonnegative}
    x double
end
obj.QuasiMomentumList = q;
obj.SpaceList = x;
obj.BandIndexMax = n;

[E,phi,u] = computeBand1D(obj,q,0:n,x);
obj.BandEnergyList = E;
obj.BlochStateList = phi;
obj.BlochStatePeriodicList = u;
obj.BoCouplingList = obj.computeBoCoupling1D;
obj.removeGauge;
obj.BoCouplingList = obj.computeBoCoupling1D;
obj.ModCouplingList = obj.computeModCoupling1D;

end

