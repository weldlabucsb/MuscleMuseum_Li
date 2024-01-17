classdef GaussianBeam < Laser
    %PLANEWAVE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Waist (2,1) double = [NaN;NaN] %In meters
        Center (3,1) double = [0;0;0] %In meters
    end
    
    properties(Dependent)
       RayleighRange %In meters
       IntensityAveraged %In W/m^2
    end
    
    methods
        function obj = GaussianBeam(options1,options2)
            arguments
                options1.waist = [NaN;NaN]
                options1.center = [0;0;0]
                options2.frequency = NaN
                options2.wavelength = NaN
                options2.polarization = [NaN;NaN;NaN]
                options2.phase = 0
                options2.direction = [NaN;NaN;NaN]
                options2.intensity = NaN
                options2.power = NaN
            end
            varargin = struct2pairs(options2);
            obj@Laser(varargin{:})
            obj.Waist = options1.waist;
            obj.Center = options1.center;
            if ~isnan(obj.Intensity)
                obj.Power = pi * obj.Intensity * obj.Waist(1) * obj.Waist(2) / 2;
            elseif ~isnan(obj.Power)
                obj.Intensity = 2 * obj.Power / obj.Waist(1) / obj.Waist(2) / pi;
            end
        end
        function zR = get.RayleighRange(obj)
            zR = pi * obj.Waist(1) * obj.Waist(2) / obj.Wavelength;
        end
        function I = get.IntensityAveraged(obj)
           I = obj.Power/obj.Waist(1)/obj.Waist(2)/pi;
        end
    end
end

