classdef (Abstract) SpectrumWaveformGenerator < WaveformGenerator
    %KEYSIGHT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected,Transient)
        Device
        RegMap
        ErrorMap
    end
    
    methods
        function obj = SpectrumWaveformGenerator(resourceName,name)
            %KEYSIGHT Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                resourceName string
                name string = string.empty
            end
            obj@WaveformGenerator(resourceName,name);
            obj.Manufacturer = "Spectrum";
        end
        
        function connect(obj)
            try
                obj.RegMap = spcMCreateRegMap;
                obj.ErrorMap = spcMCreateErrorMap;
            catch
                error("The Spectrum MATLAB library is not found. Please download it from Spectrum AWG websites and install it." + ...
                " Make sure the library is in MATLAB's search path.")
            end
            [isOpened,obj.Device] = spcMInitDevice(obj.ResourceName);
            if ~isOpened
                spcMErrorMessageStdOut(obj.Device, 'Error: Could not open card\n', true)
            end
        end

        function set(obj)
            obj.check;
            switch obj.TriggerSource
                case "External"
                    [~,obj.Device] = spcMSetupTrigExternal(obj.Device, obj.RegMap('SPC_TM_POS'), 0, 0, 1, 0); 
                case "Immediate"
                    [~,obj.Device] = spcMSetupTrigSoftware(obj.Device, 0);
            end

            for ii = 1:obj.NChannel
                if obj.IsOutput(ii)
                    [~,obj.Device] = spcMSetupAnalogOutputChannel (obj.Device, ii-1, 2000, 0, 0, obj.RegMap('SPCM_STOPLVL_ZERO'), 0, 0);
                end


                % sourceStr = "SOURce" + string(ii);
                % outputStr = "OUTPut" + string(ii);
                % triggerStr = "TRIGger" + string(ii);
                % writeline(d,outputStr + " 0") % Stop output
                % writeline(d,sourceStr + ":DATA:VOLatile:CLEar") % Clear volatile memory
                % writeline(d,"FORM:BORD SWAP") % Swaps byte order to LSB
                % writeline(d, sprintf(sourceStr + ':FUNCtion:ARBitrary:SRATe %g MHZ', obj.SamplingRate * 1e-6)); % Sampling rate
                % writeline(d, sprintf(sourceStr + ':VOLTage:HIGH %g', 2.0)); % Voltage high
                % writeline(d, sprintf(sourceStr + ':VOLTage:LOW %g', -2.0)); % Voltage low
                % writeline(d, sprintf(sourceStr + ':VOLTage:OFFset %g', 0)); % Voltage offset
                % writeline(d, sprintf(sourceStr + ':FUNCtion:ARBitrary:PTPeak %g', 1)); % Set arbitray waveform p2p
                % 
                % % Trigger source
                % switch obj.TriggerSource
                %     case "External"
                %         writeline(d, triggerStr + ":SOURce EXT");
                %     case "Internal"
                %         writeline(d, triggerStr + ":SOURce BUS");
                % end
                % 
                % % Trigger slope
                % switch obj.TriggerSlope
                %     case "Rise"
                %         writeline(d, triggerStr + ":SLOPe POS");
                %     case "Fall"
                %         writeline(d, triggerStr + ":SLOPe NEG");
                % end
                % 
                % % Output mode
                % switch obj.OutputMode
                %     case "Normal"
                %         writeline(d, outputStr + ':MODE NORMal');
                %     case "Gated"
                %         writeline(d, outputStr + ':MODE GATed'); % Gating the output
                % end
                % 
                % % Output load
                % switch obj.OutputLoad
                %     case "50"
                %         writeline(d, outputStr + ':LOAD 50')
                %     case "Infinity"
                %         writeline(d, outputStr + ':LOAD INFinity')
                % end
            end
        end

        function upload(obj)
            %% Check connection to the device
            obj.check;
            d = obj.Device;

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

                %% Set PTP value
                scaleFactor = max(cellfun(@(x) max(abs(x)),t.Sample));
                ptp = 2 * scaleFactor;
                writeline(d, sprintf(sourceStr + ':FUNCtion:ARBitrary:PTPeak %g', ptp)); % Set arbitray waveform p2p

                %% Upload
                for jj = 1:nWave
                    dataBlock = t.Sample{jj} ./ scaleFactor;
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
                    writebinblock2(d,dataBlock,obj.DataType,header) % Write data into arb segment
                    arbToSeq{jj}=sprintf('%s,%d,%s,%s,%d',arbSegName(jj),t.NRepeat(jj),playMode,markerModeList{jj},markerLocList(jj));
                end

                %% Concatenate arb segments into an arb sequence
                allArbsToSeq=sprintf(strcat(arbFileName,',%s'),sprintf('%s,',arbToSeq{1:end}));
                allArbsToSeq=allArbsToSeq{1}(1:end-1); %remove final comma
                header2 = char(sourceStr + pad(":DATA:SEQuence "));
                writebinblock2(d,allArbsToSeq,obj.DataType,header2)

                %% Tell the device to output the arb sequence
                writeline(d,sprintf(sourceStr + ':FUNCtion:ARBitrary "%s"', arbFileName)) % Change ARB source file
                writeline(d,sourceStr + ":FUNCtion ARB") % Change output mode to ARB
                writeline(d,outputStr + " 1") % Start to output

                %% Check if upload is successful
                s = obj.check;
                if s
                    disp(obj.Name + " channel" + num2str(ii) + " uploaded successfully.")
                else
                    obj.set
                end
            end

            obj.saveObject;
        end

        function close(obj)
            if isempty(obj.Device)
                warning("VISA device is not connected.")
                return
            elseif ~isvalid(obj.Device)
                warning("VISA device was deleted.")
                return
            else
                em = query(obj.Device, ':SYSTem:ERRor?');
                if em(1:2)~="+0"
                    disp("Hardware error. Message: "+ newline + em)
                    obj.set
                end
            end
            v = obj.Device;
            write(v, '*WAI');
            write(v, ':ABORt');
            delete(v);
            clear v;
            clear instrument
        end
    
        function status = check(obj)
            status = false;
            if isempty(obj.Device)
                error("Device is not connected.")
            elseif ~isvalid(obj.Device)
                error("Device was deleted.")
            elseif obj.Device.cardFunction ~= obj.RegMap('SPCM_TYPE_AO')
                spcMErrorMessageStdOut(obj.Device, 'Error: Card function not supported by this example\n', false);
            elseif bitand(obj.Device.featureMap, obj.RegMap('SPCM_FEAT_SEQUENCE')) == 0
                spcMErrorMessageStdOut(obj.Device, 'Error: Sequence Mode Option not installed. Example was done especially for this option!\n', false);
            elseif obj.Device.setError
                error(obj.Device.errorText)
            else
                [success, obj.Device] = spcMSetupClockPLL(obj.Device, obj.SamplingRate, 0);
                if ~success
                    spcMErrorMessageStdOut(obj.Device, 'Error: spcMSetupClockPLL:\n\t', true);
                else
                    status = true;
                end
            end
        end
    
    end
end

