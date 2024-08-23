function fixedphase = fixPhase(phase,boundary,boundaryVal,ref)
if nargin == 4
    phase = phase - phase(ref)+boundaryVal;
end
phase(1:boundary) = boundaryVal;
phase(boundary+1:end) = phase(boundary+1:end) - phase(boundary+1)+boundaryVal;
nx = numel(phase);
for ii = 2:nx
    dtest = [phase(ii),phase(ii)+2*pi,phase(ii)+4*pi,phase(ii)-2*pi,phase(ii)-4*pi,phase(ii)+4*pi];
    [~,idx] = min(abs(phase(ii-1)-dtest));
    phase(ii) = dtest(idx);
end
fixedphase = phase;
% fixedphase(abs(pop)<th) = boundary;
end

