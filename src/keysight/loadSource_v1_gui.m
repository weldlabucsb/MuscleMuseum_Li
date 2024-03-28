%Do not edit this code, try to work in its framework!!!
function [errorSeqLoad]=loadSource_v1_gui(whichSource,arbsList,sampleR,repeatsList,playModeIn, selectedTrigButton)
    
%Editing this code 6/21/2023 to add new framework and figure out why the
%code upload is so slow.

%This scripts takes in information to upload a number of sequences to the
%keysight 33600A.

%whichSource= takes an integer or string of 1 or 2 to determine the output
%   channel.
%arbsList = cell array of 1d arrays of numbers which serve as the sequence
%of waveforms in order.
%   input for the code
%sampleR= sampling frequency of the waveform in arbsList
%repeatsList = 1d array of integers describing number of times each
%   sequence repeats.
%playModeIn = Describes the method at which a sequence is played. Options
    % %include:
    %     - once
    %     - onceWaitTrig
    %     - repeat
    %     - repeatInf
    %     - repeatTilTrig
%selectedTrigButton:
   %- would tell how waveform is triggered, not coded in.

%% Format Data To Properly Send Data to Code
    % which source
    sour=string(whichSource);
    sampleRinMHz=sampleR*1e-6;

    % source-dependent strings 
    source=strcat('SOURce',sour);
    trigger=strcat('TRIGger',sour);
    output=strcat('OUTPut',sour);

    % set specific commands for each arb. 
    %First arb and last arb do nothing (just waits for trigger)
    arbName='arbSeq';
    % arbName   ='arbSeq,%s';
%     playControlList={'onceWaitTrig','repeat','repeat','repeat','onceWaitTrig'};
    % playModeIn={'onceWaitTrig',playModeIn{:},'repeat'};
    % repeatsList=[0,repeatsList,0];
    
    % playControlList=playModeIn;

%     markerModeList={'lowAtStart','lowAtStart','lowAtStart','lowAtStart','lowAtStart'};
    markerModeList=repmat({'lowAtStart'}, 1, length(arbsList));
    markerLocList=linspace(10,10,length(arbsList));

    %This loads all the arb files from arbsList
    for ii=1:length(arbsList)
        %set file names
        arbfileNames{ii}=strcat('ARB',sour,char(64+ii));
        % 3 significant digits and remove trailing zeroes
%         arb{ii}=sprintf('%0.02g,' , arbsList{ii});
        arb{ii}=arbsList{ii};
        %Remove last comma
%         arb{ii}=arb{ii}(1:end-1);
        %construct file name to load (source1)
        arbLoad{ii}=convertStringsToChars(sprintf(strcat(source,':DATA:ARBitrary %s,%s'),arbfileNames{ii},arb{ii}));
    end


%% Connecting to Device

    %%%% connect to device %%%
    bufferSize=8388608; %Should be calculated based on actual signal input.
    % Connect steps
%     v33622A = visa('agilent', 'USB0::0x0957::0x5707::MY59000681::0::INSTR'); %Double check this code...
        v33622A = visa('agilent', 'USB0::0x0957::0x5607::MY59000681::0::INSTR'); %Connected to Eber's computer
%         v33622A = visa('agilent', 'TCPIP0::169.254.5.21::5025::SOCKET');
%         %Using the ethernet connection on Eber's computer
%     v33622A.InputBufferSize = bufferSize;
    v33622A.OutputBufferSize = bufferSize;
    v33622A.ByteOrder = 'littleEndian';
    v33622A.EOSMode='read&write';
    fopen(v33622A);
    fprintf(v33622A, '*CLS');

    % preset channels: just avoid weird outputs
    fprintf(v33622A, sprintf('OUTPut1 %d', 0));
    fprintf(v33622A, sprintf('OUTPut2 %d', 0)); %Need to verify whether this is even necessary.
    %%% end of presets

    %% Reset Memory
    %Clear volatile Memory
    fprintf(v33622A, strcat(source,':DATA:VOLatile:CLEar')); %After executing this step, returns an error, can I troubleshoot without this??? %clears only specific channel.

    %% Input Settings for Arb File
    fprintf(v33622A, 'FORM:BORD SWAP') %Swaps byte order to LSB in keysight, that's how its usually communicated for byte blocks.

    % Source presets for arb file
    fprintf(v33622A, sprintf(strcat(source,':FUNCtion:ARBitrary:SRATe %g MHZ'), sampleRinMHz));
    fprintf(v33622A, sprintf(strcat(source,':VOLTage:HIGH %g'), 2.0));
    fprintf(v33622A, sprintf(strcat(source,':VOLTage:LOW %g'), -2.0));
    fprintf(v33622A, sprintf(strcat(source,':VOLTage:OFFset %g'), 0));
    fprintf(v33622A, sprintf(strcat(source,':FUNCtion:ARBitrary:PTPeak %g'), 2));
    fprintf(v33622A, sprintf(strcat(output,':MODE GATed')));
    %%%% 
    
    %Set whether to trigger by external (default) or by software (for
    %testing)
