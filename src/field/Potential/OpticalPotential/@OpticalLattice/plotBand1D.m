function plotBand1D(obj,n)
%PLOTBAND1D Summary of this function goes here
%   Detailed explanation goes here
arguments
    obj OpticalLattice
    n double {mustBeInteger,mustBeNonnegative} = 3
end
nGrid = 200;
kL = obj.Laser.AngularWavenumber;
Er = obj.RecoilEnergy;
qList = linspace(-kL,kL,nGrid);
E = obj.computeBand1D(qList,n) / Er;
figure(13548)
plot(qList / kL,E(1:n+1,:))
xlabel("$q/k_{\mathrm{L}}$",Interpreter="latex")
ylabel("$E/E_{\mathrm{R}}$",Interpreter="latex")
render
end

