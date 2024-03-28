%StepTypeStructCreation.m
%Written by Eber Nolasco-Martinez
%11-17-2021

%Purpose of this code is to create a struct that contains all necessary
%information about each step type, including number of variables, variable
%names, step name, default variable settings, etc. Will leave explicit
%formation of waveform in to the Upload button script (since to make it
%efficient may require some trickery in terms of repetitions, etc, that may
%be unique to each specific step type:

%Fields are as following:
%- stepname    - String representing what the step type is called
%- varnumber   - Integer representing number of parameters per step to vary
%- varnames    - cell list of Strings representing name of each parameter
%- vardefault  - Array of numbers representing default strings


%Create Sinusoidal Struct item
StepTypeStyles=struct();
StepTypeStyles(1).stepname='Sinusoidal';
StepTypeStyles(1).varnumber=4;
StepTypeStyles(1).varnames={'Step Length (s)', 'Frequency (Hz)', 'Amplitude (V)', 'Phase (Not working)'};
StepTypeStyles(1).vardefault=[1e-3,50e3,0.1,0];

StepTypeStyles(2).stepname='Pulse';
StepTypeStyles(2).varnumber=5;
StepTypeStyles(2).varnames={'Step Length (s)', 'Period (s)', 'Width (s)', 'Amplitude (V)','Delay (s)'};
StepTypeStyles(2).vardefault=[1, 1, 1, 1, 0];

StepTypeStyles(3).stepname='Constant';
StepTypeStyles(3).varnumber=2;
StepTypeStyles(3).varnames={'Step Length', 'Amplitude'};
StepTypeStyles(3).vardefault=[1, 1];

StepTypeStyles(4).stepname='TwoFreq';
StepTypeStyles(4).varnumber=6;
StepTypeStyles(4).varnames={'Step Length (s)', 'Frequency 1 (Hz)', 'Amplitude 1 (V)', 'Frequency 2 (Hz)', 'Amplitude 2 (V)', 'Delay 2 (s)'};
StepTypeStyles(4).vardefault=[1, 1, 1, 1, 1, 0];

StepTypeStyles(5).stepname='SineRampUp';
StepTypeStyles(5).varnumber=3;
StepTypeStyles(5).varnames={'Step Length (s)', 'Frequency (Hz)', 'Amplitude (V)'};
StepTypeStyles(5).vardefault=[1,1,1];

StepTypeStyles(6).stepname='SineRampDown';
StepTypeStyles(6).varnumber=3;
StepTypeStyles(6).varnames={'Step Length (s)', 'Frequency (Hz)', 'Amplitude (V)'};
StepTypeStyles(6).vardefault=[1,1,1];

StepTypeStyles(7).stepname='RFPulseWaveform';
StepTypeStyles(7).varnumber=6;
StepTypeStyles(7).varnames={'Step Length (s)', 'Frequency (Hz)', 'Amplitude (V)', 'Phase (rad)', 'Rise Time (s)', 'Fall Time(s)'};
StepTypeStyles(7).vardefault=[1,1,1, 0, 0.1, 0.1];



save('StepTypeStyles.mat', 'StepTypeStyles');
clear all



