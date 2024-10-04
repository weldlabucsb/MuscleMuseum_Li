close all
atom = Alkali("Lithium7");
bias = MagneticField(bias=[0;0;2.3e-4]);
[s,U] = atom.DGround.BiasDressedStateList(bias);
res = s.EnergyShift(1) - s.EnergyShift(6) + s.Energy(1) - s.Energy(6);
hfs = abs(diff(atom.DGround.Energy));
disp(res)
% H0 = atom.DGround.HamiltonianAtom(U);
% Hb = atom.DGround.HamiltonianAtomBiasField(bias,U);
H0 = diag(s.EnergyShift);

muBase = 1e-7;
dbList = -20:2:50;
% dbList = 1:2;
muList = muBase * 10.^(dbList/20);
freqEndList = (806:0.05:808.4) * 1e6;
popAll = zeros(numel(muList),numel(freqEndList));

for ii = 1:numel(muList)
    muF = MagneticField(bias=muList(ii) / sqrt(3) * [1,1,1]);
    Hmu = atom.DGround.HamiltonianAtomBiasField(muF,U);
    Hmu(6:8,6:8) = zeros(3,3);
    Hmu(1:5,1:5) = zeros(5,5);
    pop = zeros(1,numel(freqEndList));
    disp(ii)
    disp(numel(muList))
    parfor jj = 1:numel(freqEndList)

        freqStart = 809.56e6 - hfs;
        freqEnd = freqEndList(jj) - hfs;
        dura = 65e-3;
        dt = 2e-8;
        tList = 0:dt:dura;
        nt = numel(tList);
        freq = linspace(freqStart,freqEnd,nt);
        psi = zeros(8,1);
        psi(1) = 1;
        % popdata = zeros(8,nt);

        for tt = 1:nt
            t = tList(tt);
            H = H0 + Hmu;
            H = H - diag([repmat(freq(tt),1,5),zeros(1,3)]);
            H = 2 * pi * H;
            psi = expm(-1i*H*dt) * psi;
            psi = psi/(psi'*psi);
            % popdata(:,tt) = abs(psi).^2;
        end
        p = abs(psi).^2;
        pop(jj) = p(6);
    end
    popAll(ii,:) = pop;

    % plot(tList * 1e3,popdata)
    % xlabel("Time [ms]")
    % ylabel("Population")
    % l = legend(s.Label);
    % l.Interpreter = "latex";
    % render

    % pop(ii) = popdata(6,end);
end
img = imagesc(popAll);
renderTicks(img,(freqEndList - res)/1e6,dbList)
xlabel("Final detuning [MHz]",'Interpreter','latex')
ylabel("RF power [dB]",'Interpreter','latex')
title("Bias = 2.3 G, Reference RF Rabi = 1.1 kHz",'Interpreter','latex')
cb = colorbar;
cb.Label.String = "Fidelity";
saveas(gcf,"stateTransfer","fig")
saveas(gcf,"stateTransfer","png")
% render
% plot(dbList,pop)
% render


