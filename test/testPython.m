arc = py.importlib.import_module('arc');
np = py.importlib.import_module('numpy');
atom = arc.Lithium7(preferQuantumDefects=false);
% r = 0.01:0.01:1;
% y = arrayfun(@(x) atom.corePotential(int32(1),x),r);
% plot(r,y)
B = 0:0.001:5;
B = B*10^(-4);
ee = atom.breitRabi(int32(2),int32(1),3/2,np.array(B));
% ee = cellfun(@double,ee,'UniformOutput',false);
plot(B*10^4,ee{1})
