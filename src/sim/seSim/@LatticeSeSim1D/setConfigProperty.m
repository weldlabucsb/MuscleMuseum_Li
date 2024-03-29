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

