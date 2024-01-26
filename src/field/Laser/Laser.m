classdef Laser < matlab.mixin.Heterogeneous & handle
    %Specify the laser parameters. 
    
    properties
        Wavelength (1,1) double = NaN %In meter
        Frequency (1,1) double = NaN %Absolute frequency in Hz. Linear frequency
        Polarization (3,1) double = [NaN;NaN;NaN]
        Phase (1,1) double = 0 %In radians
        Direction (3,1) double = [NaN;NaN;NaN]
        Angle (1,2) double = [NaN,NaN] %[Polar angle theta, Azimth angle phi] in radians
        Intensity double = NaN %In W/m^2
        Power double = NaN %In Watts
    end

    properties (Dependent)
        Wavenumber
        Wavevector
        AngularFrequency
        AngularWavenumber
        AngularWavevector
        WavelengthInAir
        IntensityLu %Intensity in mW/cm^2
        ElectricFieldAmplitude
    end
    
    methods
        
        function obj = Laser(options)
            arguments
                options.frequency = NaN
                options.wavelength = NaN
                options.polarization = [NaN;NaN;NaN]
                options.phase = 0
                options.direction = [NaN;NaN;NaN]
                options.angle = [NaN,NaN]
                options.intensity = NaN
                options.power = NaN
            end
            if ~isnan(options.frequency)
                obj.Frequency = options.frequency;
            elseif ~isnan(options.wavelength)
                obj.Wavelength = options.wavelength;
            end
            obj.Polarization = options.polarization;
            obj.Phase = options.phase;
            if ~isnan(options.direction)
                obj.Direction = options.direction;
            elseif ~isnan(options.angle)
                obj.Angle = options.angle;
            end
            obj.Intensity = options.intensity;
            obj.Power = options.power;
        end
        function obj = set.Frequency(obj,val)
            if (abs(val - obj.Frequency)>eps || any(isnan(obj.Frequency)) )&& ~isnan(val)
                 obj.Frequency = val;
                 obj.Wavelength = Constants.SI("c")/val;
            end
        end
        function obj = set.Wavelength(obj,val)
            if (abs(val - obj.Wavelength)>eps || any(isnan(obj.Wavelength)) ) && ~isnan(val)
                 obj.Wavelength = val;
                 obj.Frequency = Constants.SI("c")/val;
            end
        end
        function obj = set.Polarization(obj,val)
            obj.Polarization = val / vecnorm(val);
        end
        function obj = set.Direction(obj,val)
            val = val / vecnorm(val);
            if (~all(abs(obj.Direction - val)<eps) || any(isnan(obj.Direction)) ) && all(~isnan(val))
                obj.Direction = val;
                [azimuth,elevation,~] = cart2sph(val(1),val(2),val(3));
                obj.Angle = [pi/2-elevation,azimuth];
            end
        end
        function obj = set.Angle(obj,val)
            if (~all(abs(obj.Angle - val)<eps) || any(isnan(obj.Angle)) ) && all(~isnan(val))
                obj.Angle = val;
                [x,y,z] = sph2cart(val(2),pi/2-val(1),1);
                obj.Direction = [x,y,z];
            end
        end
        function obj = set.Power(obj,val)
            if (abs(val - obj.Power)>eps || isnan(obj.Power) ) && ~isnan(val)
                obj.Power = val;
                if class(obj) == "GaussianBeam"
                    obj.Intensity = 2 * obj.Power / obj.Waist(1) / obj.Waist(2) / pi;
                end
            end
        end
        function obj = set.Intensity(obj,val)
            if (abs(val - obj.Intensity)>eps || isnan(obj.Intensity) ) && ~isnan(val)
                obj.Intensity = val;
                if class(obj) == "GaussianBeam"
                    obj.Power = pi * obj.Intensity * obj.Waist(1) * obj.Waist(2) / 2;
                end
            end
        end
        function lambdaAir = get.WavelengthInAir(obj)
            lambdaAir = obj.Wavelength/1.000293;
        end
        function nu = get.Wavenumber(obj)
            nu = 1/obj.Wavelength;
        end
        function k = get.AngularWavenumber(obj)
            k = obj.Wavenumber * 2 * pi;
        end
        function omega = get.AngularFrequency(obj)
            omega = obj.Frequency * 2 * pi;
        end
        function nuVec = get.Wavevector(obj)
            nuVec = obj.Wavenumber * obj.Direction;
        end
        function kVec = get.AngularWavevector(obj)
            kVec = obj.Wavevector * 2 * pi;
        end
        function I = get.IntensityLu(obj)
            I = obj.Intensity / 10;
        end
        function E = get.ElectricFieldAmplitude(obj)
            E = sqrt(obj.Intensity * 2 * Constants.SI("Z0"));
        end
        function obj = rotate(obj,eul)
            rotm = eul2rotm(eul,"ZYZ");
            dir = obj.Direction;
            dir = dir(:);
            dir = rotm * dir;
            obj.Direction = reshape(dir,size(obj.Direction));
            pol = obj.Polarization;
            pol = pol(:);
            pol = rotm * pol;
            obj.Polarization = reshape(pol,size(obj.Polarization));
        end
        function obj = rotateToAngle(obj,angle)
            oldAngle = obj.Angle;
            rotm = eul2rotm([angle(2),angle(1),0],"ZYZ") * ...
                (eul2rotm([oldAngle(2),oldAngle(1),0],"ZYZ"))^(-1);
            dir = obj.Direction;
            dir = dir(:);
            dir = rotm * dir;
            obj.Direction = reshape(dir,size(obj.Direction));
            pol = obj.Polarization;
            pol = pol(:);
            pol = rotm * pol;
            obj.Polarization = reshape(pol,size(obj.Polarization));
        end
        function func = spacePhaseFunc(obj)
            kvec = obj.AngularWavevector;
            phase = obj.Phase;
            func = @(r) spacePhase(r);
            function out = spacePhase(r)
                out = exp(1i*(phase - kvec.'*r(:)));
            end
        end
        function func = timePhaseFunc(obj)
            omega = obj.AngularFrequency;
            func = @(t) timePhase(t);
            function out = timePhase(t)
                out = exp(1i*(omega*t));
            end
        end
        function func = spaceTimePhaseFunc(obj)
            omega = obj.AngularFrequency;
            kvec = obj.AngularWavevector;
            phase = obj.Phase;
            func = @(r,t) spacePhase(r,t);
            function out = spacePhase(r,t)
                out = exp(1i*(omega*t + phase - kvec.'*r(:)));
            end
        end
    end
end

