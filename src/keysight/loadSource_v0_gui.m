%Do not edit this code, try to work in its framework!!!
function [errorSeqLoad]=loadSource_v0_gui(whichSource,arbsList,sampleR,repeatsList,playModeIn, selectedTrigButton)

    % which source
    sour=string(whichSource);
    sampleRinMHz=sampleR*1e-6;

    % source-dependent strings
    source=strcat('SOURce',sour);
    trigger=strcat(':TRIGger',sour);
    output=strcat(':OUTPut',sour);

    % set specific commands for each arb. 
    %First arb and last arb do nothing (just waits for trigger)
    arbName='arbSeq';
    arbNameS='arbSeq,%s';
%     playControlList={'onceWaitTrig','repeat','repeat','repeat','onceWaitTrig'};
%     playControlList={'onceWaitTrig',playModeIn{:},'repeat'};
    playControlList=playModeIn;

%     markerModeList={'lowAtStart','lowAtStart','lowAtStart','lowAtStart','lowAtStart'};
    markerModeList=repmat({'lowAtStart'}, 1, length(arbsList));
    markerLocList=linspace(10,10,length(arbsList));

    %%%% connect to device %%%
    bufferSize=8388608;
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
    fprintf(v33622A, sprintf(':OUTPut1 %d', 0));
    fprintf(v33622A, sprintf(':OUTPut2 %d', 0));
    %%% end of presets

%This loads all the arb files from arbsList
    for ii=1:length(arbsList)
        %set file names
        arbfileNames{ii}=strcat('ARB',sour,char(64+ii));
        % 3 significant digits and remove trailing zeroes
%         arb{ii}=sprintf('%0.02g,' , arbsList{ii});
        arb{ii}=arbsList{ii};
        %Remove last comma
        arb{ii}=arb{ii}(1:end-1);
        %construct file name to load (source1)
        arbLoad{ii}=convertStringsToChars(sprintf(strcat(source,':DATA:ARBitrary %s,%s'),arbfileNames{ii},arb{ii}));
    end



    %Clear volatile Memory
    pause(1);
    fprintf(v33622A, strcat(source,':DATA:VOLatile:CLEar')); %After executing this step, returns an error, can I troubleshoot without this???

    % Source presets for arb file
    fprintf(v33622A, sprintf(strcat(source,':FUNCtion:ARBitrary:SRATe %g MHZ'), sampleRinMHz));
    fprintf(v33622A, sprintf(strcat(source,':VOLTage:HIGH %g'), 2.0));
    fprintf(v33622A, sprintf(strcat(source,':VOLTage:LOW %g'), -2.0));
    fprintf(v33622A, sprintf(strcat(source,':VOLTage:OFFset %g'), 0));
    fprintf(v33622A, sprintf(strcat(source,':FUNCtion:ARBitrary:PTPeak %g'), 2));
    %%%% 

    %Set whether to trigger by external (default) or by software (for
    %testing)
%     selectedTrigButton=app.OutputButtonGroup.SelectedObject.Text;
%     switch selectedTrigButton
%         case 'External'
            fprintf(v33622A, sprintf(':TRIGger1:SOURce %s', 'EXT'));
            fprintf(v33622A, sprintf(':TRIGger2:SOURce %s', 'EXT'));
%         otherwise
%             fprintf(v33622A, sprintf(':TRIGger1:SOURce %s', 'BUS'));
%             fprintf(v33622A, sprintf(':TRIGger2:SOURce %s', 'BUS'));
%             
%     end


    % Loads all arb files in volatile memory and checks for errors.
    % It also creates arbToSeq, which is the string that contains
    % all specific commands for each arb previously set before.

    % first and last arbs should be empty.
%     repeatsList=[0,repeatsList,0];

    errorSeqLoad="allGood";
    



    for ii=1:length(arb)
%         fprintf(v33622A, arbLoad{ii});
        binblockwrite(v33622A, arb{ii}, sprintf(strcat(source,':DATA:ARBitrary %s,'),arbfileNames{ii}));
        disp(arbLoad{ii});
        error=query(v33622A, ':SYSTem:ERRor?');
        disp(strjoin(['Load arb',string(ii),'of',string(length(arb)),'with ->',error]))
        if error(1:2)~="+0"
            errorSeqLoad="failedCreation";
           break
        else
            arbToSeq{ii}=sprintf('%s,%d,%s,%s,%d',arbfileNames{ii},repeatsList(ii),playControlList{ii},markerModeList{ii},markerLocList(ii));

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
        fprintf(v33622A, sprintf(strcat(source,':FUNCtion:ARBitrary "%s"'), arbName))
        errorSeqLoad=query(v33622A, ':SYSTem:ERRor?');

            if contains(errorSeqLoad , 'No error')==1
                disp(strcat(pad("Sequence loaded in channel "),"",string(whichSource)))
                errorSeqLoad="allGood";
                fprintf(v33622A, sprintf(':OUTPut1 %d', 1));
                fprintf(v33622A, sprintf(':OUTPut2 %d', 0));
            elseif contains(errorSeqLoad , 'No error')==0
                disp(errorSeqLoad)

            end

    end



    % Close communication, but keep files loaded.
    fprintf(v33622A, '*WAI');
    fprintf(v33622A, ':ABORt');
    % Cleanup
    fclose(v33622A);
    delete(v33622A);
    clear v33622A;
    clear instrument



end