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
            obj.IsOutput = [true,true];
            obj.Memory = 4e6;
            obj.SamplingRate = 64e6;
            obj.TriggerSource = "External";
            obj.TriggerSlope = "Rise";
            obj.DataType = "uint8";
            obj.WaveformList = cell(1,obj.NChannel);
        end
        
        function connect(obj)
            obj.VisaDevice = visadev(obj.ResourceName);
        end

        function set(obj)
            obj.check
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
            %% Check connection to the device
            obj.check
            v = obj.VisaDevice;

            %% Upload to channels
            for ii = 1:obj.NChannel
                %% Check waveform and output
                if isempty(obj.WaveformList{ii})
                    continue
                elseif obj.IsOutput(ii) == false
                    continue
                end

                %% Add begining and ending zero waveforms for triggering
                obj.WaveformList{ii}.SamplingRate = obj.SamplingRate;
                t = obj.WaveformList{ii}.WaveformPrepared;
                Sample = {zeros(1,35)};
                PlayMode = "OnceWaitTrigger";
                NRepeat = 0;
                t0 = table(Sample,PlayMode,NRepeat);
                PlayMode = "Repeat";
                te = table(Sample,PlayMode,NRepeat);
                t = [t0;t;te];

                %% Initialize parameters
                nWave = size(t,1);
                arbSegName = "MMARB_ch" + string(ii) + "_" + string(1:nWave)';
                arbFileName = "MMARB_ch" + string(ii);
                arbToSeq = cell(1,nWave);
                markerModeList=repmat({'lowAtStart'}, 1, nWave);
                markerLocList=linspace(10,10,nWave);
                sourceStr = "SOURce" + string(ii);
                outputStr = "OUTPut" + string(ii);

                %% Upload
                for jj = 1:nWave
                    dataBlock = t.Sample{jj};
                    dataBlock = dataBlock(:).'; % data block has to be a row vector
                    dataBlock = single(dataBlock); % reduce memory use

                    %% Map play mode string
                    switch t.PlayMode(jj)
                        case "Once"
                            playMode = "once";
                        case "OnceWaitTrigger"
                            playMode = "onceWaitTrig";
                        case "Repeat"
                            playMode = "repeat";
                        case "RepeatInf"
                            playMode = "repeatInf";
                        case "RepeatTilTrigger"
                            playMode = "repeatTilTrig";
                    end

                    %% Write arb segment data into the device
                    header = char(sprintf(sourceStr+":DATA:ARBitrary" + " %s,",arbSegName(jj)));
                    writebinblock2(v,dataBlock,obj.DataType,header) % Write data into arb segment
                    arbToSeq{jj}=sprintf('%s,%d,%s,%s,%d',arbSegName(jj),t.NRepeat(jj),playMode,markerModeList{jj},markerLocList(jj));
                end

                %% Concatenate arb segments into an arb sequence
                allArbsToSeq=sprintf(strcat(arbFileName,',%s'),sprintf('%s,',arbToSeq{1:end}));
                allArbsToSeq=allArbsToSeq(1:end-1); %remove final comma
                header2 = char(sourceStr + pad(":DATA:SEQuence "));
                writebinblock2(v,allArbsToSeq,obj.DataType,header2)

                %% Tell the device to output the arb sequence
                writeline(v,sprintf(sourceStr + ':FUNCtion:ARBitrary "%s"', arbFileName)) % Change ARB source file
                writeline(v,sourceStr + ":FUNCtion ARB") % Change output mode to ARB
                writeline(v,outputStr + " 1") % Start to output
            end
        end

        function close(obj)
            obj.check
            v = obj.VisaDevice;
            write(v, '*WAI');
            write(v, ':ABORt');
            delete(v);
            clear v;
            clear instrument
        end
    
        function check(obj)
            if isempty(obj.VisaDevice)
                error("VISA device is not connected.")
            elseif ~isvalid(obj.VisaDevice)
                error("VISA device was deleted.")
            end
        end
    
    end
end

