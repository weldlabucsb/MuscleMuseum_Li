s1 = SineWave(amplitude=0.5,duration=20e-3,startTime=0,frequency=1e3);
s2 = SineWave(amplitude=0.2,duration=20e-3,startTime=0,frequency=1.2e3);
s3 = SineWave(amplitude=0.2,duration=20e-3,startTime=12e-3,frequency=2e3);
wf = {s1,s2,s3};
wfl = WaveformList;
wfl.SamplingRate = 64e6;
wfl.WaveformOrigin = wf;
wfl.ConcatMethod = "Sequential";
wfl.IsTriggerAdvance = true;

% s1.plotOneCycle
% s1.plotExtra