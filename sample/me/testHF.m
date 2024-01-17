%%
B = MagneticField(bias=[0,0,720e-4]);
atom = Alkali("Lithium7");
[s,U] = atom.D2.BiasDressedStateList(B);
% ee = s.Energy + s.EnergyShift;
% hfs = atom.DGround.HFSCoefficient;
% a = hfs(1);
% b = hfs(2);

%%
JO = atom.D2.JOperator;
IO = atom.D2.IOperator;
state1 = s.DressedState{22};
state2 = s.DressedState{4};
d = atom.D2.LoweringOperator(1);
dd = (-1)^(1)*atom.D2.LoweringOperator(-1)';
d = d + dd;
sigma = atom.D2.LoweringOperator(1,U);
disp(sigma(22,4))
disp(state1'*d*state2)
disp(state1'*IO{3}*state1)
disp(state1'*JO{3}*state1)

disp(state2'*IO{3}*state2)
disp(state2'*JO{3}*state2)





%%
state3 = s.DressedState{18};
state33 = [zeros(16,1);uncoupledSpinBasis(1/2,1/2,3/2,1/2)];
state22 = [uncoupledSpinBasis(3/2,3/2,3/2,-3/2);zeros(8,1)];
state11 = [zeros(16,1);uncoupledSpinBasis(1/2,-1/2,3/2,3/2)];
disp(state3'*d*state2)
disp(state33'*d*state22)
