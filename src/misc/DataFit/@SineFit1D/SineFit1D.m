classdef SineFit1D < FitData1D
    %GAUSSIANFIT1D Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = SineFit1D(rawData)
            %GAUSSIANFIT1D Construct an instance of this class
            %   Detailed explanation goes here
            obj@FitData1D(rawData)
            obj.Func = fittype('A * sin(2 * pi * f * x + phi) + C','independent', {'x'},...
        'coefficients', {'A', 'f', 'phi','C'});
            x = rawData(:,1);
            y = rawData(:,2);

            % Offset guess
            guessOffset=mean(y);

            % Amplitude guess
            guessAmplitude = (max(y) - min(y))/2;
            
            % Phase guess
            guessPhase = 0;

            % Frequency guess
            guessFrequency = 1 / (max(x) - min(x));

            obj.StartPoint = [guessAmplitude,guessFrequency,guessPhase,guessOffset];
            obj.Lower = [0, 0, -pi, min(y)];
            obj.Upper = [2.5 * guessAmplitude, 20 * guessFrequency, pi, max(y)];
            
        end
        
    end
end

