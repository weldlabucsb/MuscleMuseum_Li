classdef Constants
    %Constants Physical constants.
    %   The values are taken from Daniel Steck's notes. The default values
    %   are in SI units. Calling Constant.### can load the constants into the
    %   caller workspace (### stands for SI, Micro). Calling Constant.###(name)
    %   can return the value of the constant in that units. Here name is the
    %   varialbe name string of the corresponding constant, which is listed
    %   bellow.
    
    properties (Constant)
        SpeedOfLight = 2.99792458e8 % c.
        VacuumPermeability = 4*pi*1e-7 % mu0.
        VacuumPermittivity = 8.854187817e-12 % epsilon0.
        ReducedPlanckConstant = 1.054571628e-34 % hbar.
        ElementaryCharge = 1.602176487e-19 % e.
        BohrMagneton = 9.27400915e-24 % muB.
        ElectronMass = 9.10938215e-31 % me.
        BohrRadius = 0.52917720859e-10 % a0.
        BoltzmannConstant = 1.3806504e-23 % kB.
        VacuumImpedance = 1/Constants.VacuumPermittivity/Constants.SpeedOfLight % Z0.
        ElectronSpin = 0.5 % Se.
        ElectronGFactor = 2.0023193043622 % gS.
    end
    
    properties (Constant, Hidden)
        List = struct('Name',{"c","mu0","epsilon0","hbar","e","muB","me","a0","kB","Z0","Se","gS"},...
            "Value",{Constants.SpeedOfLight,Constants.VacuumPermeability,Constants.VacuumPermittivity,...
            Constants.ReducedPlanckConstant,Constants.ElementaryCharge,Constants.BohrMagneton,...
            Constants.ElectronMass,Constants.BohrRadius,Constants.BoltzmannConstant,Constants.VacuumImpedance,...
            Constants.ElectronSpin,Constants.ElectronGFactor});
    end
    
    methods (Static)
        
        function constantValue = SI(constantName)
            %Load constants in SI units into the caller workspace
            vList = Constants.List;
            callerList = convertCharsToStrings(evalin('caller','who'));
            if nargin == 1
                names = [vList.Name];
                constantValue = vList(names == constantName).Value;
                return
            end 
            
            for iVar = 1:numel(vList)
                name = vList(iVar).Name;
                value = vList(iVar).Value;
                if find(callerList == name)
                    if evalin('caller',name) ~= value
                        warning(strcat("Variable ",name," already exists."))
                    end
                else
                    assignin('caller',name,value)
                end
            end
        end
        
        function constantValue = Micro(constantName)
            %Load constants in micron - micro-second - kilogram units into the caller workspace
            vList = Constants.List;
            vList(1).Value = vList(1).Value;
            vList(2).Value = vList(2).Value*1e-6;
            vList(3).Value = vList(3).Value*1e6;
            vList(4).Value = vList(4).Value*1e6;
            vList(5).Value = vList(5).Value*1e6;
            vList(6).Value = vList(6).Value*1e12;
            vList(7).Value = vList(7).Value*1e12;
            vList(8).Value = vList(8).Value*1e6;
            vList(9).Value = vList(9).Value;
            vList(10).Value = vList(10).Value*1e-6;
            callerList = convertCharsToStrings(evalin('caller','who'));
            
            if nargin == 1
                names = [vList.Name];
                constantValue = vList(names == constantName).Value;
                return
            end 
            
            for iVar = 1:numel(vList)
                name = vList(iVar).Name;
                value = vList(iVar).Value;
                if find(callerList == name)
                    if evalin('caller',name) ~= value
                        warning(strcat("Variable ",name," already exists."))
                    end
                else
                    assignin('caller',name,value)
                end
            end
        end
        
    end
end

