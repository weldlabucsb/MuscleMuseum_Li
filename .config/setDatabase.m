function setDatabase
%% Connect to the default database
serverName = "localhost";
databaseName = "postgres";
port = 5432;
username = "postgres";
password = "Ultr@c0ld";
conn = connectPsqlDatabase(databaseName,serverName,port,username,password);

%% Create databases
newDatabaseList = ["lithium_experiment","simulation"];

disp([newline,'Attempt to create new databases...'])
for ii = 1: numel(newDatabaseList)
    try
        execute(conn,append("CREATE DATABASE ",newDatabaseList(ii)))
        disp(append('Database [',newDatabaseList(ii),'] created'))
    catch ME
        warning(ME.message)
    end
end

%% Create users
newUserList = ["writer","reader"];
disp([newline,'Attempt to create new users...'])
for ii = 1:numel(newUserList)
    try
        execute(conn,append("CREATE ROLE ",newUserList(ii),' WITH LOGIN PASSWORD ''',newUserList(ii),''''))
        disp(append('User ',newUserList(ii),' created'))
    catch ME
        warning(ME.message)
    end
end
close(conn)

%% Create tables for experiment
serverName = "localhost";
databaseName = newDatabaseList(1);
port = 5432;
username = "postgres";
password = "Ultr@c0ld";
conn = connectPsqlDatabase(databaseName,serverName,port,username,password);
expTableList = "main";

disp(append(newline,'Attempt to create new tables for database [',databaseName,']'))
for ii = 1:numel(expTableList)
    try
        execute(conn,"CREATE TABLE " + expTableList(ii) + "(" + ...
            """SerialNumber"" serial," + ...
            """DateTime"" timestamp," + ...
            """Name"" varchar," + ...
            """NRun"" integer," + ...
            """NCompletedRun"" integer" + ...
            ");")
        disp(append('Table [',expTableList(ii),'] created'))
    catch ME
        warning(ME.message)
    end
end
close(conn)

%% Create tables for simulation
serverName = "localhost";
databaseName = newDatabaseList(2);
port = 5432;
username = "postgres";
password = "Ultr@c0ld";
conn = connectPsqlDatabase(databaseName,serverName,port,username,password);

simTableList = ["master_equation_simulation",...
    "gross_pitaevskii_equation_simulation",...
    "schrodinger_equation_simulation",...
    "fokker_planck_equation_simulation"];
disp(append(newline,'Attempt to create new tables for database [',databaseName,']'))
for ii = 1:numel(simTableList)
    try
        execute(conn,"CREATE TABLE " + simTableList(ii) + "(" + ...
            """SerialNumber"" serial," + ...
            """DateTime"" timestamp," + ...
            """Name"" varchar," + ...
            """NRun"" integer," + ...
            """NCompletedRun"" integer" + ...
            ");")
        disp(append('Table [',simTableList(ii),'] created'))
    catch ME
        warning(ME.message)
    end
end
close(conn)

%% Grant permissions
for ii = 1:numel(newDatabaseList)

    serverName = "localhost";
    databaseName = newDatabaseList(ii);
    port = 5432;
    username = "postgres";
    password = "Ultr@c0ld";
    conn = connectPsqlDatabase(databaseName,serverName,port,username,password);

    tableList = fetch(conn,"SELECT table_name FROM information_schema.tables  WHERE table_schema='public' AND table_type='BASE TABLE'");
    disp([newline,'Attempt to grant privileges to users...'])
    try
        execute(conn,append("GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA public TO ","writer"))
        execute(conn,append("GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO ","writer"))
        for jj = 1:numel(tableList.table_name)
            execute(conn,append("ALTER TABLE ",tableList.table_name(jj)," OWNER TO ","writer"))
        end
        disp(append('User [writer] granted for database [',newDatabaseList(ii),']'))
    catch ME
        warning(ME.message)
    end

    try
        execute(conn,append("GRANT SELECT ON ALL TABLES IN SCHEMA public TO ","reader"))
        disp(append('User [reader] granted for database [',newDatabaseList(ii),']'))
    catch ME
        warning(ME.message)
    end

    close(conn)
end
end





