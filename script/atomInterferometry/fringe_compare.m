f = openfig("11_13_fringe_compare.fig");
l = f.Children(2).Children;

freqlz = l(3).XData;
freqex = l(4).XData;
datalz = l(3).YData;
dataex = l(4).YData;
close all

plot(1./freqlz*1e3,datalz,1./freqex*1e3,dataex)
xlabel("Bloch Period [ms]")
ylabel("$p$ Band Fraction")
lg = legend("Floquet LZ + Phase Shift","Exact Fourier TDSE");
xlim([min(1./freqlz*1e3),max(1./freqlz*1e3)])
lg.Location = "best";
render