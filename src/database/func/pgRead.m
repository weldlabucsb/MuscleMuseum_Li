function [data,metadata] = pgRead(conn,tableName,varargin)
%PGREAD read table from a postgresql database
%   

%First check to see if the subclass supports this method
subclass = metaclass(conn);
sqlreadHookMethod = subclass.MethodList(string({subclass.MethodList.Name}) == "sqlreadHook");
definingClass = sqlreadHookMethod.DefiningClass;
if definingClass ~= subclass
    %This class does not support close, so error out
    error(message('database:database"MethodNotSupported','sqlread',class(conn)));
end

nargoutchk(0,2);

%Check for a valid connection
if ~isopen(conn)
    error(message("database:database:invalidConnection"));
end

% Parse inputs
p = inputParser;
p.addRequired("connect",@(x)validateattributes(x,"database.relational.connection",{'scalar'},'sqlread'));
p.addRequired("tablename",@(x)validateattributes(x,["string" "char"],{'scalartext'},'sqlread'));
p.addOptional("opts",[],@(x)validateattributes(x,"database.options.SQLImportOptions",{'scalar'},'sqlread'));
p.addParameter("Catalog","",@(x)validateattributes(x,["string" "char"],{'scalartext'},'sqlread'));
p.addParameter("Schema","",@(x)validateattributes(x,["string" "char"],{'scalartext'},'sqlread'));
p.addParameter("MaxRows",0,@(x)validateattributes(x, "numeric", {'scalar','integer','nonnegative','nonzero'},'sqlread'));
p.addParameter("VariableNamingRule","preserve",@(x)validateattributes(x, ["string" "char"], {'scalartext'},'sqlread'));
p.addParameter("RowFilter",rowfilter(missing),@(x)validateattributes(x,"matlab.io.RowFilter","scalar","sqlread"));

p.parse(conn,tableName,varargin{:});
validateattributes(char(p.Results.tablename),"char",{'nonempty'},"sqlread","tablename")
tableName = string(tableName);

catalog = string(p.Results.Catalog);
schema = string(p.Results.Schema);
maxRows = p.Results.MaxRows;
preservenames = validatestring(p.Results.VariableNamingRule,["modify" "preserve"]);
isvarnamerulespecified = ~any(strcmpi(p.UsingDefaults,'VariableNamingRule'));
rowFilter = p.Results.RowFilter;


optsObject = p.Results.opts;
if ~isempty(p.Results.opts)
    if isvarnamerulespecified
        %Options object is not compatible with the
        %VariableNAmingRule Name-Value pair
        error(message('database:importoptions:ImportOptionsVariableNamingRule'));
    end
    %Copy the object so changes can be made.
    optsObject = copy(p.Results.opts);
end

%Add the scema and catalog to the table name
if schema.strlength ~= 0
    tableName = schema + "." + tableName;
end

if catalog.strlength ~= 0
    tableName = catalog + "." + tableName;
end

%Construct the query
querybuilder = database.internal.utilities.SQLQueryBuilder;
querybuilder = querybuilder.select("*").from(tableName);

underlyingFilter = getProperties(rowFilter).UnderlyingFilter;

if ~isa(underlyingFilter,"matlab.io.internal.filter.UnconstrainedRowFilter") && ...
        ~isa(underlyingFilter,"matlab.io.internal.filter.MissingRowFilter")

    if ~isempty(optsObject)
        %RowFilter name-value pair can't be used with an
        %options object as the options may have its own filter
        %object
        error(message('database:importoptions:RowFilterOptionsIncompatible'));
    end
    
    filter = {rowFilter};
    % nfilter = numel(filter);
    % for ii = 1:nfilter
    vNames = properties(filter{1});
    nNames = numel(vNames);
    for jj = 1:nNames
        filter{1} = replaceVariableNames(filter{1},vNames{jj},['"',vNames{jj},'"']);
    end
    % end
    dispatcher = database.internal.utilities.SQLFilterDispatcher();
    querybuilder = dispatcher.dispatch(filter{1},querybuilder,conn.DatabaseProductName);
    % querybuilder = dispatcher.dispatch(rowFilter,querybuilder,connect.DatabaseProductName);
end

query = strtrim(querybuilder.SQLQuery);

if nargout == 2
    [data,metadata] = pgReadHook(conn,query,optsObject,maxRows,preservenames,isvarnamerulespecified);
else
    data = pgReadHook(conn,query,optsObject,maxRows,preservenames,isvarnamerulespecified);
end

end
