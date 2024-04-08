classdef WaveformList < handle
    %WAVEFORMLIST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SamplingRate double % In Hz
        ConcatMethod string {mustBeMember(ConcatMethod,{'Sequential','Simultaneous'})} = "Sequential"
        PatchMathod string {mustBeMember(PatchMathod,{'Continue','Constant'})} = "Continue"
        PatchConstant double = 0
        IsTriggerAdvance logical = false
        WaveformOrigin cell
    end

    properties (Dependent)
        WaveformPrepared Table
    end
    
    methods
        function obj = WaveformList()
            
        end

        function t = get.WaveformPrepared(obj)
            nWave = numel(obj.WaveformOrigin);
            if nWave == 0
                return
            end

            Sample = cell(nWave,1);
            if ~obj.IsTriggerAdvance
                PlayMode = repmat("Repeat",nWave,1);
            else
                PlayMode = repmat("RepeatTilTrigger",nWave,1);
            end
            NRepeat = zeros(nWave,1);
            % timeList = zeros(nWave,2);
            switch obj.ConcatMethod
                case "Sequential"
                    for ii = 1:nWave
                        obj.WaveformOrigin{ii}.SamplingRate = obj.SamplingRate;
                        if isa(obj.WaveformOrigin{ii},"PeriodicWaveform")
                            Sample{ii} = obj.WaveformOrigin{ii}.SampleOneCycle;
                            if ~obj.IsTriggerAdvance
                                NRepeat(ii) = obj.WaveformOrigin{ii}.NRepeat;
                            else
                                NRepeat(ii) = 1e6;
                            end
                        else
                            Sample{ii} = obj.WaveformOrigin{ii}.Sample;
                            if ~obj.IsTriggerAdvance
                                NRepeat(ii) = 1;
                            else
                                NRepeat(ii) = 1e6;
                            end
                        end
                    end
            end
            t = table(Sample,PlayMode,NRepeat);
        end
        
    end
end

