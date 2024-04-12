s1 = SineWave(amplitude=0.5,duration=10e-3,startTime=0,frequency=1e3);
s2 = SineWave(amplitude=0.2,duration=10e-3,startTime=0,frequency=1.2e3);
wf = {s1,s2};
wfl = WaveformList;
wfl.SamplingRate = 64e6;
wfl.WaveformOrigin = wf;
ks = getWG("LatticeMod");
ks.OutputMode = "Gated";
ks.connect;
ks.set;
ks.WaveformList = {wfl,wfl};
ks.upload