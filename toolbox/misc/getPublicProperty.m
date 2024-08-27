function propList = getPublicProperty(className)
%GETPUBLICPROPERTIES Summary of this function goes here
%   Detailed explanation goes here
arguments
    className string
end
c = meta.class.fromName(className);
p = c.PropertyList;
propList = string({p.Name});
propList = propList(string({p.GetAccess}) == "public" & string({p.SetAccess}) == "public" & ~[p.Dependent]);
end

