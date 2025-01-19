atom = Alkali("Lithium7");
bField = MagneticField(bias = [0,0,1200e-4]);
[sg,~,brg] = atom.DGround.BiasDressedStateList(bField);

gIndx1 = 6;
gIndx2 = 1;

bg = brg{1};
eg1 = brg{2}(gIndx1,:);
eg2 = brg{2}(gIndx2,:);
% eg0 = sg.Energy(gIndx1);

% eeint = interp1(be,ee,bg);
plot(bg * 1e4,(eg2 - eg1)/1e6)
xlim([0,1200])
xlabel("Magnetic Field [Gauss]",'Interpreter','latex')
ylabel("$f - f_{\mathrm{c}}$ [MHz]",'Interpreter','latex')
render

fitIndx = (bg(:) * 1e4 < 560) & (bg(:) * 1e4 > 520);
fData = LinearFit1D([bg(fitIndx).' * 1e4,(eg2(fitIndx).' - eg1(fitIndx).')/1e6]);
fData.do