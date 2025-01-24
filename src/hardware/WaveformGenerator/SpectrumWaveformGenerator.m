classdef (Abstract) SpectrumWaveformGenerator < WaveformGenerator
    %SpectrumWaveformGenerator Summary of this class goes here
    %   Please download the Spectrum AWG MATLAB driver:
    %   https://spectrum-instrumentation.com/products/drivers_examples/matlab_support.php
    
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
                    [~,obj.Device] = spcMSetupAnalogOutputChannel(obj.Device, ii-1, 2000, 0, 0, obj.RegMap('SPCM_STOPLVL_ZERO'), 0, 0);
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
            % Different from Keysight, Spectrum AWG insists that all
            % channels have the same number of segments and behave in the
            % same way. The samples must be uploaded segment by segment,
            % and each (physical) segment stores samples of all channels.
            % See the manual, chapter <data management>.
            %% Check connection to the device
            obj.check;
            d = obj.Device;

            %% Get the minimum segment size
            enabledChannel = [];
            for ii = 1:obj.NChannel
                if isempty(obj.WaveformList{ii})
                    continue
                elseif obj.IsOutput(ii) == false
                    continue
                else
                    enabledChannel = [enabledChannel,ii];
                end
            end

            if isempty(enabledChannel)
                return
            else
                nEnabledChannel = numel(enabledChannel);
            end

            switch nEnabledChannel
                case 0
                    return
                case 1
                    segmentSizeMinimum = 384;
                case 2
                    segmentSizeMinimum = 192;
                case 3
                    segmentSizeMinimum = 192;
                otherwise
                    segmentSizeMinimum = 96;
            end

            %% Check numbers of waveforms of each channel
            nWaveList = zero(1,nEnabledChannel);
            for ii = 1:nEnabledChannel
                nWaveList(ii) = numel(obj.WaveformList{enabledChannel(ii)}.WaveformOrigin);
            end
            if all(nWaveList == nWaveList(1))
                nWave = nWaveList(1) + 1;
            else
                error("The numbers of waveforms of each channel have to be the same.")
            end
            [~,d] = spcMSetupModeRepSequence(d, 0, 1, nWave, 0); % need to verify

            %% Prepare the waveforms
            sample = cell(nWave,nEnabledChannel);
            for jj = 1:nWave
                segSize = 0;
                for ii = 1:nEnabledChannel
                    if jj == nWave
                        sample{jj,ii} = zeros(0,1,segmentSizeMinimum);
                    else
                        sample{jj,ii} = obj.WaveformList{enabledChannel(ii)}.WaveformOrigin{jj}.Sample;
                    end
                    if numel(sample{jj,ii}) < segmentSizeMinimum
                        sample{jj,ii} = [sample{jj,ii},interp1(sample{jj,ii},(numel(sample{jj,ii})+1):segmentSizeMinimum,'linear','extrap')];
                    end
                    remainder=32-mod(numel(sample{jj,ii}), 32);
                    segSize = segSize + ceil(numel(sample{jj,ii})/32)*32;
                    if remainder
                        sample{jj,ii} = [sample{jj,ii},interp1(sample{jj,ii}(end-9:end),11:(remainder+10),'linear','extrap')];
                    end
                end
                spcm_dwSetParam_i32(obj.Device.hDrv, obj.RegMap('SPC_SEQMODE_WRITESEGMENT'),jj-1);
                spcm_dwSetParam_i32(obj.Device.hDrv, obj.RegMap('SPC_SEQMODE_SEGMENTSIZE'), segSize);
                spcm_dwSetData(obj.Device.hDrv, 0, segSize, nEnabledChannel, 0, sample{jj,:});
            end

            %% Determine the order
            for ii = 1:nWave
                if ii ~= nWave
                    spcMSetupSequenceStep(d,ii-1,ii,ii-1,1,0);
                else
                    spcMSetupSequenceStep(d,ii-1,0,ii-1,1,1); %loop the zero output until trigger
                end
            end

            %% Activate Card
            commandMask = bitor(obj.RegMap('M2CMD_CARD_START'), obj.RegMap('M2CMD_CARD_ENABLETRIGGER'));
            errorCode = spcm_dwSetParam_i32(d.hDrv, obj.RegMap('SPC_M2CMD'), commandMask);

            if (errorCode ~= 0)
                [~, d] = spcMCheckSetError (errorCode, d);
                if errorCode == obj.ErrorMap('ERR_TIMEOUT')
                    errorCode = spcm_dwSetParam_i32 (d.hDrv, obj.RegMap('SPC_M2CMD'), obj.RegMap('M2CMD_CARD_STOP'));
                    fprintf (' OK\n ................... replay stopped\n');
                else
                    spcMErrorMessageStdOut (d, 'Error: spcm_dwSetParam_i32:\n\t', true);
                    return;
                end
            end

            %% Check if upload is successful
            s = obj.check;
            if s
                disp(obj.Name + " channel" + num2str(ii) + " uploaded successfully.")
            else
                obj.set
            end

            obj.saveObject;
        end

        function close(obj)
            if isempty(obj.Device)
                warning("Device is not connected.")
                return
            elseif ~isvalid(obj.Device)
                warning("Device was deleted.")
                return
            else
                spcMCloseCard(obj.Device);
                toc;
            end
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

