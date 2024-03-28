x = 0:0.01:5;
T = 1.2;
Tr = 0.7;
Amax = 1;
Amin = 0.5;
phi = 0.1;

y = (mod((x + phi), T) < Tr) .* (Amin + (Amax - Amin) .* mod((x + phi), T) / Tr) + ...
                (mod((x + phi), T) >= Tr) .* (Amax -  (Amax - Amin) .* (mod((x + phi), T) - Tr) / (T - Tr));
fData = TriangleFit1D([x',y']);
fData.do
fData.plot
% plot(x,y)