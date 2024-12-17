function l = plotWavyLine(pt1, pt2, ax)
arguments
    pt1 (1,2) double
    pt2 (1,2) double
    ax = gca
end
% first, create a "unit" wavy line segment
xx = 0:.001:1;
reps = 10; % how many periods of sine you want
widthRatio = 0.1; % height of peaks / lenght of line
yy = (widthRatio/2)*sin(reps*xx*2*pi);

% stretch our unit wavy line to be the proper length
dx = pt2(1) - pt1(1);
dy = pt2(2) - pt1(2);
len = sqrt(dx*dx+dy*dy);
xx = len*xx;

% now rotate it
th = atan2(dy, dx);
R = [cos(th), -sin(th); sin(th), cos(th)];
rotatedPts = R * [xx;yy];

% finally, shift it to start at pt1, and plot
shiftedPts = rotatedPts + [pt1(1); pt1(2)] * ones(size(xx));

l = plot(ax,shiftedPts(1,:), shiftedPts(2,:),'k');

end