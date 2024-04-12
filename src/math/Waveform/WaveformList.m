classdef WaveformList < handle
    %WAVEFORMLIST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SamplingRate double % In Hz
        ConcatMethod string {mustBeMember(ConcatMethod,{'Sequential','Simultaneous'})} = "Sequential"
        PatchMethod string {mustBeMember(PatchMethod,{'Continue','Constant'})} = "Continue"
        PatchConstant double = 0
        IsTriggerAdvance logical = false
        WaveformOrigin cell
    end

    properties (Dependent)
        TimeStep
        RepeatMode string
        WaveformPrepared Table
    end
    
    methods
        function obj = WaveformList()
            
        end

        function dt = get.TimeStep(obj)
            dt = 1/obj.SamplingRate;
        end

        function rM = get.RepeatMode(obj)
            if obj.IsTriggerAdvance
                rM = "RepeatTilTrigger";
            else
                rM = "Repeat";
            end
        end

        function t = get.WaveformPrepared(obj)
            %% Check waveform origin
            if isempty(obj.WaveformOrigin)
                return
            else
                nWave = numel(obj.WaveformOrigin);
                if nWave == 0
                    return
                end
            end

            %% Set sampling rate
            for ii = 1:nWave
                obj.WaveformOrigin{ii}.SamplingRate = obj.SamplingRate;
            end

            %% Initialization
            sampleIdx = 0;
            NRepeat = double.empty;
            Sample = cell(1,1);
            PlayMode = string.empty;
            
            %% Construct waveform sequence from segments
            switch obj.ConcatMethod
                case "Sequential"      
                    for ii = 1:nWave
                        sampleIdx = sampleIdx + 1;
                        if isa(obj.WaveformOrigin{ii},"PeriodicWaveform")
                            if isa(obj.WaveformOrigin{ii},"ConstantWave")
                                obj.WaveformOrigin{ii}.Frequency = obj.SamplingRate;
                            end
                            Sample{sampleIdx} = obj.WaveformOrigin{ii}.SampleOneCycle;
                            NRepeat(sampleIdx) = obj.WaveformOrigin{ii}.NRepeat;
                            PlayMode(sampleIdx) = obj.RepeatMode;

                            sExtra = obj.WaveformOrigin{ii}.SampleExtra;
                            if (~isempty(sExtra)) && (~obj.IsTriggerAdvance)
                                sampleIdx = sampleIdx + 1;
                                Sample{sampleIdx} = sExtra;
                                NRepeat(sampleIdx) = 1;
                                PlayMode(sampleIdx) = "Repeat";
                            end
                        elseif isa(obj.WaveformOrigin{ii},"PartialPeriodicWaveform")
                            sBefore = obj.WaveformOrigin{ii}.SampleBefore;
                            if ~isempty(sBefore)
                                Sample{sampleIdx} = sBefore;
                                NRepeat(sampleIdx) = 1;
                                PlayMode(sampleIdx) = "Repeat";
                                sampleIdx = sampleIdx + 1;
                            end

                            Sample{sampleIdx} = obj.WaveformOrigin{ii}.SampleOneCycle;
                            NRepeat(sampleIdx) = obj.WaveformOrigin{ii}.NRepeat;
                            PlayMode(sampleIdx) = obj.RepeatMode;

                            sAfter = obj.WaveformOrigin{ii}.SampleAfter;
                            if ~isempty(sAfter)
                                sampleIdx = sampleIdx + 1;
                                Sample{sampleIdx} = sAfter;
                                NRepeat(sampleIdx) = 1;
                                PlayMode(sampleIdx) = "Repeat";
                            end
                        else
                            Sample{sampleIdx} = obj.WaveformOrigin{ii}.Sample;
                            NRepeat(sampleIdx) = 1;
                            PlayMode(sampleIdx) = obj.RepeatMode;
                        end
                    end
                case "Simultaneous"
                    intervalList = zeros(nWave,2);
                    for ii = 1:nWave
                        intervalList(ii,1) = obj.WaveformOrigin{ii}.StartTime;
                        intervalList(ii,2) = obj.WaveformOrigin{ii}.EndTime;
                    end
                    [unionList,unionLimit,patchLimit] = findIntervalUnion(intervalList);
                    dt = obj.TimeStep;
                    nUnion = numel(unionList);
                    for jj = 1:nUnion
                        sampleIdx = sampleIdx + 1;
                        t = unionLimit(jj,1) : dt : unionLimit(jj,2);
                        sample = zeros(1,numel(t));
                        for kk = 1:numel(unionList{jj})
                            tFunc = obj.WaveformOrigin{unionList{jj}(kk)}.TimeFunc;
                            sample = sample + tFunc(t);
                        end
                        Sample{sampleIdx} = sample;
                        NRepeat(sampleIdx) = 1;
                        PlayMode(sampleIdx) = obj.RepeatMode;
                        if jj ~= nUnion
                            sampleIdx = sampleIdx + 1;
                            switch obj.PatchMethod
                                case "Constant"
                                    patchConstant = obj.PatchConstant;
                                case "Continue"
                                    patchConstant = sample(end);
                            end
                            tPatch = patchLimit(jj,2) - patchLimit(jj,1);
                            Sample{sampleIdx} = repmat(patchConstant,1,10);
                            NRepeat(sampleIdx) = floor(tPatch / dt / 10);
                            PlayMode(sampleIdx) = obj.RepeatMode;
                        end
                    end
            end
            Sample = Sample.';
            PlayMode = PlayMode.';
            NRepeat = NRepeat.';
            t = table(Sample,PlayMode,NRepeat);
        end
        
    end
end

