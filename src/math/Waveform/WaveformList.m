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
        Sample
        TimeStep
        RepeatMode string
        WaveformPrepared Table 
    end

    properties (SetAccess = protected)
        Name string
        NSample double
    end
    
    methods
        function obj = WaveformList(name,options)
            arguments
                name string
                options.samplingRate double = 1e3
                options.concatMethod string = "Sequential"
                options.patchMethod string = "Continue"
                options.patchConstant double = 0
                options.isTriggerAdvance logical = false
                options.waveformOrigin cell = {}
            end
            obj.Name = name;
            field = string(fieldnames(options));
            for ii = 1:numel(field)
                if ~isempty(options.(field(ii)))
                    obj.(capitalizeFirst(field(ii))) = options.(field(ii));
                end
            end
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
            sampleIdx = 1;
            NRepeat = double.empty;
            Sample = cell(1,1);
            PlayMode = string.empty;
            
            %% Construct waveform sequence from segments
            switch obj.ConcatMethod
                case "Sequential"
                    for ii = 1:nWave
                        if isa(obj.WaveformOrigin{ii},"PeriodicWaveform")
                            if isa(obj.WaveformOrigin{ii},"ConstantWave")
                                obj.WaveformOrigin{ii}.Frequency = obj.SamplingRate;
                            end

                            s = obj.WaveformOrigin{ii}.SampleOneCycle;
                            if ~isempty(s)
                                Sample{sampleIdx} = obj.WaveformOrigin{ii}.SampleOneCycle;
                                NRepeat(sampleIdx) = obj.WaveformOrigin{ii}.NRepeat;
                                PlayMode(sampleIdx) = obj.RepeatMode;
                                sampleIdx = sampleIdx + 1;
                            end

                            sExtra = obj.WaveformOrigin{ii}.SampleExtra;
                            if (~isempty(sExtra)) && (~obj.IsTriggerAdvance)
                                Sample{sampleIdx} = sExtra;
                                NRepeat(sampleIdx) = 1;
                                PlayMode(sampleIdx) = "Repeat";
                                sampleIdx = sampleIdx + 1;
                            end
                        elseif isa(obj.WaveformOrigin{ii},"PartialPeriodicWaveform")
                            sBefore = obj.WaveformOrigin{ii}.SampleBefore;
                            if ~isempty(sBefore)
                                Sample{sampleIdx} = sBefore;
                                NRepeat(sampleIdx) = 1;
                                PlayMode(sampleIdx) = "Repeat";
                                sampleIdx = sampleIdx + 1;
                            end
                            
                            s = obj.WaveformOrigin{ii}.SampleOneCycle;
                            if ~isempty(s)
                                Sample{sampleIdx} = obj.WaveformOrigin{ii}.SampleOneCycle;
                                NRepeat(sampleIdx) = obj.WaveformOrigin{ii}.NRepeat;
                                PlayMode(sampleIdx) = obj.RepeatMode;
                                sampleIdx = sampleIdx + 1;
                            end

                            sAfter = obj.WaveformOrigin{ii}.SampleAfter;
                            if ~isempty(sAfter)
                                Sample{sampleIdx} = sAfter;
                                NRepeat(sampleIdx) = 1;
                                PlayMode(sampleIdx) = "Repeat";
                                sampleIdx = sampleIdx + 1;
                            end
                        else
                            Sample{sampleIdx} = obj.WaveformOrigin{ii}.Sample;
                            NRepeat(sampleIdx) = 1;
                            PlayMode(sampleIdx) = obj.RepeatMode;
                            sampleIdx = sampleIdx + 1;
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
            obj.NSample = sum(cellfun(@numel,Sample));
        end

        function sample = get.Sample(obj)
            t = obj.WaveformPrepared;
            sample = [];
            for ii = 1:size(t,1)
                sample = [sample,repmat(t.Sample{ii},1,t.NRepeat(ii))];
            end
        end

        function func = TimeFunc(obj)
            %% Check waveform origin
            if isempty(obj.WaveformOrigin)
                return
            else
                nWave = numel(obj.WaveformOrigin);
                if nWave == 0
                    return
                end
            end

            %% Construct waveform time function handle
            if obj.ConcatMethod == "Sequential"
                ti = obj.WaveformOrigin{1}.StartTime;
                for ii = 2:nWave
                    ti = ti + obj.WaveformOrigin{ii-1}.Duration;
                    obj.WaveformOrigin{ii}.StartTime = ti;
                end
            end
            funcList = cell(1,nWave);
            for ii = 1:nWave
                funcList{ii} = obj.WaveformOrigin{ii}.TimeFunc;
            end
            function out = timeFunc(t)
                out = 0;
                for jj = 1:nWave
                    out = out + funcList{jj}(t);
                end
            end
            func = @(t) timeFunc(t);
        end

        function plot(obj)
            dt = obj.TimeStep;
            sample = obj.Sample;
            time = 0:(numel(sample)-1);
            time = time * dt;
            figure(14739)
            plot(time,sample)
            xlabel("Time [s]",'Interpreter','latex')
            ylabel("Waveform Sample",'Interpreter','latex')
            render
        end
        
    end
end

