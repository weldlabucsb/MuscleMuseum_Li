s1 = SineWave(amplitude=1,duration=10e-3,startTime=0,frequency=100e3);
s2 = SineWave(amplitude=1,duration=10e-3,startTime=0,frequency=120e3);
wf = {s1,s2};
wfl = WaveformList;
wfl.SamplingRate = 64e6;
wfl.WaveformOrigin = wf;
ks = getWG("LatticeMod");
ks.connect;
ks.set;
ks.WaveformList = {wfl,wfl};
ks.upload