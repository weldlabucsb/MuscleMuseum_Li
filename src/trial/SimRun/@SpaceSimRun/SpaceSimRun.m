classdef (Abstract) SpaceSimRun < SimRun
    %SPACESIMRUN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SpaceOrigin double = [0;0;0] % in meters
        SpaceRange double {mustBePositive} % in meters
        NSpaceStep double {mustBePositive,mustBeInteger}
        BoundaryCondition string {mustBeMember(BoundaryCondition,{'Periodic','Dirichlet','Neumann'})} = "Periodic"
    end

    properties (SetAccess = protected)
        Dimension (1,1) double {mustBeInteger,mustBeInRange(Dimension,1,3)} = 1
    end

    properties (Dependent)
        SpaceStep
        SpaceList
        SpaceAngularFrequencyStep % for fft
        SpaceAngularFrequencyList % for fft
    end
    
    methods
        function obj = SpaceSimRun(spaceSim)
            %SPACESIMRUN Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                spaceSim = []
            end
            obj@SimRun(spaceSim)
            if ~isempty(spaceSim)
                if isa(spaceSim,"SpaceSim")
                    obj.SpaceOrigin = spaceSim.SpaceOrigin;
                    obj.SpaceRange = spaceSim.SpaceRange;
                    obj.NSpaceStep = spaceSim.NSpaceStep;
                    obj.Dimension = spaceSim.Dimension;
                else
                    error("Input must be an object of the SpaceSim class")
                end
            end
        end

        function obj = set.NSpaceStep(obj,val)
            % Number of steps must be an odd number
            if mod(val,2) ~= 0
                val = val + 1;
            end
            if mod(log2(val),1)~=0
                warning("# of spatial steps is not a power of 2. A power of 2 step number " + ...
                    "can enhance fft performance.")
            end
            obj.NSpaceStep = val;
        end

        function sList = get.SpaceList(obj)
            origin = obj.SpaceOrigin;
            sRange = obj.SpaceRange;
            NN = obj.NSpaceStep;
            switch obj.Dimension
                case 1
                    sList = origin(1) + linspace(-sRange(1)/2, sRange(1)/2, NN(1));
                case 2
                    sListX = origin(1) + linspace(-sRange(1)/2, sRange(1)/2, NN(1));
                    sListY = origin(2) + linspace(-sRange(2)/2, sRange(2)/2, NN(2));
                    sList = {sListX;sListY};
                case 3
                    sListX = origin(1) + linspace(-sRange(1)/2, sRange(1)/2, NN(1));
                    sListY = origin(2) + linspace(-sRange(2)/2, sRange(2)/2, NN(2));
                    sListZ = origin(3) + linspace(-sRange(3)/2, sRange(3)/2, NN(3));
                    sList = {sListX;sListY;sListZ};
            end
        end

        function spaceStep = get.SpaceStep(obj)
            switch obj.Dimension
                case 1
                    spaceStep = obj.SpaceList(2) - obj.SpaceList(1);
                case 2
                    spaceStep = cellfun(@(x) x(2) - x(1),obj.SpaceList);
                case 3
                    spaceStep = cellfun(@(x) x(2) - x(1),obj.SpaceList);
            end
        end

        function kList = get.SpaceAngularFrequencyList(obj)
            NN = obj.NSpaceStep;
            step = obj.SpaceStep;
            switch obj.Dimension
                case 1
                    kList = 2 * pi * [0:NN(1)/2-1 -NN(1)/2:-1]/NN(1)/step(1);
                case 2
                    kListx = 2 * pi * [0:NN(1)/2-1 -NN(1)/2:-1]/NN(1)/step(1);
                    kListy = 2 * pi * [0:NN(2)/2-1 -NN(2)/2:-1]/NN(2)/step(2);
                    kList = {kListx;kListy};
                case 3
                    kListx = 2 * pi * [0:NN(1)/2-1 -NN(1)/2:-1]/NN(1)/step(1);
                    kListy = 2 * pi * [0:NN(2)/2-1 -NN(2)/2:-1]/NN(2)/step(2);
                    kListz = 2 * pi * [0:NN(3)/2-1 -NN(3)/2:-1]/NN(3)/step(3);
                    kList = {kListx;kListy;kListz};
            end
        end

        function kStep = get.SpaceAngularFrequencyStep(obj)
            switch obj.Dimension
                case 1
                    kStep = obj.SpaceAngularFrequencyList(2) - obj.SpaceAngularFrequencyList(1);
                case 2
                    kStep = cellfun(@(x) x(2) - x(1),obj.SpaceAngularFrequencyList);
                case 3
                    kStep = cellfun(@(x) x(2) - x(1),obj.SpaceAngularFrequencyList);
            end
        end
        
    end
end

