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
            guessOffset=(max(y) + min(y))/2;

            % Amplitude guess
            guessAmplitude = (max(y) - min(y))/2;

            % Frequency guess
            dx = max(abs(diff(sort(x))));
            dYdX = diff(y) / dx;
            guessFrequency = (max(dYdX) - min(dYdX)) / 4 / pi / guessAmplitude;
            % guessFrequency = 1 / (max(x) - min(x));

            % Phase guess
            guessPhase = mod(pi/2 - 2 * pi * guessFrequency * x(y==max(y)),2 * pi);

            obj.StartPoint = [guessAmplitude,guessFrequency,guessPhase,guessOffset];
            obj.Lower = [0.5 * guessAmplitude, guessFrequency / 3, 0, guessOffset - 0.3 * guessAmplitude];
            obj.Upper = [2 * guessAmplitude, 3 * guessFrequency, 2 * pi, guessOffset + 0.3 * guessAmplitude];

        end

    end
end

