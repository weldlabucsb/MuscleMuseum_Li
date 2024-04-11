close all
% atom = loadVar('AtomData.mat','Sodium');
% B = 0.07;

tmax = 100*1e3;
dt = 1;
t = 0:dt:tmax;
nn = numel(t);
Omega = 2*pi/200;
Omega = Omega / 13.35;
Deltalist = linspace(-100,100,nn)*2*pi/1e3;
% Deltalist= linspace(0,0,nn)*2*pi/1e3;
psi = [0,1]';
% [p,q] = atom.BreitRabiSpin1(B);
% h0 = diag([q,0,q]);

popdata = zeros(2,nn);
ev = zeros(2,nn);

for ii = 1:nn
    h = hB(Deltalist(ii),Omega);
    psi = expm(-1i*h*dt) *psi;
    psi = psi/(psi'*psi);
    popdata(:,ii) = abs(psi).^2;
    ev(:,ii) = eig(h);
end

t = t/1e3;
figure
plot(t,popdata(1,:),t,popdata(2,:))
xlabel('Time in [ms]')
ylabel('Population')
legend('$|e\rangle$','$|g\rangle$')

render

figure
plot(Deltalist/2/pi*1e3,ev(1,:)/2/pi*1e3,Deltalist/2/pi*1e3,ev(2,:)/2/pi*1e3)
xlabel('Detuning in [kHz]')
ylabel('Eigen-energy in [kHz]')
% legend('$|e\rangle$','$|g\rangle$')

render


function h = hB(delta,Omega)
    h = [-delta,Omega/2;...
        Omega/2,0];
end

