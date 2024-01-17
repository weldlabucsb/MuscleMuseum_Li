setTestConfig
atom = Alkali("Lithium7");

niB = 543.6e-4;
bField = MagneticField(bias=[0;0;niB]);
bField = {bField};
stateList = atom.D2.BiasDressedStateList(bField{1});


freq = atom.CyclerFrequency ...
    + stateList(stateList.F==3 & stateList.MF==3 & stateList.IsExcited == true,:).EnergyShift ...
    - stateList(stateList.F==2 & stateList.MF==2 & stateList.IsExcited == false,:).EnergyShift;
Isat = atom.CyclerSaturationIntensity;

nL = 1;
sList = linspace(0.01,0.5,nL);
laser = cell(1,nL);
angle = 0;
for ii = 1:nL
laser{ii} = Laser( ...
    frequency = freq,...
    direction = [0,0,1],...
    polarization = sphericalBasis(-1),...
    intensity = sList(ii)*Isat ...
    );
laser{ii}.rotateToAngle([angle/180*pi,0]);
end

fRot = freq;

psi = zeros(atom.D2.NNState,1);
psi(stateList(stateList.F==2 & stateList.MF==2 & stateList.IsExcited == false,:).Index) = 1;
ic = InitialCondition("MeSim");
ic.WaveFunction = psi;

me = MeSim("crossSectionLi7",...
    initialCondition=ic,...
    laser=laser,...
    magneticField=bField,...
    rotatingFrequency=fRot,...
    totalTime = 0.1e-6);
me.start
