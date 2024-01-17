classdef (Abstract) Atom < dynamicprops & handle & matlab.mixin.Heterogeneous
    %ATOM The Atom class stores information about alkali/divalent atoms  
    %and calculates the atomic structure.
    %   This class is based on the well-known python package, ARC 
    %   (Alkali.ne Rydberg Calculator). Most (but not all) of the atomic
    %   data are inherited from the ARC package. Not all the ARC package
    %   functions are used, because of some defects in that package and
    %   some convetion conflicts.
    %   
    %   When an Atom object is constructed, it reads data from the
    %   corresponding ARC atom object and saves them as its own properties.
    %   The ArcObj is also saved for later use.
    
    properties (SetAccess = protected)
        Name string % Lithium7, for example. Check the ARC documents for available atoms.
        DataPath string % Where to save the pre-calcualted data, for example, the MI,MJ <-> F,MF correspondence
    end

    properties (SetAccess = private, Hidden)
        ArcObj % The ARC atom object
        Type string % Either alkali or Divalent
    end
    
    methods
        function obj = Atom(atomName)
            obj.Name = atomName; 
            arc = py.importlib.import_module('arcDataEdit'); % Import the ARC python package. The package is edited to include more accurate atomic data.
            pyType = py.importlib.import_module('getTypeNature'); % Import this python module for resolving type name/attributes etc.
            try
                obj.ArcObj = arc.(atomName)(preferQuantumDefects=false); % Load the ARC atom object
            catch
                error(atomName + " is not a valid isotope name in the python ARC package.")
            end

            % Wrtie python object properties into matlab object properties
            s = struct(pyType.attributes(obj.ArcObj));  
            fieldList = fieldnames(s);
            for ii = 1:numel(fieldList)
                addprop(obj,fieldList{ii}); % Add properties
                obj.(fieldList{ii}) = py2Mat(s.(fieldList{ii})); % Convert python data type to matlab data type.
            end
            
            % Check the atom type
            tName = string(pyType.baseTypeName(obj.ArcObj));
            if any(cell2mat(strfind(tName,"divalent")))
                obj.Type = "Divalent";
            elseif any(cell2mat(strfind(tName,"alkali")))
                obj.Type = "Alkali";
            end

            % Set data path. Distinguish this with the dataFolder property
            % that pointing to the arc atomic data.
            obj.DataPath = fullfile(getenv('USERPROFILE'),"Documents","AtomData");
            createFolder(obj.DataPath);
        end

        function s = saveobj(obj)
            % Only save the Type and the Name of the object to files.
            s.Type = obj.Type;
            s.Name = obj.Name;
        end
    end

    methods (Static)
        function obj = loadobj(s) 
            % When the objected is loaded, reconstruct it using the name of
            % the atom.
            if isstruct(s)
                switch s.Type
                    case "Alkali"
                        obj = Alkali(s.Name);
                    case "Divalent"
                        obj = Divalent(s.Name);
                end
            else
                obj = s;
            end
        end
    end

end

