function nSpaceStep = getNSpaceStep(spaceRange,spaceStep)
%GETNSPACESTEP Summary of this function goes here
%   Detailed explanation goes here
nSpaceStep = spaceRange ./ spaceStep;
nSpaceStep = 2.^(ceil(log2(nSpaceStep)));
end

