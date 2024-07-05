function plotBandTransition1D(obj,freq,n)
%PLOTBANDTRANSITION1D Summary of this function goes here
%   Detailed explanation goes here
arguments
    obj OpticalLattice
    freq double {mustBeScalarOrEmpty}
    n double {mustBeInteger,mustBeNonnegative} = 0:3
end
obj.plotBand1D(n);
freqList = freq * (1:4);
kL = obj.Laser.AngularWavenumber;
Er = obj.RecoilEnergy;
ax = gca;
ax.Title.String = ax.Title.String + ", $\omega=" + num2str(freq/1e3) + "~\mathrm{kHz}$";
hold on
for ii = n
    for jj = n
        if jj <= ii
            continue
        end
        qRes = -obj.computeTransitionQuasiMomentum1D(freqList,ii,jj);
        for kk = 1:4
            if ~isnan(qRes(kk))
                E = obj.computeBand1D(qRes(kk),[ii,jj]);
                p1 = plot([1,1]*qRes(kk)/kL,...
                    E/Er,...
                    'k-','linewidth',1);
                switch kk
                    case 1
                        p1.LineStyle='-';
                        p1.LineWidth=3;
                    case 2
                        p1.LineStyle='--';
                        p1.LineWidth=2;
                    case 3
                        p1.LineStyle='-.';
                        p1.LineWidth=1;
                    otherwise
                        p1.LineStyle = ':';
                        p1.LineWidth=.2;
                end
            end
        end
    end
end
hold off

end

