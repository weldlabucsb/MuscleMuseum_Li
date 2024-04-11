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

popdata = zeros(2,nn);
ev = zeros(2,nn);

nPhase = 20;
phaseList = linspace(0,2*pi,nPhase);
phaseList2 = zeros(1,nPhase);
finalPop = zeros(1,nPhase);

for jj = 1:nPhase
    psi = [0,1]';
    for ii = 1:nn
        h = hB(Deltalist(ii),Omega * exp(1i*phaseList(jj)));
        psi = expm(-1i*h*dt) *psi;
        psi = psi/(psi'*psi);
        popdata(:,ii) = abs(psi).^2;
    end
    phaseList2(jj) = mod(diff(angle(psi)),2*pi) / pi * 180;
    finalPop(jj) = abs(psi(1)).^2;
end

% t = t/1e3;
figure
plot(phaseList/pi*180,phaseList2)
xlabel('Phase of Rabi [degree]')
ylabel('Phase difference of states [degree]')
axis([0,360,0,360])
render

figure
plot(phaseList/pi*180,finalPop)
xlabel('Phase of Rabi')
ylabel('Population of excited state')
axis([0,360,0,1])
render

t = t/1e3;
figure
plot(t,popdata(1,:),t,popdata(2,:))
xlabel('Time in [ms]')
ylabel('Population')
legend('$|e\rangle$','$|g\rangle$')
render

function h = hB(delta,Omega)
    h = [-delta,Omega/2;...
        conj(Omega)/2,0];
end