%     selectedTrigButton=app.OutputButtonGroup.SelectedObject.Text;
%     switch selectedTrigButton
%         case 'External'
            fprintf(v33622A, sprintf(':TRIGger1:SOURce %s', 'EXT'));
            fprintf(v33622A, sprintf(':TRIGger2:SOURce %s', 'EXT'));
%         otherwise
            % fprintf(v33622A, sprintf(':TRIGger1:SOURce %s', 'BUS'));
            % fprintf(v33622A, sprintf(':TRIGger2:SOURce %s', 'BUS'));
%             
%     end



    % Loads all arb files in volatile memory and checks for errors.
    % It also creates arbToSeq, which is the string that contains
    % all specific commands for each arb previously set before.
    
    % first and last arbs should be empty.
    
    
    %% Input Waveforms
    errorSeqLoad="allGood";

    for ii=1:length(arb)
%         fprintf(v33622A, arbLoad{ii});
%         arb=arb{ii};
%         datablock=typecast(arb, 'uint8');
%         datablock=linspace(0,1,200e3);
        datablock=arb{ii};
        datablock=single(datablock);
        datablock=typecast(datablock, 'uint8');
%         max(datablock)
%         min(datablock)
%         plot(arb{ii});
%         header=sprintf(strcat(source,':DATA:ARBitrary %s,'),arbfileNames{ii});
%         header=[source ':DATA:ARBitrary ' arbfileNames{ii} ','];
%         fwrite(v33622A, [header datablock], 'uint8');
%         arbBytes=num2str(length(datablock) * 4);
        binblockwrite(v33622A, datablock, sprintf(strcat(source,':DATA:ARBitrary %s,'),arbfileNames{ii}));
%         fprintf(v33622A, '*WAI')
%         disp(arbLoad{ii});
        error=query(v33622A, ':SYSTem:ERRor?');
        disp(strjoin(['Load arb',string(ii),'of',string(length(arb)),'with ->',error]))
        if error(1:2)~="+0"
            errorSeqLoad="failedCreation";
           break
        else
            arbToSeq{ii}=sprintf('%s,%d,%s,%s,%d',arbfileNames{ii},repeatsList(ii),playModeIn{ii},markerModeList{ii},markerLocList(ii));

        end
    
    end

    if errorSeqLoad=="failedCreation"
        % Close communication, but keep files loaded.
        fprintf(v33622A, '*WAI');
        fprintf(v33622A, ':ABORt');
        % Cleanup
        fclose(v33622A);
        delete(v33622A);
        clear v33622A;
        clear instrument
        disp('Aborted');
        return
    elseif errorSeqLoad=="allGood"
        % This loads the sequence in memory and checks if there are errors.
        allArbsToSeq=sprintf(strcat(arbName,',%s'),sprintf('%s,',arbToSeq{1:end}));
        allArbsToSeq=allArbsToSeq(1:end-1); %remove final comma
        %write and load sequence (first is empty, waits for trigger to start)
        binblockwrite(v33622A,allArbsToSeq,strcat(source,pad(":DATA:SEQuence "))); 
        %pad() in binblockwrite adds needed white space at the end of string
        error=query(v33622A, ':SYSTem:ERRor?');
    %     disp(error)

        % Load the arb or sequence file
        fprintf(v33622A, sprintf(strcat(source,':FUNCtion:ARBitrary "%s"'), arbName));
        errorSeqLoad=query(v33622A, ':SYSTem:ERRor?');

            if contains(errorSeqLoad , 'No error')==1
                disp(strcat(pad("Sequence loaded in channel "),"",string(whichSource)))
                errorSeqLoad="allGood";
                fprintf(v33622A, sprintf(strcat(source, ':FUNCtion ARB')));
                fprintf(v33622A, sprintf(':OUTPut1 %d', 0));
                fprintf(v33622A, sprintf(':OUTPut2 %d', 1));
            elseif contains(errorSeqLoad , 'No error')==0
                disp(errorSeqLoad)

            end

    end

    %% Close Communication

    % Close communication, but keep files loaded.
    fprintf(v33622A, '*WAI');
    fprintf(v33622A, ':ABORt');
    % Cleanup
    fclose(v33622A);
    delete(v33622A);
    clear v33622A;
    clear instrument



end