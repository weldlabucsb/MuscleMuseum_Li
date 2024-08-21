function propList = getProperty(className)
%GETPROPERTY Summary of this function goes here
%   Detailed explanation goes here
arguments
    className string
end
c = meta.class.fromName(className);
p = c.PropertyList;
propList = string({p.Name});
propList = propList(~[p.Dependent]);
end

