classdef (ConstructOnLoad = true) dropshadow < hgsetget
%DROPSHADOW Adds a dropshadow to plot objects.
%   ShadowObj = DROPSHADOW(hAxes) creates a dropshadow object for the plot
%   objects in the specified axes. The shadow image is rendered using 2D 
%   convolution of a Gaussian kernel based on the properties Color, Angle, 
%   Distance, Spread and Size. The original plot objects are kept, such 
%   that the figure can still be exported to a vector graphics format such 
%   as EPS or PDF.
%
%   ShadowObj = DROPSHADOW(hAxes,'Prop1',Value1,...) Creates the dropshadow
%   and sets the specified properties.
%
%   The dropshadow object is updated whenever a change is made to one of 
%   the properties below. The object is deleted upon axes deletion.
%
%   Note that the shadow is always put as a 2D image in the background of
%   the plot axes, regardless of 3D rotations.
%
%   DROPSHADOW Properties:
%       Angle       - Angle of lighting.
%       Color       - Shadow color.
%       Distance    - Distance from plot objects in pixels.
%       Size        - Size (Gaussian standard deviation) in pixels.
%       Spread      - Spread in pixels.
%       ParentAxes  - Axes to which the dropshadow object is linked.
%
%   DROPSHADOW Methods:
%       delete      - Delete the shadow object from the axes.
%       repaint     - Repaint the shadow.
%       revalidate  - Take a new snapshot and repaint the shadow.
%       update      - Alias for revalidate method.
%
%   Example:
%       x = 0:0.1:10;
%       y1 = sin(x)+cos(2*x);
%       y2 = y1+(0.5-rand(size(x)));
%       plot(x,y1,'b','LineWidth',2); hold on
%       plot(x,y2,'r','LineWidth',2);
%       drawnow, pause(0.5) % Wait for figure to be drawn
%       hDrop = dropshadow(gca,'Size',4,'Spread',2,'Distance',5);
%
%   Written by: Maarten van der Seijs, 2012.
%   Version 1.0.

    properties (SetObservable)
        Color = [0.5 0.5 0.5];      %Shadow color.
        Angle = 135;                %Angle of lighting.
        Distance = 3;               %Shadow distance in pixels.
        Spread = 2;                 %Shadow spread in pixels.
        Size = 3;                   %Shadow size (Gaussian standard deviation) in pixels.
    end
    
    properties (SetAccess = private)
        ParentAxes                  %Parent axes handle.
    end

    properties (SetAccess = private, Transient = true, Hidden = true)
        ParentFig                   %Parent figure handle.
        ShadowAxes                  %Shadow axes handle.
        ShadowImage                 %Shadow image handle.
    end
    
    properties (Hidden = true)
        SnapMethod = 'robot';       %Undocumented feature, see snapshot method.
    end    
    
    properties (Access = private, Transient = true)
        B                           %Monochrome image
        D                           %Dropshadow CData
        G                           %Gaussian kernel
    end
    
    properties (Hidden = true, Transient = true)
        listeners = struct;
    end
    
    %% Constructor
    methods
        function obj = dropshadow(h,varargin)
        %Creates the dropshadow object.            
            if ~nargin
                h = gca;
            end
            
            % Check for valid handles
            assert(isa(handle(h),'axes'),'Parent must be an axes handle.')

            % Handle an array of axes
            if ~isscalar(h)
                [N,M] = size(h);
                obj(N,M) = dropshadow(h(end),varargin{:});
                for n = 1:(N*M-1)
                    obj(n) = dropshadow(h(n),varargin{:});
                end
                return
            end
           
            % Link axes
            obj.ParentAxes = h;
            
            % Set properties
            if nargin > 1
                set(obj,varargin{:})
            end
            
            % Add listeners to object properties
            addlistener(obj,{'Color','Angle','Distance','Spread','Size'},'PostSet',@(~,~) obj.repaint);
            
            % Add listeners to axes
            obj.listeners.ObjectBeingDestroyed = handle.listener(h, 'ObjectBeingDestroyed', @(~,~) delete(obj));            

            % Paint
            obj.snapshot;
            obj.repaint;
        
        end
    end
    
    
    %% GET methods
    methods
        function ParentFig = get.ParentFig(obj)
            ParentFig = ancestor(obj.ParentAxes,'figure');
        end
    end

    %% SET methods
    methods
        function set.SnapMethod(obj,SnapMethod)
            obj.SnapMethod = validatestring(SnapMethod,{'robot','getframe'});
        end
    end
    
    
    %% Private methods
    methods (Access = private)
        function snapshot(obj)

            % Delete old dropshadow axes
            h_old = findobj(obj.ParentFig,'type','axes','tag','dropshadowaxes','UserData',obj.ParentAxes);
            delete(h_old)
            
            % Prepare axes for snapshot
            oldcolor = get(obj.ParentFig,'color');
            oldaxesvisible = get(obj.ParentAxes,'visible');
            
            % Prepare figure 
            set(obj.ParentFig,'color','w')
            set(obj.ParentAxes,'visible','off')

            switch obj.SnapMethod
                case 'getframe'
                    % Use MATLAB internal GETFRAME function. May need
                    % temporary repositioning of the figure.
                    oldposition = get(obj.ParentFig,'position');
                    oldwindowstyle = get(obj.ParentFig,'windowstyle');
                    set(obj.ParentFig,'windowstyle','normal')
                    movegui(obj.ParentFig,'onscreen') % Make sure figure is on the first screen
                    drawnow, pause(0.05)
                    
                    % Make snapshot of figure
                    Frame = getframe(obj.ParentAxes);                    
                    CData = Frame.cdata;
                    
                    % Generate monochrome image
                    [w, h, ~] = size(CData);
                    obj.B = zeros(w,h);
                    back = [255 255 255];
                    for xi = 1:w
                        for yi = 1:h
                            obj.B(xi,yi) = ~((CData(xi,yi,1) == back(1)) && ...
                                (CData(xi,yi,2) == back(2)) && ...
                                (CData(xi,yi,3) == back(3)));
                        end
                    end
                    
                    % Move figure back to original position
                    set(obj.ParentFig,'position',oldposition,'windowstyle',oldwindowstyle)
                    
                case 'robot'
                    % Use java.awt.Robot
                    obj.B = getaxesframe(obj);
                    
            end
            
            % Restore figure
            set(obj.ParentFig,'color',oldcolor)
            set(obj.ParentAxes,'visible',oldaxesvisible)            
            drawnow
            
        end
        
        function generatekernel(obj)
            m = 1 + ceil(obj.Distance + obj.Size*3);
            idxs = -m:1:m;
            
            mu_x = -cosd(obj.Angle)*obj.Distance + 0.5;
            mu_y = sind(obj.Angle)*obj.Distance + 0.5;
            
            gaussfun = @(x,mu,sigma) exp(-(x-mu).^2./(2*sigma^2));
            g_x = sqrt(obj.Spread)/(obj.Size*sqrt(2*pi)) .* gaussfun(idxs,mu_x,obj.Size);
            g_y = sqrt(obj.Spread)/(obj.Size*sqrt(2*pi)) .* gaussfun(idxs,mu_y,obj.Size);
            
            obj.G = g_y.'*g_x;            
        end
        
        function generateshadow(obj)
            % Do 2D convolution
            C = conv2(obj.B,obj.G,'same');            
                        
            % Flip and clip
            C = flipud(C);
            C(C>1) = 1;            
            
            % Generate drop CData
            obj.D = ones([size(C) 3]);
            obj.D(:,:,1) = 1-(1-obj.Color(1)).*C;
            obj.D(:,:,2) = 1-(1-obj.Color(2)).*C;
            obj.D(:,:,3) = 1-(1-obj.Color(3)).*C;
        end
        
        function paintshadow(obj)
            xl = xlim(obj.ParentAxes);
            yl = ylim(obj.ParentAxes);
            
            % Delete old dropshadow axes
            h_old = findobj(obj.ParentFig,'type','axes','tag','dropshadowaxes','UserData',obj.ParentAxes);
            delete(h_old)
            
            % Create ShadowAxes
            obj.ShadowAxes = axes('parent',gcf,'position',get(obj.ParentAxes,'position'));
            obj.ShadowImage = image(xl,yl,obj.D,'Parent',obj.ShadowAxes,'CDataMapping','direct','tag','dropshadow');
            set(obj.ShadowAxes,'YDir','normal','visible','off')
            
            % Link axes properties
            if strcmp(get(obj.ParentAxes,'DataAspectRatioMode'),'manual')
                obj.listeners.AxesLink = linkprop([obj.ParentAxes obj.ShadowAxes],{'Position', ...
                    'XLim','YLim','ZLim','DataAspectRatio','DataAspectRatioMode'});
            else
                obj.listeners.AxesLink = linkprop([obj.ParentAxes obj.ShadowAxes],{'Position', ...
                    'XLim','YLim','ZLim'});
            end

            % Set ShadowAxes properties
            set(obj.ShadowAxes,'UserData',obj.ParentAxes,'tag','dropshadowaxes')
            
            % Set ParentAxes properties
            set(obj.ParentAxes,'Color','none','XLim',xl,'YLim',yl)
            axes(obj.ParentAxes)
        end
    end
    
    %% Public methods
    methods (Access = public)        
        function repaint(objs)
        %Recalculate the shadow kernel and repaint the shadow image.
            for obj = objs
                obj.generatekernel;
                obj.generateshadow;
                obj.paintshadow;
            end
        end
        
        function revalidate(objs)
        %Take a new snapshot of the plot objects and repaint the shadow.
            for obj = objs
                obj.snapshot;
                obj.repaint;
            end
        end
        
        function update(objs)
        %Alias for revalidate method.
            revalidate(objs)
        end
        
        function delete(objs)
        %Delete the shadow object from the axes.
            for obj = objs
                try
                    obj.listeners = [];
                    delete(obj.ShadowAxes)
                    set(obj.ParentAxes,'Color','w')
                    delete@handle(obj)
                catch %#ok
                end
            end            
        end
        
    end
    
