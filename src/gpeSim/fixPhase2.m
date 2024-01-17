function fixedphase = fixPhase2(phase,boundary,boundaryVal,ref)
if nargin == 4
    phase = phase - phase(ref)+boundaryVal;
end
phase(boundary:end) = boundaryVal;
nx = numel(phase);
for ii = nx-1:-1:1
    dtest = [phase(ii),phase(ii)+2*pi,phase(ii)+4*pi,phase(ii)-2*pi,phase(ii)-4*pi,phase(ii)+4*pi];
    [~,idx] = min(abs(phase(ii+1)-dtest));
    phase(ii) = dtest(idx);
end
fixedphase = phase;
% fixedphase(abs(pop)<th) = boundary;
end

