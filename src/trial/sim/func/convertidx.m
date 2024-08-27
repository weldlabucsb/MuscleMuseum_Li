function varargout = convertidx(varargin)
% Conversion between state vector index and (F,M) quantum numbers. If the number
% of inputs is 3, then the inputs should be (Fg,Fe,index), the outputs will
% be (F,M,q). Here Fg, Fe are lists of ground or excited states angular
% momentum quantum number F; q = 0 means it is the ground state, q = 1
% means it is the excited state. If the number of inputs is 5, then the
% inputs should be (Fg,Fe,F,M,q), the outputs will be the index.
Fg = varargin{1};
Fe = varargin{2};
Ng = sum(2*Fg+1);
if nargin == 3
    idx = varargin{3};
    if idx <= Ng
        q = 0;
        ii = 0;
        s = 0;
        while idx>s
            ii = ii + 1;
            s = sum(2*Fg(1:ii)+1);
        end
        F = Fg(ii);
        M = -F:1:F;
        m = M(idx-sum(2*Fg(1:ii-1)+1));
        varargout = cell(1,3);
        varargout{1} = F;
        varargout{2} = m;
        varargout{3} = q;
    else
        q = 1;
        ii = 0;
        s = Ng;
        while idx>s
            ii = ii + 1;
            s = Ng+sum(2*Fe(1:ii)+1);
        end
        F = Fe(ii);
        M = -F:1:F;
        m = M(idx-Ng-sum(2*Fe(1:ii-1)+1));
        varargout = cell(1,3);
        varargout{1} = F;
        varargout{2} = m;
        varargout{3} = q;
    end
elseif nargin == 5
    varargout = cell(1,1);
    F = varargin{3};
    m = varargin{4};
    q = varargin{5};
    M = -F:1:F;
    mi = find(M==m);
    if q == 0
        fi = find(Fg==F);
        varargout{1} = sum(2*Fg(1:fi-1)+1) + mi;
    elseif q==1
        fi = find(Fe==F);
        varargout{1} = Ng+sum(2*Fe(1:fi-1)+1) + mi;
    end
end
end

