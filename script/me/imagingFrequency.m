atom = Alkali("Lithium7");
bField = MagneticField(bias = [0,0,560e-4]);
[sg,~,brg] = atom.DGround.BiasDressedStateList(bField);
[se,~,bre] = atom.D2Excited.BiasDressedStateList(bField);

gIndx = 6;
eIndx = 4;

bg = brg{1};
be = bre{1};
eg = brg{2}(gIndx,:);
ee = bre{2}(eIndx,:);
eg0 = sg.Energy(gIndx);
ee0 = se.Energy(eIndx);

ec = se.Energy(1) - sg.Energy(1);

eeint = interp1(be,ee,bg);
plot(bg * 1e4,(eeint-ec-eg)/1e6)
xlim([520,560])
xlabel("Magnetic Field [Gauss]",'Interpreter','latex')
ylabel("$f - f_{\mathrm{c}}$ [MHz]",'Interpreter','latex')
render

fData = LinearFit1D([bg(:) * 1e4,(eeint(:)-ec-eg(:))/1e6]);
fData.do