classdef GaussianFit1D < FitData1D
    %GAUSSIANFIT1D Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = GaussianFit1D(rawData)
            %GAUSSIANFIT1D Construct an instance of this class
            %   Detailed explanation goes here
            obj@FitData1D(rawData)
            obj.Func = fittype('A*exp(-(x-x0)^2/(2*sigma^2))+C','independent', {'x'},...
        'coefficients', {'A', 'x0', 'sigma','C'});
            x = rawData(:,1);
            y = rawData(:,2);

            % Offset guess
            if length(y)>50
                guessOffset=mean([y(1:20);y(end-19:end)]);
            else
                guessOffset=min(y);
            end

            % Amplitude guess
            guessAmplitude = max(y) - guessOffset;
            
            % Center guess
            guessCenter = median(x(y>0.5*max(y)));

            % Standard deviation guess
            guessStandardDeviation = (max(x) - min(x))/30;

            obj.StartPoint = [guessAmplitude,guessCenter,guessStandardDeviation,guessOffset];
            obj.Lower = [0, min(x), 0, min(y) - 0.05 * guessAmplitude];
            obj.Upper = [1.5 * guessAmplitude, max(x), (max(x) - min(x))*.25, 5*abs(min(y))];
            
        end
        
    end
end

