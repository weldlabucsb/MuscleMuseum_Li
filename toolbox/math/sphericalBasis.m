function eVec = sphericalBasis(q)
%SPHERICALBASIS Summary of this function goes here
%   Detailed explanation goes here
switch q
    case 1
        eVec = -[1; 1i; 0]/sqrt(2);
    case 0
        eVec = [0; 0; 1];
    case -1
        eVec = [1; -1i; 0]/sqrt(2);
    otherwise
        error('Input must be +1, 0, or -1')
end

