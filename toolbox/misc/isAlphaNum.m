function isAN = isAlphaNum(c)
%ISALPHANUM Check if the input string only has alphabatic and numerical
%characters
%   Detailed explanation goes here
if isstring(c)
    TF = isstrprop(c,'alphanum');
    isAN = all(TF);
else
    error('input is not a string')
end

