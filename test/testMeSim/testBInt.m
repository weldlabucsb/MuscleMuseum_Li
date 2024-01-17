close all
atom = Alkali("Lithium7");
bias = 10e-4;
B = MagneticField(bias=[0;0;bias]);

s = atom.D2Excited.BiasDressedStateList(B,true);
bList = linspace(0,bias,500);
ee = atom.ArcObj.breitRabi(int32(2),int32(1),3/2,py.numpy.array(bList));
f = double(ee{2});
mf = double(ee{3});
ll = cell(1,numel(mf));
for ii = 1:numel(mf)
    ll{ii} = num2str(mf(ii));
end
hold on
plot(bList,ee{1})
% legend(ll{:})
hold off
