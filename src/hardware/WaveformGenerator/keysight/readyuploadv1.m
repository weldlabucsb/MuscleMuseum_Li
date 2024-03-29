
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
        IP= '169.254.164.89';       %Eber's Red Pitaya Address
        port = 5000;
        tcpipObj=tcpip(IP, port); %#ok<TCPC> 
        
        tcpipObj.InputBufferSize = 16384*64;
        tcpipObj.InputBufferSize = 16384*12;

        tcpipObj.OutputBufferSize = 16384*64;
        flushinput(tcpipObj)
        flushoutput(tcpipObj)
        
        x=instrfind;
        try fclose(x);
        catch
        end
        instrreset
%                     
        var=app.CurrentVarData;
        loopreps=app.VarLoopField.Value;

        flag=0;
        
        for nn=1:loopreps
        for ii=1:length(var)
            disp(ii);
            if ~app.debug
                try 
                    fopen(tcpipObj);
                    
                    tcpipObj.Terminator = 'CR/LF';
                    fprintf(tcpipObj,'ACQ:RST');
                    fprintf(tcpipObj,'DEC:64');
                    fprintf(tcpipObj,'ACQ:TRIG:LEV 1500 mV');
                    fprintf(tcpipObj,'ACQ:START');
                    pause(1);
                    fprintf(tcpipObj,'ACQ:TRIG CH1_PE');
                    pause(1);
%                             disp('debugging');
                catch
                    disp('Red Pitaya failure');
                    app.AbortVal=1;
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
                    trig_rsp=query(tcpipObj,'ACQ:TRIG:STAT?');
%                             disp(trig_rsp);
                    if strcmp('TD',trig_rsp(1:2)) % Read only TD
                        disp('triggered!')
                        clear trig_rsp;
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
                x=instrfind;
                fclose(x);
                break
            end
            uistylenew=uistyle('BackgroundColor', [1 .5 .5]);
            removeStyle(app.VarTable);
            addStyle(app.VarTable, uistylenew, 'cell', [ii, 1]);
            
%                         
        %Grab list of variable.
        %Wait for trig
        %Update Variable
            UploadButtonScriptv4

            pause(0.5);
            %Close instr
            x=instrfind;
            fclose(x);
            instrreset

        end
        end
    removeStyle(app.VarTable);
    delete(app.ForceTrig);
        
end