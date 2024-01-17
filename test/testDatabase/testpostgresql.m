databaseName = "lithium_exp";
username = "writer";
password = "writer";


% load("Config.mat","BecExpDbConfig")
conn = postgresql(databaseName,username,password);
conn.AutoCommit;

DateTime = datetime("now");
ExpType = "evapD";
DataPath = string(pwd);
Testt = "aweraf";
atestt = [1 2 3.5];
% atestt = double.empty(1,0);
intdata = int32(1);
intarray = int32([2 4 5 6]);
celltest = [1 2 3];
logi = true;

stringArray = ["ac","basdq","cawer","qwer"];
% stringArray = string.empty(1,0);

tdata = table(DateTime,ExpType,DataPath,Testt,atestt,intdata,intarray,celltest,logi,stringArray);

tablename = "main"; 
pgWrite(conn,tablename,tdata);

% rf = rowfilter({'SerialNumber','ExpType'}); 
% rf = rf.SerialNumber == 2 & rf.ExpType == "evapD";
% intdata = 2;
% uparray = [1 2 3];
% tdata = table(intdata,ExpType,uparray);
% tdata = quoteTableColumn(tdata);
% pgUpdate(conn,tablename,tdata,rf);


rf = rowfilter({'SerialNumber','ExpType'}); 
rf = (rf.SerialNumber == 70 | rf.SerialNumber == 85);
data = pgRead(conn,"main",rowfilter = rf);
close(conn)


