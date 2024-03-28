atom = Alkali("Lithium7");
cycFreq = atom.CyclerFrequency;
sList = atom.D2.StateList;
masterFreq = (sList.Energy(1) + sList.Energy(16)) / 2 - ...
    (sList.Energy(17) + sList.Energy(24)) / 2 - 70e6;
motcdpFreq = masterFreq - 209.75e6 * 2;
imgniFreq = motcdpFreq - 90e6 + 74.4e6;
disp(((imgniFreq - cycFreq)/1e6 - 784.699) / (-1.6248))

disp((sList.Energy(16) - sList.Energy(1)) / 2 / 1e6 / 1.6248)