function fitResult = fitSine(varargin)
t = varargin{1};
centers = varargin{2};

fitfun  = fittype(@(a,phi,omega,c,t) a.*sin(omega.*t+phi)+c,'independent',{'t'});
options = fitoptions(fitfun);
if nargin == 3
    omega = varargin{3};
    options.StartPoint = [100,pi,omega,512];
    options.Lower = [0,0,omega,0];
    options.Upper = [512,2*pi,omega,1022];
else
    options.StartPoint = [100,pi,2*pi*5e-3,512];
    options.Lower = [0,0,2*pi*1e-3,0];
    options.Upper = [512,2*pi,2*pi*20e-3,1022];
end

t = reshape(t,[],1);
centers = reshape(centers,[],1);
fitResult = fit(t,centers,fitfun,options);
end

