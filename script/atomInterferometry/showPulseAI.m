%%
atom = Alkali("Lithium7");
laser = GaussianBeam( ...
    wavelength = 1064e-9,...
    direction = [0;1;0],...
    polarization = [0;0;1],...
    power = 1, ...
    waist = 110e-6 ...
    );
ol = OpticalLattice(atom,laser);
kL = ol.Laser.AngularWavenumber;
Er = ol.RecoilEnergy;
ol.DepthSpec = 8.8458 * Er;
ol.updateIntensity;
nq = 2e4;
ol.computeAll1D(nq,2)
Fjn = ol.BlochStateFourier;
lambda = laser.Wavelength;

%%
E = ol.BandEnergy;
E = E(1:3,:);
E = repmat(E,1,3);
qList = ol.QuasiMomentumList;
qList = [qList,qList + 2*kL,qList + 4*kL];
plot(qList/kL,E/Er)
xlabel("Quasimomentum ($k_{\mathrm{L}}$)")
ylabel("Energy ($E_{\mathrm{R}}$)")
qRes1 = 0.39 * kL;
qRes2 = 3.61 * kL;
ax = gca;

render
ax.Position(4) = ax.Position(4) - 0.04;
hold on
[~,qIdx] = min(abs(qList-qRes1));
pt1 = [qRes1/kL,E(2,qIdx)/Er];
pt2 = [qRes1/kL,E(3,numel(qList)-qIdx)/Er];
l = plotWavyLine(pt1,pt2,ax);
l.LineWidth = 1;
[~,qIdx] = min(abs(qList-qRes2));
pt1 = [qRes2/kL,E(2,qIdx)/Er];
pt2 = [qRes2/kL,E(3,numel(qList)-qIdx)/Er];
l = plotWavyLine(pt1,pt2,ax);
l.LineWidth = 1;
hold off
xlim([0,4])
ylim([-6.5,5]);

