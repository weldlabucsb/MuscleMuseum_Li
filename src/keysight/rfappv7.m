classdef rfappv7 < matlab.apps.AppBase
    % This version will add functionality to allow for flexible adjustments and
    % additions to the different waveforms one might want to add (instead of
    % hardcoding the settings measurement box.

    %Last edited 4/25/2022

    %Dependents on following codes:
    %UploadButtonScriptv4.m
    %StepTypeStructCreation.m (for 1st time setup or new step type only)
    %loadSource_v0_gui.m
    %buildplotscript.m
    %readyuploadv1.m

    %Changes for v6:
    %
    % - Gonna try and retrieve the latest log file when triggered to upload??



    %Procedure for message display:
    %turn on diary (create file in folder)
    %create a timer object to check for new messages repeatedly (kind of
    %annoying I guess, maybe make it a 2 time

    %% Properties that correspond to app components (Variables that reach different functions)
    properties (Access = public)
        UIFigure            matlab.ui.Figure
        RunModeButtonGroup  matlab.ui.container.ButtonGroup
        SingleRunButton     matlab.ui.control.RadioButton
        ListButton          matlab.ui.control.RadioButton
        CiceroButton        matlab.ui.control.RadioButton
        OutputButtonGroup   matlab.ui.container.ButtonGroup
        BusButton           matlab.ui.control.RadioButton
        ExternalButton      matlab.ui.control.RadioButton
        BuildButton         matlab.ui.control.Button
        RFGUIv1Label        matlab.ui.control.Label
        UploadButton        matlab.ui.control.Button
        AbortButton         matlab.ui.control.Button
        ForceTrig           matlab.ui.control.Button
        TabGroup            matlab.ui.container.TabGroup
        KP1Tab              matlab.ui.container.Tab
        DropDown_3          matlab.ui.control.DropDown
        SettingsButton      matlab.ui.control.Button
        DropDown_4          matlab.ui.control.DropDown
        AddButton_2         matlab.ui.control.Button
        DeleteButton_2      matlab.ui.control.Button
        KP2Tab              matlab.ui.container.Tab
        DropDown            matlab.ui.control.DropDown
        SettingsButton_2    matlab.ui.control.Button
        DropDown_2          matlab.ui.control.DropDown
        AddButton           matlab.ui.control.Button
        DeleteButton        matlab.ui.control.Button
        SaveSequenceButton  matlab.ui.control.Button
        SaveSequenceButton_2 matlab.ui.control.Button
        DeleteSequenceButton  matlab.ui.control.Button
        DeleteSequenceButton_2 matlab.ui.control.Button
        SaveAsSeqButton     matlab.ui.control.Button
        SaveAsSeqButton_2   matlab.ui.control.Button
        VarTab              matlab.ui.container.Tab
        VarSizeField        matlab.ui.control.NumericEditField
        VarTable            matlab.ui.control.Table;
        VarStartField       matlab.ui.control.NumericEditField
        VarStopField        matlab.ui.control.NumericEditField
        VarStepField        matlab.ui.control.NumericEditField
        VarLoopField        matlab.ui.control.NumericEditField
        FillVarButton       matlab.ui.control.Button
        VarStartText        matlab.ui.control.Label
        VarStopText         matlab.ui.control.Label
        VarStepText         matlab.ui.control.Label
        VarLoopText        matlab.ui.control.Label
        PlotTab             matlab.ui.container.Tab
        KP1Plot             matlab.ui.control.UIAxes
        KP2Plot             matlab.ui.control.UIAxes
        RFMessagesLabel     matlab.ui.control.Label
        %         logEnableLabel      matlab.ui.control.Label
        logEnableCheckbox   matlab.ui.control.CheckBox
        SequenceStruct1
        CurrentSequence1
        SequenceStruct2
        CurrentSequence2
        CurrentStep1
        CurrentStep2
        Dropdownbuttons1
        Dropdownbuttons2
        Settingsbuttons1
        Settingsbuttons2
        CurrentVarData
        AppStepTypeStyles
        CircleLocation      matlab.ui.control.UIAxes
        CircleItem
        Lamp                matlab.ui.control.Lamp

    end

    properties (Access = public)
        VariableList
        VariableLocations
        %         StepTypeList ={'Sinusoidal', 'Pulse', 'Constant', 'TwoFreq'};

        ForceTrigVal
        AbortVal
        debug
        timer_messages
    end

    %% Callbacks that handle component events (tells buttons what to do when acted upon
    methods (Access = public)


        %% Run Mode selection (ok)
        % Selection changed function: RunModeButtonGroup
        function RunModeButtonGroupSelectionChanged(app, event) %#ok<*INUSD>
            selectedButton = app.RunModeButtonGroup.SelectedObject;
            switch selectedButton
                case 'Single Run'
                    %Here I should just build the sequence.
                case 'List'
                    %Here I should make an iteration through all of the
                    %variable list for a given variable.
                otherwise %Cicero Option, need to know how to obtain the list.

            end

        end

        %% Build Button Selection  (ok, may want to add a preview panel using BuildButtonPushed)
        function BuildButtonPushed(app, event) %Build Sequence for Preview
            selectedButton=app.RunModeButtonGroup.SelectedObject.Text;
            uploadState=0; %#ok<NASGU>
            app.readyuploadv1(uploadState);
        end

        %% Upload button action (ok, could try to edit UploadButtonScriptv2 to not repeat code)
        function UploadButtonPushed(app, event) %Upload to Keysight;
            %These steps are all repeated within the uploadbutton script in
            % load_source
            uploadState=1; %#ok<NASGU>
            selectedButton=app.RunModeButtonGroup.SelectedObject.Text ;
            app.readyuploadv1(uploadState);
        end

        function readyuploadv1(app, uploadState)
            selectedButton=app.RunModeButtonGroup.SelectedObject.Text;
            switch selectedButton
                case 'Single Run'
                    %                     clear loopWaves;
                    %                     loopWaves(1).times{ii}
                    % %                     writeArbs_loop("ch1",loopWaves(idx))
                    %Rewriet writeArbs_loop that allows it to take in the
                    %sequence as is, assuming extra params realtime and
                    %playmode (assume playmode is repeat).

                    UploadButtonScriptv4



                otherwise
                    app.ForceTrigVal=0;
                    app.AbortVal=0;

                    % Create ForceTrig %button doesn't work for some
                    % reason??
                    %                     disp('createbutton')
                    app.ForceTrig = uibutton(app.UIFigure, 'push');
                    app.ForceTrig.Position = [411 78 100 22];
                    app.ForceTrig.Text = 'Force Trigger';
                    app.ForceTrig.ButtonPushedFcn=createCallbackFcn(app, @ForceTrigPushed, true);
                    app.ForceTrig.Visible='on';
                    %                     disp('did button form?')

                    %Define trigger selection
                    %Prep RedPitaya
                    %                     IP= '169.254.111.118';           % Input IP of your Red Pitaya...
                    % IP= '169.254.164.89';       %Eber's Red Pitaya Address
                    % IP = '169.254.111.118';     %functional ip address
                    IP = '192.16.0.1'; %New RP address to minimize conflict with logfiles transfers.
                    port = 5000;
                    echotcpip("off");
                    clear tcpipObj
                    %Not working right now
                    % tcpipObj=tcpip(IP, port); %#ok<TCPC>
                    % 
                    % tcpipObj.InputBufferSize = 16384*64;
                    % tcpipObj.InputBufferSize = 16384*12;
                    % 
                    % tcpipObj.OutputBufferSize = 16384*64;
                    % flushinput(tcpipObj)
                    % flushoutput(tcpipObj)

                    % tcpclient(IP, port);
                    
                    %
                    var=app.CurrentVarData;
                    loopreps=app.VarLoopField.Value;

                    flag=0;
                    % try
                    echotcpip("on", 5000)
                    % 
                    tcpipObj=tcpclient(IP, port);
                    configureTerminator(tcpipObj, 'CR/LF');
                    writeline(tcpipObj,'ACQ:RST');
                    code='d';
                    writeline(tcpipObj,'DEC:64');
                    code='e';
                    writeline(tcpipObj,'ACQ:TRIG:LEV 0.5 V');
                    code='f';
                    % writeline(tcpipObj,'ACQ:START');
                    code='g';
                    writeline(tcpipObj,'ACQ:TRIG CH1_PE');
                    writeline(tcpipObj,'ACQ:TRIG:EXT:DEBouncer:US 50');

                    % configureTerminator(tcpipObj, 'CR/LF');
                    % catch
                    %     disp('Red Pitaya failure');
                    %                 app.AbortVal=1;
                    % end
                    for nn=1:loopreps
                        for ii=1:length(var)
                            disp(ii);
                            if ~app.debug
                                try
                                    
                                    
                                    % echotcpip("on", 5000)
                                    % code='a';
                                    % % pause(1);
                                    % % tcpipObj=tcpclient(IP, port);
                                    % code='b';
                                    % configureTerminator(tcpipObj, 'CR/LF');
                                    % code='c';
                                    % writeline(tcpipObj,'ACQ:RST');
                                    % code='d';
                                    % writeline(tcpipObj,'DEC:64');
                                    % code='e';
                                    % writeline(tcpipObj,'ACQ:TRIG:LEV 0.5 V');
                                    % code='f';
                                    writeline(tcpipObj,'ACQ:START');
                                    % code='g';
                                    % writeline(tcpipObj,'ACQ:TRIG CH1_PE');
                                    % code='h';
                                    %                             disp('debugging');
                                catch
                                    disp('Red Pitaya failure');
                                    app.AbortVal=1;
                                    disp(code)
                                end
                            end

                            %                         disp('here1');
                            varval=var(ii); %#ok<NASGU>
                            while true

                                if app.AbortVal==1
                                    flag=1;
                                    app.AbortVal=0;
                                    break
                                end

                                if ~app.debug
                                    clear trig_rsp
                                    trig_rsp=writeread(tcpipObj,'ACQ:TRIG:STAT?');
                                    % pause(0.1)
                                    %                             disp(trig_rsp);
                                    if strcmp('TD',trig_rsp(1:2)) % Read only TD
                                        disp('triggered!')
                                        clear trig_rsp;
                                        writeline(tcpipObj,'ACQ:STOP');
                                        % writeline(tcpipObj,'ACQ:RST');
                                        writeline(tcpipObj,'ACQ:TRIG CH1_PE');
                                        pause(1)
                                        break
                                    end
                                end

                                %Include this snippet if you want upload to trigger at
                                %end of cicero sequence
                                if ii==1 && nn==1
                                    clear trig_rsp
                                    break
                                end



                                if app.ForceTrigVal==1
                                    app.ForceTrigVal=0;
                                    disp('Force Triggered!')
                                    clear trig_rsp
                                    break
                                end
                                pause(0.01);
                            end
                            if flag==1
                                flag=0;
                                %Close instr
                                pause(0.5);
                                
                                try
                                % clear tcpipObj
                                % echotcpip("off");
                                catch
                                end
                                break
                            end
                            uistylenew=uistyle('BackgroundColor', [1 .5 .5]);
                            removeStyle(app.VarTable);
                            addStyle(app.VarTable, uistylenew, 'cell', [ii, 1]);

                            %
                            %Grab list of variable.
                            %Wait for trig
                            %Update Variable
                            pause(0.5);
                            % clear tcpipobj
                            % echotcpip("off")

                            UploadButtonScriptv4

                            
                            

                        end
                    end
                    clear tcpipobj
                    echotcpip("off")
                    removeStyle(app.VarTable);
                    delete(app.ForceTrig);

            end
        end
        %% Button to force trigger

        function ForceTrigPushed(app, event)
            app.ForceTrigVal=1;
            %             disp('ForceTrigPressed');
        end



        %% Button to Abort

        function AbortButtonPushed(app, event)
            app.AbortVal=1;
            %             disp('ForceTrigPressed');
        end


        %% Buttton to add step to sequence (could use some cleanup)

        function AddPushedKP1(app, event)
            app.CurrentStep1=app.CurrentStep1+1;
            %Move add and delete button down
            app.AddButton_2.Position(2)=app.TabGroup.Position(4)-127-30*(app.CurrentStep1-1);
            app.DeleteButton_2.Position(2)=app.TabGroup.Position(4)-127-30*(app.CurrentStep1-1);




            %Add new default dropdown and setting buttons
            app.Dropdownbuttons1{app.CurrentStep1}=uidropdown(app.KP1Tab);
            app.Dropdownbuttons1{app.CurrentStep1}.Tag=strcat('Dropdown1_',num2str(app.CurrentStep1));
            app.Dropdownbuttons1{app.CurrentStep1}.Items = {app.AppStepTypeStyles.stepname};
            app.Dropdownbuttons1{app.CurrentStep1}.Position = [28 app.TabGroup.Position(4)-90-30*(app.CurrentStep1-1) 100 22];
            app.Dropdownbuttons1{app.CurrentStep1}.Value = 'Sinusoidal';
            app.Dropdownbuttons1{app.CurrentStep1}.ValueChangedFcn=createCallbackFcn(app, @steptypechanged, true);


            app.Settingsbuttons1{app.CurrentStep1} = uibutton(app.KP1Tab, 'push');
            app.Settingsbuttons1{app.CurrentStep1}.Tag=strcat('Settings1_', num2str(app.CurrentStep1));
            app.Settingsbuttons1{app.CurrentStep1}.Position = [142 app.TabGroup.Position(4)-90-30*(app.CurrentStep1-1) 100 22];
            app.Settingsbuttons1{app.CurrentStep1}.Text = 'Settings';
            app.Settingsbuttons1{app.CurrentStep1}.ButtonPushedFcn=createCallbackFcn(app, @EditSettings, true);

            %Add to the saved currentsequence with new default settings
            app.CurrentSequence1.step_type{end+1}='Sinusoidal';
            app.CurrentSequence1.settings{end+1}=[1,1,1,0];
            app.CurrentSequence1.varsettings{end+1}={'Manual','Manual','Manual','Manual'};

            if app.CurrentStep1>1
                app.DeleteButton_2.Visible='on';
            end

        end


        function AddPushedKP2(app, event)
            app.CurrentStep2=app.CurrentStep2+1;
            %Move add button down
            %             app.AddButton.Position(2)=app.AddButton.Position(2)-30;
            app.AddButton.Position(2)=app.TabGroup.Position(4)-126-30*(app.CurrentStep2-1);
            app.DeleteButton.Position(2)=app.TabGroup.Position(4)-127-30*(app.CurrentStep2-1);
            %             app.DeleteButton.Position(2)=app.DeleteButton.Position(2)-30;

            %Add new default dropdown and setting buttons
            app.Dropdownbuttons2{app.CurrentStep2}=uidropdown(app.KP2Tab);
            app.Dropdownbuttons2{app.CurrentStep2}.Tag=strcat('Dropdown2_',num2str(app.CurrentStep2));
            app.Dropdownbuttons2{app.CurrentStep2}.Items = {app.AppStepTypeStyles.stepname};
            %             app.Dropdownbuttons2{app.CurrentStep2}.Position = [28 190-30*(app.CurrentStep2-1) 100 22];
            app.Dropdownbuttons2{app.CurrentStep2}.Position = [28 app.TabGroup.Position(4)-90-30*(app.CurrentStep2-1) 100 22];
            app.Dropdownbuttons2{app.CurrentStep2}.Value = 'Sinusoidal';
            app.Dropdownbuttons2{app.CurrentStep2}.ValueChangedFcn=createCallbackFcn(app, @steptypechanged, true);

            app.Settingsbuttons2{app.CurrentStep2} = uibutton(app.KP2Tab, 'push');
            app.Settingsbuttons2{app.CurrentStep2}.Tag=strcat('Settings2_', num2str(app.CurrentStep2));
            %             app.Settingsbuttons2{app.CurrentStep2}.Position = [142 190-30*(app.CurrentStep2-1) 100 22];
            app.Settingsbuttons2{app.CurrentStep2}.Position = [142 app.TabGroup.Position(4)-90-30*(app.CurrentStep2-1) 100 22];
            app.Settingsbuttons2{app.CurrentStep2}.Text = 'Settings';
            app.Settingsbuttons2{app.CurrentStep2}.ButtonPushedFcn=createCallbackFcn(app, @EditSettings, true);

            %Add to the saved currentsequence with new default settings
            app.CurrentSequence2.step_type{end+1}='Sinusoidal';
            app.CurrentSequence2.settings{end+1}=[1,1,1,0];
            app.CurrentSequence2.varsettings{end+1}={'Manual','Manual','Manual','Manual'};

            if app.CurrentStep2>1
                app.DeleteButton.Visible='on';
            end

        end

        %% Button to delete steps (could use some cleanup)
        function DeletePushedKP1(app, event)
            if app.CurrentStep1>1
                app.CurrentStep1=app.CurrentStep1-1;

                delete(app.Dropdownbuttons1{end});
                app.Dropdownbuttons1(end)=[];
                delete(app.Settingsbuttons1{end});
                app.Settingsbuttons1(end)=[];

                app.AddButton_2.Position(2)=app.TabGroup.Position(4)-127-30*(app.CurrentStep1-1);
                app.DeleteButton_2.Position(2)=app.TabGroup.Position(4)-127-30*(app.CurrentStep1-1);

                app.CurrentSequence1.step_type(end)=[];
                app.CurrentSequence1.settings(end)=[];
                app.CurrentSequence1.varsettings(end)=[];

            end

            if app.CurrentStep1==1
                app.DeleteButton_2.Visible='off';
            end

        end

        function DeletePushedKP2(app, event)
            if app.CurrentStep2>1
                app.CurrentStep2=app.CurrentStep2-1;

                delete(app.Dropdownbuttons2{end});
                app.Dropdownbuttons2(end)=[];
                delete(app.Settingsbuttons2{end});
                app.Settingsbuttons2(end)=[];

                %                 app.AddButton.Position(2)=app.AddButton.Position(2)+30;
                app.AddButton.Position(2)=app.TabGroup.Position(4)-127-30*(app.CurrentStep2-1);
                app.DeleteButton.Position(2)=app.TabGroup.Position(4)-127-30*(app.CurrentStep2-1);
                %                 app.DeleteButton.Position(2)=app.DeleteButton.Position(2)+30;

                app.CurrentSequence2.step_type(end)=[];
                app.CurrentSequence2.settings(end)=[];
                app.CurrentSequence2.varsettings(end)=[];

            end

            if app.CurrentStep2==1
                app.DeleteButton.Visible='off';
            end

        end

        %% Function for saving sequence.
        function SaveSequence1Pushed(app, event)
            if (strcmp(app.DropDown_3.Value, 'New Sequence'))
                NewName='';

                %Create a GUI popup window to create figure
                GetSequenceNameFig = uifigure('Visible', 'off');
                GetSequenceNameFig.Position = [500 500 300 100];
                GetSequenceNameFig.Name = 'Sequence Name. Enter Unique Name';
                set(GetSequenceNameFig, 'CloseRequestFcn', '');


                %Add text field to small GUI
                NameField = uieditfield(GetSequenceNameFig, 'text');
                NameField.Position=[ 10 50 170 22];

                % Create Label To insert sequence name
                NameLabel = uilabel(GetSequenceNameFig);
                NameLabel.Position = [10 70 170 22];
                NameLabel.Text = 'Insert Sequence Name';

                % Create Button to submit name
                EnterNameButton= uibutton(GetSequenceNameFig, 'push');
                EnterNameButton.Position = [10 25 100 22];
                EnterNameButton.Text='Enter';
                EnterNameButton.ButtonPushedFcn=createCallbackFcn(app, @RetrieveName, true);

                GetSequenceNameFig.Visible='on';



                while(strcmp(NewName, ''))
                    pause(1);
                end
                % Save Sequence
                app.CurrentSequence1.name=NewName;
                app.SequenceStruct1(end+1)=app.CurrentSequence1;
                %Update Dropdown sequence list.
                app.DropDown_3.Items = {app.SequenceStruct1.name};
                app.DropDown_3.Value = app.CurrentSequence1.name;
            else
                NameList={app.SequenceStruct1.name};
                sequenceid=find(contains(NameList, app.DropDown_3.Value));
                app.SequenceStruct1(sequenceid)=app.CurrentSequence1;
            end


            a=app.SequenceStruct1;
            save('SequenceFile1.mat', 'a');



            function RetrieveName(app, event)
                if (isempty(find(contains({app.SequenceStruct1.name}, NameField.Value),1)))
                    NewName=NameField.Value;
                    delete(GetSequenceNameFig);
                end
            end


        end

        % Function for pressing save sequence button for KP2
        function SaveSequence2Pushed(app, event)
            if (strcmp(app.DropDown.Value, 'New Sequence'))
                NewName='';

                %Create a GUI popup window to create figure
                GetSequenceNameFig = uifigure('Visible', 'off');
                GetSequenceNameFig.Position = [500 500 300 100];
                GetSequenceNameFig.Name = 'Sequence Name';
                set(GetSequenceNameFig, 'CloseRequestFcn', '');


                %Add text field to small GUI
                NameField = uieditfield(GetSequenceNameFig, 'text');
                NameField.Position=[ 10 50 170 22];

                % Create Label To insert sequence name
                NameLabel = uilabel(GetSequenceNameFig);
                NameLabel.Position = [10 70 170 22];
                NameLabel.Text = 'Insert Sequence Name';

                % Create Button to submit name
                EnterNameButton= uibutton(GetSequenceNameFig, 'push');
                EnterNameButton.Position = [10 25 100 22];
                EnterNameButton.Text='Enter';
                EnterNameButton.ButtonPushedFcn=createCallbackFcn(app, @RetrieveName, true);

                GetSequenceNameFig.Visible='on';



                while(strcmp(NewName, ''))
                    pause(1);
                end
                % Save Sequence
                app.CurrentSequence2.name=NewName;
                app.SequenceStruct2(end+1)=app.CurrentSequence2;
                %Update Dropdown sequence list.
                app.DropDown.Items = {app.SequenceStruct2.name};
                app.DropDown.Value = app.CurrentSequence2.name;
            else
                NameList={app.SequenceStruct2.name};
                sequenceid=find(contains(NameList, app.DropDown.Value));
                app.SequenceStruct2(sequenceid)=app.CurrentSequence2;

            end


            a=app.SequenceStruct2;
            save('SequenceFile2.mat', 'a');


            function RetrieveName(app, event)
                if (isempty(find(contains({app.SequenceStruct2.name}, NameField.Value)))) %#ok<EFIND>
                    NewName=NameField.Value;
                    delete(GetSequenceNameFig);
                end
            end


        end


        %% Save As Functions

        %% Function for saving sequence.
        function SaveAsSequence1Pushed(app, event)

            NewName='';

            %Create a GUI popup window to create figure
            GetSequenceNameFig = uifigure('Visible', 'off');
            GetSequenceNameFig.Position = [500 500 300 100];
            GetSequenceNameFig.Name = 'Sequence Name. Enter Unique Name';
            set(GetSequenceNameFig, 'CloseRequestFcn', '');


            %Add text field to small GUI
            NameField = uieditfield(GetSequenceNameFig, 'text');
            NameField.Position=[ 10 50 170 22];

            % Create Label To insert sequence name
            NameLabel = uilabel(GetSequenceNameFig);
            NameLabel.Position = [10 70 170 22];
            NameLabel.Text = 'Insert Sequence Name';

            % Create Button to submit name
            EnterNameButton= uibutton(GetSequenceNameFig, 'push');
            EnterNameButton.Position = [10 25 100 22];
            EnterNameButton.Text='Enter';
            EnterNameButton.ButtonPushedFcn=createCallbackFcn(app, @RetrieveName, true);

            GetSequenceNameFig.Visible='on';



            while(strcmp(NewName, ''))
                pause(1);
            end
            % Save Sequence
            app.CurrentSequence1.name=NewName;
            app.SequenceStruct1(end+1)=app.CurrentSequence1;
            %Update Dropdown sequence list.
            app.DropDown_3.Items = {app.SequenceStruct1.name};
            app.DropDown_3.Value = app.CurrentSequence1.name;



            a=app.SequenceStruct1;
            save('SequenceFile1.mat', 'a');



            function RetrieveName(app, event)
                if (isempty(find(contains({app.SequenceStruct1.name}, NameField.Value),1)))
                    NewName=NameField.Value;
                    delete(GetSequenceNameFig);
                end
            end


        end

        function SaveAsSequence2Pushed(app, event)
            NewName='';

            %Create a GUI popup window to create figure
            GetSequenceNameFig = uifigure('Visible', 'off');
            GetSequenceNameFig.Position = [500 500 300 100];
            GetSequenceNameFig.Name = 'Sequence Name';
            set(GetSequenceNameFig, 'CloseRequestFcn', '');


            %Add text field to small GUI
            NameField = uieditfield(GetSequenceNameFig, 'text');
            NameField.Position=[ 10 50 170 22];

            % Create Label To insert sequence name
            NameLabel = uilabel(GetSequenceNameFig);
            NameLabel.Position = [10 70 170 22];
            NameLabel.Text = 'Insert Sequence Name';

            % Create Button to submit name
            EnterNameButton= uibutton(GetSequenceNameFig, 'push');
            EnterNameButton.Position = [10 25 100 22];
            EnterNameButton.Text='Enter';
            EnterNameButton.ButtonPushedFcn=createCallbackFcn(app, @RetrieveName, true);

            GetSequenceNameFig.Visible='on';



            while(strcmp(NewName, ''))
                pause(1);
            end
            % Save Sequence
            app.CurrentSequence2.name=NewName;
            app.SequenceStruct2(end+1)=app.CurrentSequence2;
            %Update Dropdown sequence list.
            app.DropDown.Items = {app.SequenceStruct2.name};
            app.DropDown.Value = app.CurrentSequence2.name;



            a=app.SequenceStruct2;
            save('SequenceFile2.mat', 'a');


            function RetrieveName(app, event)
                if (isempty(find(contains({app.SequenceStruct2.name}, NameField.Value)))) %#ok<EFIND>
                    NewName=NameField.Value;
                    delete(GetSequenceNameFig);
                end
            end


        end


        %% Function for deleting sequence

        function DeleteSequence1Pushed(app, event)
            if ~(strcmp(app.DropDown_3.Value, 'New Sequence'))
                SequenceList={app.SequenceStruct1.name};
                oldsequenceid=find(contains(SequenceList, app.DropDown_3.Value));
                app.DropDown_3.Value='New Sequence';
                sequenceid=find(contains(SequenceList, 'New Sequence'));
                %                 clear app.CurrentSequence1;
                app.CurrentSequence1=app.SequenceStruct1(sequenceid);
                app.CurrentStep1=length(app.CurrentSequence1.step_type);
                app.SequenceStruct1(oldsequenceid)=[];
                app.DropDown_3.Items = {app.SequenceStruct1.name};
                %                 disp(oldsequenceid);
                %                 disp(app.SequenceStruct1(oldsequenceid));

                %Delete all existing dropdown for step types and setting
                %buttons
                for i=length(app.Dropdownbuttons1):-1:1
                    delete(app.Dropdownbuttons1{i});
                    delete(app.Settingsbuttons1{i});
                    app.Dropdownbuttons1(i)=[];
                    app.Settingsbuttons1(i)=[];

                end

                %Add new step type lists and setting buttons with new
                %settings

                for i=1:app.CurrentStep1
                    app.Dropdownbuttons1{i}=uidropdown(app.KP1Tab);
                    app.Dropdownbuttons1{i}.Tag=strcat('Dropdown1_',num2str(i));
                    app.Dropdownbuttons1{i}.Items={app.AppStepTypeStyles.stepname};
                    app.Dropdownbuttons1{i}.Position=[28 app.TabGroup.Position(4)-90-30*(i-1) 100 22];
                    app.Dropdownbuttons1{i}.Value=app.CurrentSequence1.step_type{i};
                    app.Dropdownbuttons1{i}.ValueChangedFcn=createCallbackFcn(app, @steptypechanged, true);

                    app.Settingsbuttons1{i} = uibutton(app.KP1Tab, 'push');
                    app.Settingsbuttons1{i}.Tag=strcat('Settings1_', num2str(i));
                    app.Settingsbuttons1{i}.Position = [142 app.TabGroup.Position(4)-90-30*(i-1) 100 22];
                    app.Settingsbuttons1{i}.Text = 'Settings';
                    app.Settingsbuttons1{i}.ButtonPushedFcn=createCallbackFcn(app, @EditSettings, true);



                end

                app.AddButton_2.Position(2)=app.TabGroup.Position(4)-127-30*(app.CurrentStep1-1);
                app.DeleteButton_2.Position(2)=app.TabGroup.Position(4)-127-30*(app.CurrentStep1-1);

                if app.CurrentStep1>1
                    app.DeleteButton_2.Visible='on';
                else
                    app.DeleteButton_2.Visible='off';
                end

                a=app.SequenceStruct1;
                save('SequenceFile1.mat', 'a');
            end
        end


        function DeleteSequence2Pushed(app, event)
            if ~(strcmp(app.DropDown.Value, 'New Sequence'))

                SequenceList={app.SequenceStruct2.name};
                oldsequenceid=find(contains(SequenceList, app.DropDown.Value));
                app.DropDown.Value='New Sequence';
                sequenceid=find(contains(SequenceList, 'New Sequence'));
                app.CurrentSequence2=app.SequenceStruct2(sequenceid);
                app.CurrentStep2=length(app.CurrentSequence2.step_type);
                app.SequenceStruct2(oldsequenceid)=[];
                app.DropDown.Items = {app.SequenceStruct2.name};


                %Delete all existing dropdown for step types and setting
                %buttons
                for i=length(app.Dropdownbuttons2):-1:1
                    delete(app.Dropdownbuttons2{i});
                    delete(app.Settingsbuttons2{i});
                    app.Dropdownbuttons2(i)=[];
                    app.Settingsbuttons2(i)=[];

                end

                %Add new step type lists and setting buttons with new
                %settings

                for i=1:app.CurrentStep2
                    app.Dropdownbuttons2{i}=uidropdown(app.KP2Tab);
                    app.Dropdownbuttons2{i}.Tag=strcat('Dropdown2_',num2str(i));
                    app.Dropdownbuttons2{i}.Items={app.AppStepTypeStyles.stepname};
                    %                     app.Dropdownbuttons2{i}.Position=[28 190-30*(i-1) 100 22];
                    app.Dropdownbuttons2{i}.Position=[28 app.TabGroup.Position(4)-90-30*(i-1) 100 22];
                    app.Dropdownbuttons2{i}.Value=app.CurrentSequence2.step_type{i};
                    app.Dropdownbuttons2{i}.ValueChangedFcn=createCallbackFcn(app, @steptypechanged, true);

                    app.Settingsbuttons2{i} = uibutton(app.KP2Tab, 'push');
                    app.Settingsbuttons2{i}.Tag=strcat('Settings2_', num2str(i));
                    %                     app.Settingsbuttons2{i}.Position = [142 190-30*(i-1) 100 22];
                    app.Settingsbuttons2{i}.Position = [142 app.TabGroup.Position(4)-90-30*(i-1) 100 22];
                    app.Settingsbuttons2{i}.Text = 'Settings';
                    app.Settingsbuttons2{i}.ButtonPushedFcn=createCallbackFcn(app, @EditSettings, true);

                end

                %Adjust add and delete buttons  initial= 28 158 100 22
                app.AddButton.Position(2)=158-30*(app.CurrentStep2-1);
                app.DeleteButton.Position(2)=158-30*(app.CurrentStep2-1);
                app.AddButton.Position(2)=app.TabGroup.Position(4)-127-30*(app.CurrentStep2-1);
                app.DeleteButton.Position(2)=app.TabGroup.Position(4)-127-30*(app.CurrentStep2-1);

                if app.CurrentStep2>1
                    app.DeleteButton.Visible='on';
                else
                    app.DeleteButton.Visible='off';
                end

                a=app.SequenceStruct2;
                save('SequenceFile2.mat', 'a');
            end
        end

        %% Function to press for editing settings (could use some cleanup, need to check is @ChooseVar is necessary)
        function EditSettings(app, event)
            %Retrieve info from which button was pushed to determine which
            %settings to edit.
            ButtonName=event.Source.Tag;
            KPid=str2num(ButtonName(9)); %#ok<ST2NM>
            SequenceStepId=str2num(ButtonName(11:end)); %#ok<ST2NM>

            SettingsSaved=0;

            %Create Window, create with current settings, depending on
            %settings.
            GetSettingsFig = uifigure('Visible', 'off');
            GetSettingsFig.Position = [300 300 400 500];
            GetSettingsFig.Name = strcat('KP', num2str(KPid),' Settings Step ', num2str(SequenceStepId));
            set(GetSettingsFig, 'CloseRequestFcn', '');
            %Grab the setting values and sequence step type;
            if (KPid==1)
                thissettings=app.CurrentSequence1.settings{SequenceStepId};
                thistype=app.CurrentSequence1.step_type{SequenceStepId};
                thisvarsettings=app.CurrentSequence1.varsettings{SequenceStepId};
            else
                thissettings=app.CurrentSequence2.settings{SequenceStepId};
                thistype=app.CurrentSequence2.step_type{SequenceStepId};
                thisvarsettings=app.CurrentSequence2.varsettings{SequenceStepId};
            end

            %Create Labels and Fields

            TopLabelSettings = uilabel(GetSettingsFig);
            TopLabelSettings.Position = [10 480 170 22];
            TopLabelSettings.Text = 'Input Settings';

            %Get the stepstylelist number for the given element.
            styleIndex=find(contains({app.AppStepTypeStyles.stepname}, thistype));
            paramnumber=app.AppStepTypeStyles(styleIndex).varnumber;
            namelist=app.AppStepTypeStyles(styleIndex).varnames;
            defaultvar=app.AppStepTypeStyles(styleIndex).vardefault; %#ok<NASGU>

            Labels=cell(1, paramnumber);
            Fields=cell(1,paramnumber);
            VarDrops=cell(1, paramnumber);

            for i=1:paramnumber
                Labels{i}= uilabel(GetSettingsFig);
                Labels{i}.Position= [10 480-30*i 170 22];
                Labels{i}.Text=namelist{i};

                Fields{i}= uieditfield(GetSettingsFig, 'numeric');
                Fields{i}.Position=[100 480-30*i 80 22];
                Fields{i}.Value=thissettings(i);

                VarDrops{i}=uidropdown(GetSettingsFig);
                VarDrops{i}.Position=[200 480-30*i 80 22];
                VarDrops{i}.Items={'Manual', 'X'} ;
                VarDrops{i}.Value=thisvarsettings{i};
                VarDrops{i}.Tag=strcat('V_', num2str(i));
                %                 VarDrop1.ValueChangedFcn=createCallbackFcn(app, @ChooseVar, true);
            end

            SaveSettingsButton = uibutton(GetSettingsFig, 'push');
            SaveSettingsButton.Position = [10 480-30*(1+paramnumber) 100 22];
            SaveSettingsButton.Text = 'Save';
            SaveSettingsButton.ButtonPushedFcn=createCallbackFcn(app, @SettingsButtonPushed, true);

            %Turn on after creating elements.
            GetSettingsFig.Visible='on';

            while(SettingsSaved==0)
                pause(1);
            end


            function SettingsButtonPushed(app, event)

                thissettings=[];
                thisvarsettings=cell(1, paramnumber);
                for jj=1:paramnumber
                    thissettings(jj)=Fields{jj}.Value;
                    thisvarsettings{jj}=VarDrops{jj}.Value;
                end
                SettingsSaved=1;
                delete(GetSettingsFig);
            end



            if (KPid==1)
                app.CurrentSequence1.settings{SequenceStepId}=thissettings;
                app.CurrentSequence1.varsettings{SequenceStepId}=thisvarsettings;
            else
                app.CurrentSequence2.settings{SequenceStepId}=thissettings;
                app.CurrentSequence2.varsettings{SequenceStepId}=thisvarsettings;
            end
        end


        %% Function to change step style depending on selection for pulse type.

        function steptypechanged(app, event)
            %Retrieve info from which button was pushed to determine which
            %settings to edit.
            ButtonName=event.Source.Tag;
            KPid=str2num(ButtonName(9)); %#ok<ST2NM>
            SequenceStepId=str2num(ButtonName(11:end)); %#ok<ST2NM>

            %Get SequenceType
            newvalue=event.Source.Value;

            %Replace steptype with newvalue
            if (KPid==1)
                app.CurrentSequence1.step_type{SequenceStepId}=newvalue;


                %Get the stepstylelist number for the given element.
                styleIndex=find(contains({app.AppStepTypeStyles.stepname}, newvalue));
                paramnumber=app.AppStepTypeStyles(styleIndex).varnumber;
                defaultvar=app.AppStepTypeStyles(styleIndex).vardefault;

                app.CurrentSequence1.settings{SequenceStepId}=defaultvar;
                varsetcell=cell(1,paramnumber);
                [varsetcell{1:paramnumber}]=deal('Manual');
                app.CurrentSequence1.varsettings{SequenceStepId}=varsetcell;

            else




                app.CurrentSequence2.step_type{SequenceStepId}=newvalue;
                %Replace settingvalues with new defaults.


                %Get the stepstylelist number for the given element.
                styleIndex=find(contains({app.AppStepTypeStyles.stepname}, newvalue));
                paramnumber=app.AppStepTypeStyles(styleIndex).varnumber;
                defaultvar=app.AppStepTypeStyles(styleIndex).vardefault;

                app.CurrentSequence2.settings{SequenceStepId}=defaultvar;
                varsetcell=cell(1,paramnumber);
                [varsetcell{1:paramnumber}]=deal('Manual');
                app.CurrentSequence2.varsettings{SequenceStepId}=varsetcell;

            end



        end


        %% Function for changing Sequence.
        function SequenceChanged(app, event)
            %Figure out if its KP1 or KP2
            SequenceID=event.Source.Tag;
            KPid=str2num(SequenceID); %#ok<ST2NM>

            if (KPid==1)
                %Obtain New Sequence
                SequenceList={app.SequenceStruct1.name};
                sequenceid=find(contains(SequenceList, app.DropDown_3.Value));
                %                 clear app.CurrentSequence1;
                app.CurrentSequence1=app.SequenceStruct1(sequenceid);
                app.CurrentStep1=length(app.CurrentSequence1.step_type);

                %Delete all existing dropdown for step types and setting
                %buttons
                for i=length(app.Dropdownbuttons1):-1:1
                    delete(app.Dropdownbuttons1{i});
                    delete(app.Settingsbuttons1{i});
                    app.Dropdownbuttons1(i)=[];
                    app.Settingsbuttons1(i)=[];

                end

                %Add new step type lists and setting buttons with new
                %settings

                for i=1:app.CurrentStep1
                    app.Dropdownbuttons1{i}=uidropdown(app.KP1Tab);
                    app.Dropdownbuttons1{i}.Tag=strcat('Dropdown1_',num2str(i));
                    app.Dropdownbuttons1{i}.Items={app.AppStepTypeStyles.stepname};
                    app.Dropdownbuttons1{i}.Position=[28 app.TabGroup.Position(4)-90-30*(i-1) 100 22];
                    app.Dropdownbuttons1{i}.Value=app.CurrentSequence1.step_type{i};
                    app.Dropdownbuttons1{i}.ValueChangedFcn=createCallbackFcn(app, @steptypechanged, true);

                    app.Settingsbuttons1{i} = uibutton(app.KP1Tab, 'push');
                    app.Settingsbuttons1{i}.Tag=strcat('Settings1_', num2str(i));
                    app.Settingsbuttons1{i}.Position = [142 app.TabGroup.Position(4)-90-30*(i-1) 100 22];
                    app.Settingsbuttons1{i}.Text = 'Settings';
                    app.Settingsbuttons1{i}.ButtonPushedFcn=createCallbackFcn(app, @EditSettings, true);



                end

                app.AddButton_2.Position(2)=app.TabGroup.Position(4)-127-30*(app.CurrentStep1-1);
                app.DeleteButton_2.Position(2)=app.TabGroup.Position(4)-127-30*(app.CurrentStep1-1);

                if app.CurrentStep1>1
                    app.DeleteButton_2.Visible='on';
                else
                    app.DeleteButton_2.Visible='off';
                end



                %Move the add and delete button to its new proper place.



            else
                SequenceList={app.SequenceStruct2.name};
                sequenceid=find(contains(SequenceList, app.DropDown.Value));
                app.CurrentSequence2=app.SequenceStruct2(sequenceid);
                app.CurrentStep2=length(app.CurrentSequence2.step_type);


                %Delete all existing dropdown for step types and setting
                %buttons
                for i=length(app.Dropdownbuttons2):-1:1
                    delete(app.Dropdownbuttons2{i});
                    delete(app.Settingsbuttons2{i});
                    app.Dropdownbuttons2(i)=[];
                    app.Settingsbuttons2(i)=[];

                end

                %Add new step type lists and setting buttons with new
                %settings

                for i=1:app.CurrentStep2
                    app.Dropdownbuttons2{i}=uidropdown(app.KP2Tab);
                    app.Dropdownbuttons2{i}.Tag=strcat('Dropdown2_',num2str(i));
                    app.Dropdownbuttons2{i}.Items={app.AppStepTypeStyles.stepname};
                    %                     app.Dropdownbuttons2{i}.Position=[28 190-30*(i-1) 100 22];
                    app.Dropdownbuttons2{i}.Position=[28 app.TabGroup.Position(4)-90-30*(i-1) 100 22];
                    app.Dropdownbuttons2{i}.Value=app.CurrentSequence2.step_type{i};
                    app.Dropdownbuttons2{i}.ValueChangedFcn=createCallbackFcn(app, @steptypechanged, true);

                    app.Settingsbuttons2{i} = uibutton(app.KP2Tab, 'push');
                    app.Settingsbuttons2{i}.Tag=strcat('Settings2_', num2str(i));
                    %                     app.Settingsbuttons2{i}.Position = [142 190-30*(i-1) 100 22];
                    app.Settingsbuttons2{i}.Position = [142 app.TabGroup.Position(4)-90-30*(i-1) 100 22];
                    app.Settingsbuttons2{i}.Text = 'Settings';
                    app.Settingsbuttons2{i}.ButtonPushedFcn=createCallbackFcn(app, @EditSettings, true);

                end

                %Adjust add and delete buttons  initial= 28 158 100 22
                app.AddButton.Position(2)=158-30*(app.CurrentStep2-1);
                app.DeleteButton.Position(2)=158-30*(app.CurrentStep2-1);
                app.AddButton.Position(2)=app.TabGroup.Position(4)-127-30*(app.CurrentStep2-1);
                app.DeleteButton.Position(2)=app.TabGroup.Position(4)-127-30*(app.CurrentStep2-1);

                if app.CurrentStep2>1
                    app.DeleteButton.Visible='on';
                else
                    app.DeleteButton.Visible='off';
                end
            end

        end



        %% Function for changing number of elements in the table for variables
        function TableSizeChanged(app, event)
            newSize=app.VarSizeField.Value;
            if floor(newSize)==newSize
                newSize=floor(newSize);%Check if current data is longer than x
                if newSize>length(app.CurrentVarData)
                    oldSize=length(app.CurrentVarData);
                    app.CurrentVarData=[app.CurrentVarData; zeros((newSize-oldSize),1)];
                else
                    app.CurrentVarData=app.CurrentVarData(1:newSize);
                end
                app.VarTable.Data=app.CurrentVarData;
            end

        end

        %% Function for editing table
        function EditVarTable(app, event)
            app.CurrentVarData=app.VarTable.Data;
        end

        function FillVarPushed(app, event)
            app.CurrentVarData=(app.VarStartField.Value:app.VarStepField.Value:app.VarStopField.Value)';
            app.VarTable.Data=app.CurrentVarData;
            app.VarSizeField.Value=length(app.VarTable.Data);
        end

        %% Function for updating screen
        % function checkRfappdiary(app, obj, event)
        %     [~, w]=system('powershell -command "& {Get-Content rfappdiary | Select-Object -last 3}"');
        %     app.RFMessagesLabel.Text = ['Message Log:' newline w];
        %     pause(0.001);
        % end

        %% Function for resizing KP1

        function resizeKP1(app, event)
            %KP1adjust
            app.DropDown_3.Position(2) = app.TabGroup.Position(4)-61;
            app.SaveSequenceButton.Position(2)= app.TabGroup.Position(4)-61;
            app.DeleteSequenceButton.Position(2)=app.TabGroup.Position(4)-91;
            app.SaveAsSeqButton.Position(2)=app.TabGroup.Position(4)-121;
            for i=1:app.CurrentStep1
                app.Dropdownbuttons1{i}.Position(2) = app.TabGroup.Position(4)-90-30*(i-1);
                app.Settingsbuttons1{i}.Position(2) = app.TabGroup.Position(4)-90-30*(i-1);
            end
            app.AddButton_2.Position(2)=app.TabGroup.Position(4)-127-30*(app.CurrentStep1-1);
            app.DeleteButton_2.Position(2)=app.TabGroup.Position(4)-127-30*(app.CurrentStep1-1);

            %KP2 adjust
            app.DropDown.Position(2)=app.TabGroup.Position(4)-61;
            app.SaveSequenceButton_2.Position(2)= app.TabGroup.Position(4)-61;
            app.DeleteSequenceButton_2.Position(2)=app.TabGroup.Position(4)-91;
            app.SaveAsSeqButton_2.Position(2)=app.TabGroup.Position(4)-121;
            for i=1:app.CurrentStep2
                app.Dropdownbuttons2{i}.Position(2) = app.TabGroup.Position(4)-90-30*(i-1);
                app.Settingsbuttons2{i}.Position(2) = app.TabGroup.Position(4)-90-30*(i-1);
            end
            app.AddButton.Position(2)=app.TabGroup.Position(4)-127-30*(app.CurrentStep2-1);
            app.DeleteButton.Position(2)=app.TabGroup.Position(4)-127-30*(app.CurrentStep2-1);




        end

        % function enableLogFunc(app, event)
        %     if app.logEnableCheckbox.Value==1
        %         diary on;
        %     else
        %         diary off;
        %     end
        % end
    end

    %%  Component initialization (Setup everything: initial information, all app objects to interface with, etc.)
    methods (Access = public)

        % Create UIFigure and components
        function createComponents(app)

            % Load Initial Settings from Structure


            %Load StepTypeStyles
            load('StepTypeStyles.mat', 'StepTypeStyles');
            app.AppStepTypeStyles=StepTypeStyles;


            %Location of saved sequences for this stuff. Create the initial
            %empty sequence and load list of sequence. Make a new file if
            %the preexisting one doesn't exist.
            app.VariableList={'X'};
            app.CurrentSequence1.name='New Sequence';
            app.CurrentSequence1.step_type={'Sinusoidal'};
            app.CurrentSequence1.settings={[1e-3, 50e3, 0.5, 0]}; %Enter default sinusoidal settings (Length (s), Freq (Hz), Amp (V), Phase (rad))
            app.CurrentSequence1.varsettings={{'Manual', 'Manual', 'Manual', 'Manual'}};
            app.CurrentStep1=1;
            app.CurrentSequence2.name='New Sequence';
            app.CurrentSequence2.step_type={'Sinusoidal'};
            app.CurrentSequence2.settings={[1e-3,50e3,0.5,0]}; %Enter default sinusoidal settings
            app.CurrentSequence2.varsettings={{'Manual', 'Manual', 'Manual', 'Manual'}};
            app.CurrentStep2=1;
            %Change location when trying new place, or set to local folder
            SequenceFile1='C:\Users\nolas\Documents\Weld Group Research\MATLAB projects\RF mod interface\SequenceFile1.mat'; %#ok<NASGU>
            SequenceFile2='C:\Users\nolas\Documents\Weld Group Research\MATLAB projects\RF mod interface\SequenceFile2.mat'; %#ok<NASGU>
            if isfile('SequenceFile1.mat') %Might want some code to ensure this has the correct format (unless the file is never touched)
                app.SequenceStruct1=load('SequenceFile1.mat').a;
                app.CurrentSequence1=app.SequenceStruct1(1);
            else
                app.SequenceStruct1=struct('name', {}, 'step_type', {}, ...
                    'settings', [], 'varsettings', {});
                app.SequenceStruct1(1)=app.CurrentSequence1;
                a=app.SequenceStruct1;
                save('SequenceFile1.mat', 'a')
            end

            if isfile('SequenceFile2.mat') %Might want some code to ensure this has the correct format (unless the file is never touched)
                app.SequenceStruct2=load('SequenceFile2.mat').a;
                app.CurrentSequence2=app.SequenceStruct2(1);
            else
                app.SequenceStruct2=struct('name', {}, 'step_type', {}, ...
                    'settings', [], 'varsettings', {});
                app.SequenceStruct2(1)=app.CurrentSequence2;
                a=app.SequenceStruct2;
                save('SequenceFile2.mat', 'a')
            end

            % Create VarData for initial step
            app.CurrentVarData=[0]; %#ok<NBRAK2>

            % Set ForceTrigVal
            app.ForceTrigVal=0;

            % Set AbortVal
            app.AbortVal=0;

            % Set debug value
            app.debug=0;

            %Start diary components
            % diary off
            % if isfile('rfappdiary')
            %     delete rfappdiary
            % end
            % diary rfappdiary

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 744 520];
            app.UIFigure.Name = 'MATLAB App';

            % Create RunModeButtonGroup
            app.RunModeButtonGroup = uibuttongroup(app.UIFigure);
            app.RunModeButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @RunModeButtonGroupSelectionChanged, true);
            app.RunModeButtonGroup.Title = 'Run Mode';
            app.RunModeButtonGroup.Position = [30 423 242 51];

            % Create SingleRunButton
            app.SingleRunButton = uiradiobutton(app.RunModeButtonGroup);
            app.SingleRunButton.Text = 'Single Run';
            app.SingleRunButton.Position = [11 5 79 22];
            app.SingleRunButton.Value = true;

            % Create ListButton
            app.ListButton = uiradiobutton(app.RunModeButtonGroup);
            app.ListButton.Text = 'List';
            app.ListButton.Position = [94 5 79 22];

            % Create CiceroButton
            app.CiceroButton = uiradiobutton(app.RunModeButtonGroup);
            app.CiceroButton.Text = 'Cicero';
            app.CiceroButton.Position = [176 5 79 22];

            % Create OutputButtonGroup
            app.OutputButtonGroup = uibuttongroup(app.UIFigure);
            app.OutputButtonGroup.Title = 'Output';
            app.OutputButtonGroup.Position = [494 431 123 74];

            % Create BusButton
            app.BusButton = uiradiobutton(app.OutputButtonGroup);
            app.BusButton.Text = 'Bus';
            app.BusButton.Position = [11 28 58 22];
            app.BusButton.Value = true;

            % Create ExternalButton
            app.ExternalButton = uiradiobutton(app.OutputButtonGroup);
            app.ExternalButton.Text = 'External';
            app.ExternalButton.Position = [11 6 66 22];

            % Create BuildButton
            app.BuildButton = uibutton(app.UIFigure, 'push');
            app.BuildButton.Position = [30 78 100 22];
            app.BuildButton.Text = 'Build';
            app.BuildButton.ButtonPushedFcn=createCallbackFcn(app, @BuildButtonPushed, true);

            % Create RFGUIv1Label
            app.RFGUIv1Label = uilabel(app.UIFigure);
            app.RFGUIv1Label.Position = [30 483 62 22];
            app.RFGUIv1Label.Text = 'RF GUI v6';

            % Create UploadButton
            app.UploadButton = uibutton(app.UIFigure, 'push');
            app.UploadButton.Position = [157 78 100 22];
            app.UploadButton.Text = 'Upload';
            app.UploadButton.ButtonPushedFcn=createCallbackFcn(app, @UploadButtonPushed, true);

            % Create AbortButton
            app.AbortButton = uibutton(app.UIFigure, 'push');
            app.AbortButton.Position = [284 78 100 22];
            app.AbortButton.Text = 'Abort';
            app.AbortButton.ButtonPushedFcn=createCallbackFcn(app, @AbortButtonPushed, true);

            %             app.ForceTrig = uibutton(app.UIFigure, 'push');
            %             app.ForceTrig.Position = [411 78 100 22];
            %             app.ForceTrig.Text = 'Force Trigger';
            %             app.ForceTrig.ButtonPushedFcn=createCallbackFcn(app, @ForceTrigPushed, true);
            %             app.ForceTrig.Visible='on';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [30 122 533 280];
            app.TabGroup.SizeChangedFcn=createCallbackFcn(app, @resizeKP1, true);
            app.TabGroup.AutoResizeChildren='off';

            % Create KP1Tab
            app.KP1Tab = uitab(app.TabGroup);
            app.KP1Tab.Title = 'KP1';

            % Create DropDown_3
            app.DropDown_3 = uidropdown(app.KP1Tab);
            % Insert elements from CurrentSequence1.
            app.DropDown_3.Position = [28 219 100 22];
            app.DropDown_3.Items = {app.SequenceStruct1.name};
            app.DropDown_3.Value = 'New Sequence';
            app.DropDown_3.Tag='01';
            app.DropDown_3.ValueChangedFcn=createCallbackFcn(app, @SequenceChanged, true);


            % Create SettingsButton
            %             app.SettingsButton = uibutton(app.KP1Tab, 'push');
            %             app.SettingsButton.Position = [142 190 100 22];
            %             app.SettingsButton.Text = 'Settings';

            % Create DropDown_4
            %             app.DropDown_4 = uidropdown(app.KP1Tab);
            %             app.DropDown_4.Items = {'Sinusoidal', 'Pulse'};
            %             app.DropDown_4.Position = [28 190 100 22];
            %             app.DropDown_4.Value = 'Sinusoidal';


            %Create a list for all the settings buttons and dropdown lists in KP1
            app.Dropdownbuttons1={};
            app.Settingsbuttons1={};


            app.Dropdownbuttons1{1}=uidropdown(app.KP1Tab);
            app.Dropdownbuttons1{1}.Tag='Dropdown1_01';
            app.Dropdownbuttons1{1}.Items = {app.AppStepTypeStyles.stepname};
            app.Dropdownbuttons1{1}.Position = [28 190 100 22];
            app.Dropdownbuttons1{1}.Value = 'Sinusoidal';
            app.Dropdownbuttons1{1}.ValueChangedFcn=createCallbackFcn(app, @steptypechanged, true);

            app.Settingsbuttons1{1} = uibutton(app.KP1Tab, 'push');
            app.Settingsbuttons1{1}.Tag='Settings1_01';
            app.Settingsbuttons1{1}.Position = [142 190 100 22];
            app.Settingsbuttons1{1}.Text = 'Settings';
            app.Settingsbuttons1{1}.ButtonPushedFcn=createCallbackFcn(app, @EditSettings, true);

            % Create AddButton_2
            app.AddButton_2 = uibutton(app.KP1Tab, 'push');
            app.AddButton_2.Position = [28 158 100 22];
            app.AddButton_2.Text = 'Add';
            app.AddButton_2.ButtonPushedFcn=createCallbackFcn(app, @AddPushedKP1, true);

            % Create DeleteButton_2
            app.DeleteButton_2 = uibutton(app.KP1Tab, 'push');
            app.DeleteButton_2.Position = [142 158 100 22];
            app.DeleteButton_2.Text = 'Delete';
            app.DeleteButton_2.Visible = 'off';
            app.DeleteButton_2.ButtonPushedFcn=createCallbackFcn(app, @DeletePushedKP1, true);

            % Create SaveSequenceButton
            app.SaveSequenceButton = uibutton(app.KP1Tab, 'push');
            app.SaveSequenceButton.Position = [400 219 120 22];
            app.SaveSequenceButton.Text = 'Save Sequence';
            app.SaveSequenceButton.ButtonPushedFcn=createCallbackFcn(app, @SaveSequence1Pushed, true);

            % Create DeleteSequenceButton
            app.DeleteSequenceButton = uibutton(app.KP1Tab, 'push');
            app.DeleteSequenceButton.Position = [400 219-30 120 22];
            app.DeleteSequenceButton.Text = 'Delete Sequence';
            app.DeleteSequenceButton.ButtonPushedFcn=createCallbackFcn(app, @DeleteSequence1Pushed, true);

            % Create SaveAsSeqButton
            app.SaveAsSeqButton = uibutton(app.KP1Tab, 'push');
            app.SaveAsSeqButton.Position = [400 219-60 120 22];
            app.SaveAsSeqButton.Text = 'Save Sequence As';
            app.SaveAsSeqButton.ButtonPushedFcn=createCallbackFcn(app, @SaveAsSequence1Pushed, true);

            % Create KP2Tab
            app.KP2Tab = uitab(app.TabGroup);
            app.KP2Tab.Title = 'KP2';
            app.KP2Tab.Scrollable = 'on';


            app.Dropdownbuttons2={};
            app.Settingsbuttons2={};

            % Create DropDown
            app.DropDown = uidropdown(app.KP2Tab);
            app.DropDown.Items = {app.SequenceStruct2.name};
            app.DropDown.Position = [28 219 100 22];
            app.DropDown.Value = 'New Sequence';
            app.DropDown.Tag = '02';
            app.DropDown.ValueChangedFcn=createCallbackFcn(app, @SequenceChanged, true);

            % Create SettingsButton_2
            app.Settingsbuttons2{1} = uibutton(app.KP2Tab, 'push');
            app.Settingsbuttons2{1}.Position = [142 190 100 22];
            app.Settingsbuttons2{1}.Text = 'Settings';
            app.Settingsbuttons2{1}.Tag='Settings2_01';
            app.Settingsbuttons2{1}.ButtonPushedFcn=createCallbackFcn(app, @EditSettings, true);


            % Create DropDown_2
            app.Dropdownbuttons2{1} = uidropdown(app.KP2Tab);
            app.Dropdownbuttons2{1}.Position = [28 190 100 22];
            app.Dropdownbuttons2{1}.Items = {app.AppStepTypeStyles.stepname};
            app.Dropdownbuttons2{1}.Value = 'Sinusoidal';
            app.Dropdownbuttons2{1}.Tag='Dropdown2_01';
            app.Dropdownbuttons2{1}.ValueChangedFcn=createCallbackFcn(app, @steptypechanged, true);

            % Create AddButton
            app.AddButton = uibutton(app.KP2Tab, 'push');
            app.AddButton.Position = [28 158 100 22];
            app.AddButton.Text = 'Add';
            app.AddButton.ButtonPushedFcn=createCallbackFcn(app, @AddPushedKP2, true);

            % Create DeleteButton
            app.DeleteButton = uibutton(app.KP2Tab, 'push');
            app.DeleteButton.Position = [142 158 100 22];
            app.DeleteButton.Text = 'Delete';
            app.DeleteButton.Visible = 'off';
            app.DeleteButton.ButtonPushedFcn=createCallbackFcn(app, @DeletePushedKP2, true);

            % Create SaveSequenceButton_2
            app.SaveSequenceButton_2 = uibutton(app.KP2Tab, 'push');
            app.SaveSequenceButton_2.Position = [400 219 120 22];
            app.SaveSequenceButton_2.Text = 'Save Sequence';
            app.SaveSequenceButton_2.ButtonPushedFcn=createCallbackFcn(app, @SaveSequence2Pushed, true);

            % Create DeleteSequenceButton_2
            app.DeleteSequenceButton_2 = uibutton(app.KP2Tab, 'push');
            app.DeleteSequenceButton_2.Position = [400 219-30 120 22];
            app.DeleteSequenceButton_2.Text = 'Delete Sequence';
            app.DeleteSequenceButton_2.ButtonPushedFcn=createCallbackFcn(app, @DeleteSequence2Pushed, true);

            % Create SaveAsSeqButton
            app.SaveAsSeqButton_2 = uibutton(app.KP2Tab, 'push');
            app.SaveAsSeqButton_2.Position = [400 219-60 120 22];
            app.SaveAsSeqButton_2.Text = 'Save Sequence As';
            app.SaveAsSeqButton_2.ButtonPushedFcn=createCallbackFcn(app, @SaveAsSequence2Pushed, true);

            % Create VariableTab
            app.VarTab = uitab(app.TabGroup);
            app.VarTab.Title = 'Variables';

            app.VarSizeField = uieditfield(app.VarTab, 'numeric');
            app.VarSizeField.Position=[98 210 100 22];
            app.VarSizeField.Value=1;
            app.VarSizeField.ValueChangedFcn=createCallbackFcn(app, @TableSizeChanged, true);

            app.VarTable=uitable(app.VarTab);
            app.VarTable.ColumnName={'X'};
            app.VarTable.ColumnEditable=true;
            app.VarTable.Data=app.CurrentVarData;
            app.VarTable.Position = [54 20 130 185];
            app.VarTable.CellEditCallback=createCallbackFcn(app, @EditVarTable, true);

            app.VarStartField = uieditfield(app.VarTab, 'numeric');
            app.VarStartField.Position=[298 210 100 22];
            app.VarStartField.Value=0;

            app.VarStopField = uieditfield(app.VarTab, 'numeric');
            app.VarStopField.Position=[298 180 100 22];
            app.VarStopField.Value=0;

            app.VarStepField = uieditfield(app.VarTab, 'numeric');
            app.VarStepField.Position=[298 150 100 22];
            app.VarStepField.Value=0;

            app.FillVarButton = uibutton(app.VarTab, 'push');
            app.FillVarButton.Position=[298 120 100 22];
            app.FillVarButton.Text='Fill';
            app.FillVarButton.ButtonPushedFcn=createCallbackFcn(app, @FillVarPushed, true);

            app.VarStartText=uilabel(app.VarTab);
            app.VarStartText.Position=[258 210 100 22];
            app.VarStartText.Text='Start';

            app.VarStartText=uilabel(app.VarTab);
            app.VarStartText.Position=[258 180 100 22];
            app.VarStartText.Text='Stop';

            app.VarStartText=uilabel(app.VarTab);
            app.VarStartText.Position=[258 150 100 22];
            app.VarStartText.Text='Step';

            app.VarLoopText=uilabel(app.VarTab);
            app.VarLoopText.Position=[258 60 100 22];
            app.VarLoopText.Text='Loops';

            app.VarLoopField = uieditfield(app.VarTab, 'numeric');
            app.VarLoopField.Position=[298 60 100 22];
            app.VarLoopField.Value=1;

            % Create KP1Tab
            app.PlotTab = uitab(app.TabGroup);
            app.PlotTab.Title = 'Plot';

            % Create KP1Plot
            app.KP1Plot = uiaxes(app.PlotTab);
            title(app.KP1Plot, 'KP1')
            xlabel(app.KP1Plot, 't')
            ylabel(app.KP1Plot, 'V')
            %             zlabel(app.UIAxes, 'Z')
            app.KP1Plot.Position = [10 10 250 200];

            %              Create KP2Plot
            app.KP2Plot = uiaxes(app.PlotTab);
            title(app.KP2Plot, 'KP2')
            xlabel(app.KP2Plot, 't')
            ylabel(app.KP2Plot, 'V')
            %             zlabel(app.KP2Plots, 'Z')
            app.KP2Plot.Position = [270 10 250 200];




            % Create RFMessageLabel for logs
            app.RFMessagesLabel = uilabel(app.UIFigure);
            app.RFMessagesLabel.Position = [30 10 400 70];
            app.RFMessagesLabel.Text = ['Message Log:' newline newline newline newline];

            %Create Timer
            app.timer_messages=timer('Period',1,'ExecutionMode','FixedSpacing');
            app.timer_messages.StartDelay=0.0;
            app.timer_messages.Name='checkDiary';
            % app.timer_messages.TimerFcn=@app.checkRfappdiary;
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';


            app.logEnableCheckbox=uicheckbox(app.UIFigure);
            app.logEnableCheckbox.Text='Enable Log Recording';
            app.logEnableCheckbox.Position=[500 10 200 22];

            % %             Create KP1Plot
            %             app.CircleLocation = uiaxes(app.UIFigure);
            % %             title(app.KP1Plot, 'KP1')
            % %             xlabel(app.KP1Plot, 't')
            % %             ylabel(app.KP1Plot, 'V')
            % %             zlabel(app.UIAxes, 'Z')
            %             app.CircleLocation.Color='none';
            %             app.CircleLocation.Position = [500 30 60 60];
            %
            % %             app.CircleAx=
            % %             app.CircleItem=viscircles(app.CircleLocation, [25,25], 25, 'Color', 'red');
            %               app.CircleItem=insertShape(app.CircleLocation, 'FilledCircle',[30 30 30],'color','red','LineWidth',5);

            app.Lamp= uilamp(app.UIFigure);
            app.Lamp.Position = [600 50 30 30];

            %             diary on
            % start(app.timer_messages);
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = rfappv7
            %             warning('off', 'all')
            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)


            if nargout == 0
                clear app
            end

            %Start Timers for automatic message check
            %             timer_messages.StartFcn=@startTimerFcn;
            %             timer_messages.StopFcn=@stopTimerFcn;
            %             pause(0.25)


        end

        % Code that executes before app deletion
        function delete(app)
            stop(app.timer_messages);
            % diary off
            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end