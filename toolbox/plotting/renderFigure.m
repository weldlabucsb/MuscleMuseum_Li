function fig = renderFigure(figNumber,windowSize,position)
%RENDERFIGURE Summary of this function goes here
%   Detailed explanation goes here
close(figure(figNumber))
fig = figure(figNumber);
fig.OuterPosition = [600 200 windowSize];
movegui(position)
% iPdefault = fig.InnerPosition;
% fig.InnerPosition = [iPdefault(1) 200 iPdefault(3) iPdefault(4)-200];

end

