function sData = readCiceroLog(obj,runIdx)
runIdx = string(runIdx(:));
logName = fullfile(obj.CiceroLogPath,obj.DataPrefix) + "_" + runIdx ...
    + ".clg";
dataStructuresLibrary=[matlabroot '\bin\win64\DataStructures.dll'];
ds=NET.addAssembly(dataStructuresLibrary);
import ds.*
serializer=System.Runtime.Serialization.Formatters.Binary.BinaryFormatter;
sData=struct;
for ii = 1:numel(runIdx)
    inputstream=System.IO.FileStream(logName(ii),...
        System.IO.FileMode.Open,System.IO.FileAccess.Read,System.IO.FileShare.Read);
    ret_obj=serializer.Deserialize(inputstream);
    for kk=1:ret_obj.RunSequence.Variables.Count
        thisvar=Item(ret_obj.RunSequence.Variables,kk-1);
        variable_name=strrep(char(thisvar.VariableName), ' ', '');
        variable_value=double(thisvar.VariableValue);
        if ii > 1
            sData.(variable_name)=[sData.(variable_name),variable_value];
        else
            sData.(variable_name)=variable_value;
        end
    end
    % for kk=1:ret_obj.RunSettings.PermanentVariables.Count
    %     thisvar=Item(ret_obj.RunSequence.Variables,kk-1);
    %     variable_name=strrep(char(thisvar.VariableName), ' ', '');
    %     variable_value=double(thisvar.VariableValue);
    %     if ii > 1
    %         sData.(variable_name)=[sData.(variable_name),variable_value];
    %     else
    %         sData.(variable_name)=variable_value;
    %     end
    % end

    inputstream.Close %Need to be closed otherwise we can not delete the log file if we want
end
end
