function conn = connectPsqlDatabase(databaseName,serverName,port,username,password)
%connectPsqlDatabase Summary of this function goes here
%   Detailed explanation goes here


opts = databaseConnectionOptions("native","PostgreSQL");
opts = setoptions(opts, ...
    'DataSourceName',databaseName, ...
    'DatabaseName',databaseName,'Server',serverName, ...
    'PortNumber',port);
saveAsDataSource(opts)

[status,message] = testConnection(opts,username,password);
if status == true
    disp(append(newline,'Database connection succeeded.',newline,...
        'Server: ',serverName,newline,...
        'Database: ',databaseName,newline,...
        'Port: ',num2str(port)))
    conn = postgresql(databaseName,username,password);
    conn.AutoCommit;
else
    error(append('Database connection failed.',newline,...
        'Error message from PostgreSQL:',newline,message))
end
end

