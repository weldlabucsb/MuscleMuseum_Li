function plotAmpModCoupling1D(obj,n,isPlotDiagonal)
%PLOTAMPMODCOUPLING1D Summary of this function goes here
%   Detailed explanation goes here
arguments
    obj OpticalLattice
    n double {mustBeVector,mustBeInteger,mustBeNonnegative} = 0:2
    isPlotDiagonal logical = false
end
if isscalar(n)
    error("dim(n) must be larger than 1.")
end

kL = obj.Laser.AngularWavenumber;

% compute coupling
if obj.BandIndexMax >= max(n)
    qList = obj.QuasiMomentumList;
    A = obj.AmpModCoupling;
    A = A(n+1,n+1,:);
else
    nGrid = 2000;
    qList = linspace(-kL,kL,nGrid);
    A = obj.computeAmpModCoupling1D(qList,n);
end

% initialize legend
nBand = numel(n);
if isPlotDiagonal
    lg = cell(1,(nBand * (nBand  +1) / 2));
else
    lg = cell(1,(nBand * (nBand  - 1) / 2));
end

% plot absolute value
ll = 1;
letters={'S','P','D','F','G','H','I','J','K',...
    'L','M','N','O','P','Q','R'};
close(figure(21542))
figure(21542)
hold on
for mm = 1:nBand
    for nn = 1:nBand
        if nn >= mm
            if ~isPlotDiagonal
                if mm == nn
                    continue
                end
            end
            plot(qList / kL,squeeze(abs(A(mm,nn,:))))
            lg{ll} = ['$',letters{n(mm)+1},'\leftrightarrow ',letters{n(nn)+1},'$'];
            ll = ll + 1;
        end
    end
end
hold off
xlabel("$q/k_{\mathrm{L}}$",Interpreter="latex")
ylabel("$|A|$",Interpreter="latex")
legend(lg{:},'interpreter','latex')
box on
title("$V_0 = " + num2str(obj.Depth/obj.RecoilEnergy) + "E_{\mathrm{R}}$",'Interpreter','latex')
render

% plot phase
close(figure(21543))
figure(21543)
hold on
for mm = 1:nBand
    for nn = 1:nBand
        if nn >= mm
            if ~isPlotDiagonal
                if mm == nn
                    continue
                end
            end
            plot(qList / kL,squeeze(angle(A(mm,nn,:))))
        end
    end
end
hold off
xlabel("$q/k_{\mathrm{L}}$",Interpreter="latex")
ylabel("$\mathrm{arg}(A)$",Interpreter="latex")
legend(lg{:},'interpreter','latex')
box on
title("$V_0 = " + num2str(obj.Depth/obj.RecoilEnergy) + "E_{\mathrm{R}}$",'Interpreter','latex')
render

end