end

function B = getaxesframe(obj)
% Screen capture function adopted from:
% GETSCREEN by Matt Dash.
%
% Copyright (c) 2009, Matthew Daskilewicz
% All rights reserved.

h = obj.ParentAxes;

rect = hgconvertunits(h, get(h,'position'), get(h,'units'), 'pixels', get(h,'parent')); %x/y coords of fighandle in pixels
rect(1:2)=[1 1];

monitors=get(0,'monitorpositions');
maxheight=max(monitors(:,4)); %max vertical resolution of all monitors

origin=getpixelposition(h,true);

%also need position of the figure containing h, since origin is w.r.t this figure:
fighandle = obj.ParentFig;
figorigin = hgconvertunits(fighandle, get(fighandle,'position'), get(fighandle,'units'), 'pixels', 0); %x/y coords of fighandle in pixels

% calculate dimensions of rectangle to take screenshot of: (in java coordinates)
%java coordinates start at top left instead of bottom left, and start at [0,0]. Also "top" is defined as the top of your
%largest monitor, even if that's not the one you're taking a screenshot from.

x=figorigin(1)+origin(1)+rect(1)-3;
y=maxheight-figorigin(2)-origin(2)-rect(2)-rect(4)+4;
w=floor(rect(3))+1;
h=floor(rect(4))+1;

figure(fighandle); % Make sure figure is visible on screen
drawnow;
pause(0.05)

% Java Robot snapshot:
robo = java.awt.Robot;
target = java.awt.Rectangle(x,y,w,h);
image = robo.createScreenCapture(target);

% Get RGBA data from BufferedImage
RGBA32 = image.getRGB(0,0,w,h,[],0,w); 

% Convert Java color integers to MATLAB RGB format:
RGBA8 = typecast(RGBA32, 'uint8');

% Generate boolean image
back = uint8([255 255 255]);
B = zeros(w,h);
B(:) = ~((RGBA8(3:4:end) == back(1)) .* ...
    (RGBA8(2:4:end) == back(2)) .* ...
    (RGBA8(1:4:end) == back(3)));

B = transpose(B);

end