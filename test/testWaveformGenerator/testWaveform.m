s1 = SineWave(amplitude=0.5,duration=20e-3,startTime=5e-3,frequency=1.05e3);
s2 = ConstantWave(offset=0.5,duration=20e-3,startTime=5e-3);
s3 = SineWave(amplitude=0.2,duration=10e-3,startTime=0,frequency=1.2e3);
s4 = SineWave(amplitude=0.2,duration=20e-3,startTime=30e-3,frequency=2e3);
tw = TrapezoidalSinePulse(amplitude=1,duration=10e-3,riseTime=1e-3,fallTime=2e-3,frequency=10e3,startTime=0);
tanhw = TanhSinePulse(amplitude=1,duration=10e-3,riseTime=1e-3,fallTime=2e-3,frequency=30e3,startTime=0);
pchipw = PchipSinePulse(amplitude=1,duration=10e-3,riseTime=1e-3,fallTime=2e-3,frequency=30e3,startTime=0);
ramp = LinearRamp(duration=2e-3,startValue=0.1,stopValue=0.2,startTime=0,rampTime = 1e-3);
% wf = {s1,s2,s3,s4};
wf = {ramp};
wfl = WaveformList("tt");
wfl.SamplingRate = 64e6;
wfl.WaveformOrigin = wf;
wfl.ConcatMethod = "Sequential";
wfl.IsTriggerAdvance = true;
wfl.plot
% s1.plotOneCycle
% s1.plotExtra