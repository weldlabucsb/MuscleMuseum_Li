close all
atom = Alkali("Lithium7");
laser = GaussianBeam(wavelength=1064e-9,waist = [110e-6;110e-6],power=0.6,direction = [0;0;1]);
ol = OpticalLattice(atom,laser);
x = linspace(-200,200,1e5) * 1e-6;
r = [x;zeros(2,numel(x))];


force = 9.8 * 3 * atom.mass;
Vf = force * x / (Constants.SI("hbar") * 2 * pi);

func = ol.spaceFunc;
pot = (func(r) + Vf);

[~,idx] = min(pot);
xmin = x(idx);
fitIdx = abs(x-xmin) < 3e-6;
fitData = ParabolicFit1D([x(fitIdx).',pot(fitIdx).']);
fitData.do;
fitData.plot
fitFun = fitData.Result;

figure(1)
plot(x * 1e6,pot * 1e-3,x * 1e6,fitFun(x) * 1e-3);
ylim([-inf,0])
xlabel("$z$ position [$\mu \mathrm{m}$]",'Interpreter','latex')
ylabel("potential [kHz]",'Interpreter','latex')
legend("potential",'fit')
render
saveas(gca,"transverse",'png')

disp(ol.RadialFrequency)
disp(sqrt(fitData.Coefficient(1) * Constants.SI("hbar") * 2 * pi * 2 / atom.mass) / 2 / pi);