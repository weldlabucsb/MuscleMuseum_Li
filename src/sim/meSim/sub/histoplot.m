function histoplot(bins,varargin)
nn = numel(varargin);
n = cell(1,nn);
e = n;
c = n;
plist = cell(1,nn*2);
for ii = 1:nn
[n{ii},e{ii}] = histcounts(varargin{ii},bins,'Normalization','count');
c{ii} = (e{ii}(1:end-1)+e{ii}(2:end))./2;
plist{ii*2-1} = c{ii};
plist{ii*2} = n{ii};
end
plot(plist{:})
end

