atom = Alkali("Rubidium87");
s = atom.D2.StateList;
sigmap = atom.D2.LoweringOperator(-1);
sigma0 = atom.D2.LoweringOperator(0);
sigmam = atom.D2.LoweringOperator(1);

[idxG,idxE] = find(sigmam);
for ii = 1:numel(idxG)
    disp( ...
        s.Label(idxG(ii)) + " to " + s.Label(idxE(ii)) + ...
        ": " + num2str(sigmam(idxG(ii),idxE(ii)))...
        )
end