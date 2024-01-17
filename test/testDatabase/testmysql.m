vendor = "MySQL";
opts = databaseConnectionOptions("native",vendor);
opts = setoptions(opts, ...
    'DataSourceName',"MySQLDataSource", ...
    'DatabaseName',"CAENS",'Server',"localhost", ...
    'PortNumber',3306);

username = "root";
password = "Ultr@c0ld";
status = testConnection(opts,username,password);
saveAsDataSource(opts)

datasource = "MySQLDataSource";
conn = mysql(datasource,username,password);

LastName = ["Sanchez";"Johnson";"Zhang";"Diaz";"Brown"];
Age = [38;43;38;40;49];
Smoker = [true;false;true;false;true];
Height = [71;69;64;67;64];
Weight = [176;163;131;133;119];
BloodPressure = [124; 109; 125; 117; 122];
arr = [1 2;3 4;5 6;7 8;9 10];

patients = table(LastName,Age,Smoker,Height,Weight,BloodPressure,arr);
 

tablename = "test3"; 
sqlwrite(conn,tablename,patients,'Catalog','caens') 