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
ol.computeAll1D

%%
n = 0:2;
kL = ol.Laser.AngularWavenumber;
Er = ol.RecoilEnergy;

% if ol.BandIndexMax >= max(n)
%     E = ol.BandEnergy;
%     E = E(n+1,:);
%     qList = ol.QuasiMomentumList;
% else
% 
% end

    nGrid = 2000;
    qList = linspace(-kL,2 * kL,nGrid);
    E = ol.computeBand1D(qList,n);

close(figure(13548))
figure(13548)
plot(qList / kL,E / Er)
xlabel("$q/k_{\mathrm{L}}$",Interpreter="latex")
ylabel("$E/E_{\mathrm{R}}$",Interpreter="latex")
title("$V_0 = " + num2str(ol.Depth/Er) +"E_{\mathrm{R}}$",'Interpreter','latex')

% draw band letters at the mean band position
letters={'S','P','D','F','G','H','I','J','K',...
    'L','M','N','O','P','Q','R'};
co = colororder;
for nn=1:numel(n)
    yy=mean(E(nn,:))/Er;
    tL=text(2.05,yy+1,['$' letters{mod(n(nn),7)+1} '$'],...
        'units','data','fontsize',15,...
        'horizontalalignment','left',...
        'color',co(mod(nn-1,7)+1,:),'interpreter','latex',...
        'verticalalignment','middle');
    tL.Units='pixels';
    tL.Position(1)=tL.Position(1)+10;
    tL.Units='data';
end
render
ax = gca;
ax.Position(3) = ax.Position(3) * 0.9;
ax.YLim = [-7,5];
