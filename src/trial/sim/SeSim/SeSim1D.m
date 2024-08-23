classdef SeSim1D < TimeSim & SpaceSim
    %SESIM Summary of this class goes here
    %   Detailed explanation goes here

    properties

    end

    methods
        function obj = SeSim1D(trialName,config)
            %SESIM Construct an instance of this class
            %   Detailed explanation goes here
            % obj.Property1 = inputArg1 + inputArg2;
            obj@TimeSim(trialName,config);
        end

        function  setConfigProperty(obj,s)
            %This method compares the properties of the handle object 'obj' with
            %the fields of a structure 'struct'. Then it sets the properties to the
            %values of the fields. The obj must inherit the set method from
            %matlab.mixin.SetGetExactNames
            mc = metaclass(obj); %use metaclass to access non-public properties
            propList = {mc.PropertyList.Name};
            fieldList = fieldnames(s);
            [~,ia,ib] = intersect(propList,fieldList);
            structcell = struct2cell(s);
            set(obj,propList(ia)',structcell(ib)')
        end

        function updateDatabase(obj)
            sData = struct(obj);
            tData = struct2table(sData,AsArray=true);
            rf = rowfilter('SerialNumber');
            rf = rf.SerialNumber == obj.SerialNumber;
            pgUpdate(obj.Writer,obj.DatabaseTableName,tData,rf);
        end

        function writeDatabase(obj)
            sData = struct(obj);
            tData = struct2table(sData,AsArray=true);
            pgWrite(obj.Writer,obj.DatabaseTableName,tData);
        end

    end
end

