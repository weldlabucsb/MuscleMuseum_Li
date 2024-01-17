function errors = fitError(fitResult)
%FITERROR Summary of this function goes here
%   Detailed explanation goes here
bounds = confint(fitResult);
coeffvals = coeffvalues(fitResult);
errors = coeffvals - bounds(1,:);
end

