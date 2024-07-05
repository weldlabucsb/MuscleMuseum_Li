function plotBand1D(obj,n)
%PLOTBAND1D Summary of this function goes here
%   Detailed explanation goes here
arguments
    obj OpticalLattice
    n double {mustBeInteger,mustBeNonnegative} = 0:3
end

kL = obj.Laser.AngularWavenumber;
Er = obj.RecoilEnergy;

if obj.BandIndexMax >= max(n)
    E = obj.BandEnergy;
    E = E(n+1,:);
    qList = obj.QuasiMomentumList;
else
    nGrid = 2000;
    qList = linspace(-kL,kL,nGrid);
    E = obj.computeBand1D(qList,n);
end

close(figure(13548))
figure(13548)
plot(qList / kL,E / Er)
xlabel("$q/k_{\mathrm{L}}$",Interpreter="latex")
ylabel("$E/E_{\mathrm{R}}$",Interpreter="latex")
title("$V_0 = " + num2str(obj.Depth/Er) +"E_{\mathrm{R}}$",'Interpreter','latex')

% draw band letters at the mean band position
letters={'S','P','D','F','G','H','I','J','K',...
    'L','M','N','O','P','Q','R'};
co = colororder;
for nn=1:numel(n)
    yy=mean(E(nn,:))/Er;
    tL=text(0.85,yy+1,['$' letters{mod(n(nn),7)+1} '$'],...
        'units','data','fontsize',15,...
        'horizontalalignment','left',...
        'color',co(mod(nn-1,7)+1,:),'interpreter','latex',...
        'verticalalignment','middle');    
    tL.Units='pixels';
    tL.Position(1)=tL.Position(1)+10;
    tL.Units='data';
end
render
end

