classdef Keysight33600A < WaveformGenerator
    %KEYSIGHT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private,Transient)
        VisaDevice
    end
    
    methods
        function obj = Keysight33600A(resourceName,name)
            %KEYSIGHT Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                resourceName string
                name string = string.empty
            end
            obj@WaveformGenerator(resourceName,name);
            obj.Manufacturer = "Keysight";
            obj.Model = "33600A";
            obj.NChannel = 2;
            obj.Memory = 4e6;
            obj.SamplingRate = 64e6;
            obj.TriggerSource = "External";
            obj.TriggerSlope = "Rise";
            obj.DataType = "uint8";
        end
        
        function connect(obj)
            obj.VisaDevice = visadev(obj.ResourceName);
        end

        function set(obj)
            v = obj.VisaDevice;
            v.ByteOrder = "little-endian";
            configureTerminator(v,"LF")
            writeline(v,"*CLS") % Clear status
            for ii = 1:obj.NChannel
                sourceStr = "SOURce" + string(ii);
                outputStr = "OUTPut" + string(ii);
                triggerStr = "TRIGger" + string(ii);
                writeline(v,outputStr + " 0") % Stop output
                writeline(v,sourceStr + ":DATA:VOLatile:CLEar") % Clear volatile memory
                writeline(v,"FORM:BORD SWAP") % Swaps byte order to LSB
                writeline(v, sprintf(sourceStr + ':FUNCtion:ARBitrary:SRATe %g MHZ', obj.SamplingRate * 1e-6)); % Sampling rate
                writeline(v, sprintf(sourceStr + ':VOLTage:HIGH %g', 2.0)); % Voltage high
                writeline(v, sprintf(sourceStr + ':VOLTage:LOW %g', -2.0)); % Voltage low
                writeline(v, sprintf(sourceStr + ':VOLTage:OFFset %g', 0)); % Voltage offset
                writeline(v, sprintf(sourceStr + ':FUNCtion:ARBitrary:PTPeak %g', 2)); % Set arbitray waveform p2p
                
                % Trigger source
                switch obj.TriggerSource
                    case "External"
                        writeline(v, triggerStr + ":SOURce EXT");
                    case "Internal"
                        writeline(v, triggerStr + ":SOURce BUS");
                end

                % Trigger slope
                switch obj.TriggerSlope
                    case "Rise"
                        writeline(v, triggerStr + ":SLOPe POS");
                    case "Fall"
                        writeline(v, triggerStr + ":SLOPe NEG");
                end

                % Output mode
                switch obj.OutputMode
                    case "Normal"
                        writeline(v, outputStr + ':MODE NORMal');
                    case "Gated"
                        writeline(v, outputStr + ':MODE GATed'); % Gating the output
                end
            end
        end

        function upload(obj)
            if isempty(obj.WaveformList)
                return
            end
            
            s = obj.VisaDevice;

            for ii = 1:obj.NChannel
                if isempty(obj.WaveformList{ii})
                    continue
                end
                obj.WaveformList{ii}.SamplingRate = obj.SamplingRate;


                t = obj.WaveformList{ii}.WaveformPrepared;

                Sample = {zeros(1,35)};
                PlayMode = "OnceWaitTrigger";
                NRepeat = 0;
                t0 = table(Sample,PlayMode,NRepeat);

                Sample = {zeros(1,35)};
                PlayMode = "Repeat";
                NRepeat = 0;
                te = table(Sample,PlayMode,NRepeat);

                t = [t0;t;te];

                nWave = size(t,1);
                arbName = "MMARB_ch" + string(ii) + "_" + string(1:nWave)';

                playMode = t.PlayMode;
                playMode = strrep(playMode,"Once","once");
                playMode = strrep(playMode,"OnceWaitTrigger","onceWaitTrig");
                playMode = strrep(playMode,"Repeat","repeat");
                playMode = strrep(playMode,"RepeatInf","repeatInf");
                playMode = strrep(playMode,"RepeatTilTrigger","repeatTilTrig");

                arbToSeq = cell(1,nWave);

                for jj = 1:nWave
                    dataBlock = t.Sample{jj};
                    dataBlock = dataBlock(:).';
                    header = char(sprintf("SOURce" + string(ii)+":DATA:ARBitrary" + " %s,",arbName(jj)));
                    switch obj.DataType
                        case "uint8"
                            dataBlock = single(dataBlock);
                            dataBlock = typecast(dataBlock, "uint8");
                            header2 = [' #' , num2str(numel(num2str(numel(dataBlock)))) , num2str(numel(dataBlock))];
                            header = uint8([header,header2]);
                    end
                    write(s,[header,dataBlock],obj.DataType) % Write data into arb files
                    arbToSeq{jj}=sprintf('%s,%d,%s',arbName(jj),t.NRepeat(jj),playMode(jj));
                end

                allArbsToSeq=sprintf(strcat('arbSeq',',%s'),sprintf('%s,',arbToSeq{1:end}));
                allArbsToSeq=allArbsToSeq(1:end-1); %remove final comma
                header3 = char(strcat(['SOURce', num2str(ii)],pad(":DATA:SEQuence ")));
                write(s,[header3,allArbsToSeq],obj.DataType); 
            end
        end

        function close(obj)
            v = obj.VisaDevice;
            write(v, '*WAI');
            write(v, ':ABORt');
            delete(v);
            clear v;
            clear instrument
        end
    end
end

