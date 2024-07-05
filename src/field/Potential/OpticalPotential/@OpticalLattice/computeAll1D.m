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

