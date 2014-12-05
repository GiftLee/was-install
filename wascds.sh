#!/bin/bash

####�����������ֲ�ʽ��Ⱥ
function create_dis_cluster() {
echo "������WEBSPHERE��װ·��"
read  WAS_ROOT
echo  "
------ ��������Ҫ�����ļ�Ⱥ���ƣ�        ------
------ ����ͬʱ���������ո�ֿ���      ------
------ ����V6�滮�����鼯Ⱥ�������£�    ------
------ pub_cluster sd_cluster rm_cluster ------
------ lms_cluster base_cluster��         ------"
read  -a clusterNames
echo "
------ ������WebSphere��Ⱥ�ڵ����ƣ�      ------
------ ���磺v6app01Node01,v6app02Node01  ------
------ ��������չ������̨�ڽڵ���Ϣ��   ------"    
read  -a nodeNames
echo "
------ ������WebSphere�������̨�û�����      ------"   
read     username
echo "
------ ������WebSphere�������̨���룺      ------"   
read    password

cd $WAS_ROOT/bin
echo "
#
# Header
#
ResourceType=VirtualHost
ImplementingResourceType=VirtualHost
ResourceId=Cell=!{cellName}:VirtualHost=default_host
AttributeInfo=aliases(port,hostname)
#Properties
9080=*
9081=*
9082=*
9083=*
9084=*
9085=*
9086=*
9087=*
9088=*
9089=*
9090=*
9091=*
9092=*
9093=*
9094=*
9095=*
9096=*
9097=*
9098=*
9099=*
9100=*
9101=*
9102=*
9103=*
9104=*
9105=*
9106=*
9107=*
9108=*
9109=*
9110=*
9111=*
9112=*
9113=*
9114=*
9115=*
9116=*
9117=*
9118=*
9119=*
9120=*
9121=*
9122=*
9123=*
9124=*
9125=*
9126=*
9127=*
9128=*
9129=*" >VirtualHost.props
cat /dev/null >$WAS_ROOT/bin/csj.py

n=`echo ${#nodeNames[@]}`
echo "server�����Զ�����"
for cluster in `echo ${clusterNames[*]}`
	do
  	nodeName=`echo ${nodeNames[0]}`
    createClusterWithoutMember="AdminClusterManagement.createClusterWithoutMember(\"$cluster\")"
    echo $createClusterWithoutMember >>$WAS_ROOT/bin/csj.py
	appname=`echo  ${cluster%%_*}`	
	firstSverName=$appname"_server1"
	createFirstClusterMemberWithTemplate="AdminClusterManagement.createFirstClusterMemberWithTemplate(\"$cluster\", \"$nodeName\", \"$firstSverName\", \"default\")"
    echo $createFirstClusterMemberWithTemplate>>$WAS_ROOT/bin/csj.py
	setFirstJVMProperties="AdminTask.setJVMProperties('[-serverName $firstSverName -nodeName $nodeName -verboseModeGarbageCollection true -initialHeapSize 512 -maximumHeapSize 1536 -genericJvmArguments \"-Djava.net.preferIPv4Stack=true\"]')"
	echo $setFirstJVMProperties>>$WAS_ROOT/bin/csj.py
	configureFirstWebcontainerThreadPool="AdminServerManagement.configureThreadPool(\"$nodeName\", \"$firstSverName\", \"ThreadPoolManager\", \"WebContainer\", 300,30,60000)"
	echo $configureFirstWebcontainerThreadPool>>$WAS_ROOT/bin/csj.py
	configureFirstDefaultThreadPool="AdminServerManagement.configureThreadPool(\"$nodeName\", \"$firstSverName\", \"ThreadPoolManager\", \"Default\",300,30,60000)"
	echo $configureFirstDefaultThreadPool   >>$WAS_ROOT/bin/csj.py
	echo "AdminConfig.save()" >>$WAS_ROOT/bin/csj.py
		for ((i=1;i<$n;i++))
    	do 
      	echo  ${cluster%%_*}
      	echo $i
      	appname=`echo  ${cluster%%_*}`	
      	serverName=$appname"_server"$((i+1))
      	echo $serverName
      	nodeName=`echo ${nodeNames[i]}`
      	echo $nodeName
      	createClusterMember="AdminClusterManagement.createClusterMember(\"$cluster\", \"$nodeName\", \"$serverName\")"
      	echo $createClusterMember >>$WAS_ROOT/bin/csj.py
	  	if [ $appname = base ]
	     then 
	  	setJVMProperties="AdminTask.setJVMProperties('[-serverName $serverName -nodeName $nodeName -verboseModeGarbageCollection true -initialHeapSize 512 -maximumHeapSize 1536 -genericJvmArguments \"-Djava.net.preferIPv4Stack=true -Dschedule.start=false\"]')" 	
	  	elif [ $appname = ecweb ]
	     then 
	  	setJVMProperties="AdminTask.setJVMProperties('[-serverName $serverName -nodeName $nodeName -verboseModeGarbageCollection true -initialHeapSize 512 -maximumHeapSize 1536 -genericJvmArguments \"-Djava.net.preferIPv4Stack=true  -Ddefault.client.encoding=GBK -Dfile.encoding=GBK\"]')"	  	
	  	elif [ $appname = ecservice ]
	     then 
	  	setJVMProperties="AdminTask.setJVMProperties('[-serverName $serverName -nodeName $nodeName -verboseModeGarbageCollection true -initialHeapSize 512 -maximumHeapSize 1536 -genericJvmArguments \"-Djava.net.preferIPv4Stack=true  -Ddefault.client.encoding=GBK -Dfile.encoding=GBK\"]')"	  	 	
	  	else 
	    setJVMProperties="AdminTask.setJVMProperties('[-serverName $serverName -nodeName $nodeName -verboseModeGarbageCollection true -initialHeapSize 512 -maximumHeapSize 1536 -genericJvmArguments \"-Djava.net.preferIPv4Stack=true\"]')"		
		  fi 
      	echo $setJVMProperties >>$WAS_ROOT/bin/csj.py
      	configureWebcontainerThreadPool="AdminServerManagement.configureThreadPool(\"$nodeName\", \"$serverName\", \"ThreadPoolManager\", \"WebContainer\", 300,30,60000)"
      	echo $configureWebcontainerThreadPool >>$WAS_ROOT/bin/csj.py
      	configureDefaultThreadPool="AdminServerManagement.configureThreadPool(\"$nodeName\", \"$serverName\", \"ThreadPoolManager\", \"Default\", 300,30,60000)"
      	echo $configureDefaultThreadPool >>$WAS_ROOT/bin/csj.py
		    echo "AdminConfig.save()" >>$WAS_ROOT/bin/csj.py
    	done
	done
cd $WAS_ROOT/bin
./wsadmin.sh  -lang jython  -conntype  SOAP  -user $username  -password $password -f $WAS_ROOT/bin/csj.py

./wsadmin.sh  -lang jython  -conntype  SOAP  -user $username  -password $password  <<EOF
AdminTask.applyConfigProperties('-propertiesFileName VirtualHost.props -reportFileName report.txt')
AdminConfig.save()
EOF
}



###��������Դ
function create_datasource() {
echo "������WEBSPHERE��װ·��"
read  WAS_ROOT
echo "
------ ������WebSphere��Ⱥ�ڵ����ƣ�      ------
------ ���磺v6app01Node01,v6app02Node01  ------
------ ��������չ������̨�ڽڵ���Ϣ��   ------"    
read  -a nodeNames
echo "
------ ������WebSphere�������̨�û�����  ------"   
read     username
echo "
------ ������WebSphere�������̨���룺      ------"   
read    password

echo "
------ ���������ݿ�����db2����oracle��Сд�� ------"  
read   dbtype

echo "
------ ������TD���ݿ����ƣ� ------"  
read    v6td

echo "
------ ������TD���ݿ�IP��ַ�� ------"  
read     tdip

echo "
------ ������TD���ݿ�˿ڣ� ------"  
read  tdport

echo "
------ ������TD���ݿ��û����� ------"  
read   tduser

echo "
------ ������TD���ݿ����룺 ------"  
read  tdpassword


echo "
------ ������HD���ݿ����ƣ� ------
------ ���û��HD������TD��Ϣ ------"  
read   v6hd

echo "
------ ������HD���ݿ�IP��ַ�� ------
------ ���û��HD������TD��Ϣ ------"  
read  hdip

echo "
------ ������HD���ݿ�˿ڣ� ------
------ ���û��HD������TD��Ϣ ------"  
read    hdport

echo "
------ ������HD���ݿ��û����� ------
------ ���û��HD������TD��Ϣ ------" 
read   hduser

echo "
------ ������HD���ݿ����룺 ------
------ ���û��HD������TD��Ϣ ------" 
read   hdpassword



echo "
------ ������xsm���ݿ����ƣ� ------
------ ���û��xsm������TD��Ϣ ------"  
read   xsmec

echo "
------ ������HD���ݿ�IP��ַ�� ------
------ ���û��HD������TD��Ϣ ------"  
read  xsmip

echo "
------ ������HD���ݿ�˿ڣ� ------
------ ���û��HD������TD��Ϣ ------"  
read    xsmport
echo "
------ ������xsm���ݿ��û����� ------
------ ���û��xsm������TD��Ϣ ------" 
read   xsmuser

echo "
------ ������xsm���ݿ����룺 ------
------ ���û��xsm������TD��Ϣ ------" 
read   xsmpassword



cat /dev/null >$WAS_ROOT/bin/cjdbc.py
cd $WAS_ROOT/bin
mkdir /opt/IBM/WebSphere/dbdriver

#####��������Դ#####
cd $WAS_ROOT/bin
for nodeName in `echo ${nodeNames[*]}`
	do 
	   if [ $dbtype = db2 ]
	   then 
      	createDB2JDBCProviderAtScope="AdminJDBC.createJDBCProviderUsingTemplateAtScope(\"/Node:$nodeName/\", \"DB2 Universal JDBC Driver Provider Only(templates/system|jdbc-resource-provider-only-templates.xml#JDBCProvider_DB2_UNI_1)\", \"DB2 Universal JDBC Driver Provider\", \"com.ibm.db2.jcc.DB2ConnectionPoolDataSource\",\"classpath=/opt/IBM/WebSphere/dbdriver/db2jcc.jar;/opt/IBM/WebSphere/dbdriver/db2jcc_license_cu.jar\")"
      	echo $createDB2JDBCProviderAtScope>>$WAS_ROOT/bin/cjdbc.py
      	createDB2TDDataSourceAtScope="AdminJDBC.createDataSourceUsingTemplateAtScope(\"/Node:$nodeName/\", \"DB2 Universal JDBC Driver Provider\", \"DB2 Universal JDBC Driver DataSource(templates/system|jdbc-resource-provider-templates.xml#DataSource_DB2_UNI_1)\", \"v6td\",[['authDataAlias', 'tduser'],[\"connectionPool\",[[\"maxConnections\",\"300\"],[\"minConnections\",\"30\"]]],['jndiName', 'jdbc/v6td'],['propertySet', [['resourceProperties', [[['name', 'databaseName'],['type', 'String'], ['value', '$v6td']], [['name', 'driverType'], ['type', 'integer'], ['value', 4]], [['name', 'serverName'], ['type', 'String'], ['value', '$tdip']], [['name', 'portNumber'], ['type', 'integer'], ['value', $tdport]]]]]]])"
      	echo $createDB2TDDataSourceAtScope>>$WAS_ROOT/bin/cjdbc.py
		    createDB2lsDataSourceAtScope="AdminJDBC.createDataSourceUsingTemplateAtScope(\"/Node:$nodeName/\", \"DB2 Universal JDBC Driver Provider\", \"DB2 Universal JDBC Driver DataSource(templates/system|jdbc-resource-provider-templates.xml#DataSource_DB2_UNI_1)\", \"loushang\",[['authDataAlias', 'tduser'],[\"connectionPool\",[[\"maxConnections\",\"300\"],[\"minConnections\",\"30\"]]],['jndiName', 'jdbc/loushang'],['propertySet', [['resourceProperties', [[['name', 'databaseName'],['type', 'String'], ['value', '$v6td']], [['name', 'driverType'], ['type', 'integer'], ['value', 4]], [['name', 'serverName'], ['type', 'String'], ['value', '$tdip']], [['name', 'portNumber'], ['type', 'integer'], ['value', $tdport]]]]]]])"
		    echo $createDB2lsDataSourceAtScope>>$WAS_ROOT/bin/cjdbc.py
      	createDB2HDDataSourceAtScope="AdminJDBC.createDataSourceUsingTemplateAtScope(\"/Node:$nodeName/\", \"DB2 Universal JDBC Driver Provider\", \"DB2 Universal JDBC Driver DataSource(templates/system|jdbc-resource-provider-templates.xml#DataSource_DB2_UNI_1)\", \"v6hd\",[['authDataAlias', 'hduser'],[\"connectionPool\",[[\"maxConnections\",\"300\"],[\"minConnections\",\"30\"]]],['jndiName', 'jdbc/v6hd'],['propertySet', [['resourceProperties', [[['name', 'databaseName'],['type', 'String'], ['value', '$v6hd']], [['name', 'driverType'], ['type', 'integer'], ['value', 4]], [['name', 'serverName'], ['type', 'String'], ['value', '$hdip']], [['name', 'portNumber'], ['type', 'integer'], ['value', $hdport]]]]]]])"
      	echo $createDB2HDDataSourceAtScope>>$WAS_ROOT/bin/cjdbc.py
      	createDB2xsmDataSourceAtScope="AdminJDBC.createDataSourceUsingTemplateAtScope(\"/Node:$nodeName/\", \"DB2 Universal JDBC Driver Provider\", \"DB2 Universal JDBC Driver DataSource(templates/system|jdbc-resource-provider-templates.xml#DataSource_DB2_UNI_1)\", \"xsm\",[['authDataAlias', 'xsmuser'],[\"connectionPool\",[[\"maxConnections\",\"300\"],[\"minConnections\",\"30\"]]],['jndiName', 'jdbc/xsmec'],['propertySet', [['resourceProperties', [[['name', 'databaseName'],['type', 'String'], ['value', '$xsmec']], [['name', 'driverType'], ['type', 'integer'], ['value', 4]], [['name', 'serverName'], ['type', 'String'], ['value', '$xsmip']], [['name', 'portNumber'], ['type', 'integer'], ['value', $xsmport]]]]]]])"
      	echo $createDB2xsmDataSourceAtScope>>$WAS_ROOT/bin/cjdbc.py
      	createDB2ecoDataSourceAtScope="AdminJDBC.createDataSourceUsingTemplateAtScope(\"/Node:$nodeName/\", \"DB2 Universal JDBC Driver Provider\", \"DB2 Universal JDBC Driver DataSource(templates/system|jdbc-resource-provider-templates.xml#DataSource_DB2_UNI_1)\", \"ecotd\",[['authDataAlias', 'xsmuser'],[\"connectionPool\",[[\"maxConnections\",\"300\"],[\"minConnections\",\"30\"]]],['jndiName', 'jdbc/ecotd'],['propertySet', [['resourceProperties', [[['name', 'databaseName'],['type', 'String'], ['value', '$xsmec']], [['name', 'driverType'], ['type', 'integer'], ['value', 4]], [['name', 'serverName'], ['type', 'String'], ['value', '$xsmip']], [['name', 'portNumber'], ['type', 'integer'], ['value', $xsmport]]]]]]])"
      	echo $createDB2ecoDataSourceAtScope>>$WAS_ROOT/bin/cjdbc.py
        echo "AdminConfig.save()">>$WAS_ROOT/bin/cjdbc.py
      fi
   if [ $dbtype = oracle ]
	  then 
	    createOracleJDBCProviderAtScope="AdminJDBC.createJDBCProviderUsingTemplateAtScope(\"/Node:$nodeName/\", \"Oracle JDBC Driver Provider Only(templates/system|jdbc-resource-provider-only-templates.xml#JDBCProvider_Oracle_5)\",\"Oracle JDBC Driver\", \"oracle.jdbc.pool.OracleConnectionPoolDataSource\",\"classpath=/opt/IBM/WebSphere/dbdriver/ojdbc6.jar\")"
      	echo $createOracleJDBCProviderAtScope>>$WAS_ROOT/bin/cjdbc.py
      	createOracleTDDataSourceAtScope="AdminJDBC.createDataSourceUsingTemplateAtScope(\"/Node:$nodeName/\", \"Oracle JDBC Driver\", \"Oracle JDBC Driver DataSource(templates/system|jdbc-resource-provider-templates.xml#DataSource_ora_5)\", \"v6td\",[['authDataAlias', 'v6user'],[\"connectionPool\",[[\"maxConnections\",\"300\"],[\"minConnections\",\"30\"]]],['jndiName', 'jdbc/v6td'],['propertySet', [['resourceProperties',[[['name', 'URL '],['type', 'String'], ['value', 'jdbc:oracle:thin:@$tdip:$tdport:$v6td']]]]]]])"
      	echo $createOracleTDDataSourceAtScope>>$WAS_ROOT/bin/cjdbc.py
      	createCreateHDDataSourceAtScope="AdminJDBC.createDataSourceUsingTemplateAtScope(\"/Node:$nodeName/\", \"Oracle JDBC Driver\", \"Oracle JDBC Driver DataSource(templates/system|jdbc-resource-provider-templates.xml#DataSource_ora_5)\", \"v6hd\",[['authDataAlias', 'v6user'],[\"connectionPool\",[[\"maxConnections\",\"300\"],[\"minConnections\",\"30\"]]],['jndiName', 'jdbc/v6hd'],['propertySet', [['resourceProperties',[[['name', 'URL '],['type', 'String'], ['value', 'jdbc:oracle:thin:@$hdip:$hdport:$v6hd']]]]]]])"
      	echo $createCreateHDDataSourceAtScope>>$WAS_ROOT/bin/cjdbc.py      	
      	createCreateloushangDataSourceAtScope="AdminJDBC.createDataSourceUsingTemplateAtScope(\"/Node:$nodeName/\", \"Oracle JDBC Driver\", \"Oracle JDBC Driver DataSource(templates/system|jdbc-resource-provider-templates.xml#DataSource_ora_5)\", \"loushang\",[['authDataAlias', 'v6user'],[\"connectionPool\",[[\"maxConnections\",\"300\"],[\"minConnections\",\"30\"]]],['jndiName', 'jdbc/loushang'],['propertySet', [['resourceProperties',[[['name', 'URL '],['type', 'String'], ['value', 'jdbc:oracle:thin:@$hdip:$hdport:$v6hd']]]]]]])"      	
      	echo $createCreateloushangDataSourceAtScope>>$WAS_ROOT/bin/cjdbc.py
      	createCreatexsmecDataSourceAtScope="AdminJDBC.createDataSourceUsingTemplateAtScope(\"/Node:$nodeName/\", \"Oracle JDBC Driver\", \"Oracle JDBC Driver DataSource(templates/system|jdbc-resource-provider-templates.xml#DataSource_ora_5)\", \"xsmec\",[['authDataAlias', 'xsmuser'],[\"connectionPool\",[[\"maxConnections\",\"300\"],[\"minConnections\",\"30\"]]],['jndiName', 'jdbc/xsmec'],['propertySet', [['resourceProperties',[[['name', 'URL '],['type', 'String'], ['value', 'jdbc:oracle:thin:@$xsmip:$xsmport:$xsmec']]]]]]])"
      	echo $createCreatexsmecDataSourceAtScope>>$WAS_ROOT/bin/cjdbc.py      	
      	createCreateecotdDataSourceAtScope="AdminJDBC.createDataSourceUsingTemplateAtScope(\"/Node:$nodeName/\", \"Oracle JDBC Driver\", \"Oracle JDBC Driver DataSource(templates/system|jdbc-resource-provider-templates.xml#DataSource_ora_5)\", \"ecotd\",[['authDataAlias', 'xsmuser'],[\"connectionPool\",[[\"maxConnections\",\"300\"],[\"minConnections\",\"30\"]]],['jndiName', 'jdbc/ecotd'],['propertySet', [['resourceProperties',[[['name', 'URL '],['type', 'String'], ['value', 'jdbc:oracle:thin:@$xsmip:$xsmport:$xsmec']]]]]]])"
      	echo $createCreateecotdDataSourceAtScope>>$WAS_ROOT/bin/cjdbc.py      	
		echo "AdminConfig.save()">>$WAS_ROOT/bin/cjdbc.py
	   fi
	done
cd $WAS_ROOT/bin
./wsadmin.sh  -lang jython  -conntype  SOAP  -user $username  -password $password -f $WAS_ROOT/bin/cjdbc.py

./wsadmin.sh  -lang jython  -conntype  SOAP  -user $username  -password $password  <<EOF
alias = ['alias', 'v6user']
userid = ['userId', '$tduser']
password = ['password', '$tdpassword']
jaasAttrs = [alias, userid, password]
cellname=AdminControl.getCell()
idname="/Cell:"+cellname+"/Security:/"
security = AdminConfig.getid(idname)
AdminConfig.create('JAASAuthData', security, jaasAttrs)
AdminConfig.save()
alias = ['alias', 'hduser']
userid = ['userId', '$hduser']
password = ['password', '$hdpassword']
jaasAttrs = [alias, userid, password]
AdminConfig.create('JAASAuthData', security, jaasAttrs)
AdminConfig.save()
alias = ['alias', 'xsmuser']
userid = ['userId', '$xsmuser']
password = ['password', '$xsmpassword']
jaasAttrs = [alias, userid, password]
AdminConfig.create('JAASAuthData', security, jaasAttrs)
AdminConfig.save()

EOF

}






####����server
function create_server() {

echo "������WEBSPHERE��װ·��"
read  WAS_ROOT
echo  "
------ ��������Ҫ������server�ļ�Ⱥ���ƣ�        ------"
read  -a clusterNames
echo "
------ ������WebSphere��Ⱥ�ڵ����ƣ�      ------
------ ���磺v6app01Node01,v6app02Node01  ------
------ ��������չ������̨�ڽڵ���Ϣ��   ------"    
read  -a nodeNames
echo "
------ ������Ҫ������server���ƣ�      ------"    
read  -a serverName
echo "
------ ������WebSphere�������̨�û�����------"   
read     username
echo "
------ ������WebSphere�������̨���룺      ------"   
read    password

cd $WAS_ROOT/bin
createClusterMember="AdminClusterManagement.createClusterMember(\"$cluster\", \"$nodeName\", \"$serverName\")"
echo $createClusterMember >>$WAS_ROOT/bin/csrv.py
setJVMProperties="AdminTask.setJVMProperties('[-serverName $serverName -nodeName $nodeName -verboseModeGarbageCollection true -initialHeapSize 512 -maximumHeapSize 1536 -genericJvmArguments \"-Djava.net.preferIPv4Stack=true\"]')"	
echo $setJVMProperties >>$WAS_ROOT/bin/csrv.py	
configureWebcontainerThreadPool="AdminServerManagement.configureThreadPool(\"$nodeName\", \"$serverName\", \"ThreadPoolManager\", \"WebContainer\", 300,30,60000)"
echo $configureWebcontainerThreadPool >>$WAS_ROOT/bin/csrv.py	
configureDefaultThreadPool="AdminServerManagement.configureThreadPool(\"$nodeName\", \"$serverName\", \"ThreadPoolManager\", \"Default\", 300,30,60000)"
echo $configureDefaultThreadPool >>$WAS_ROOT/bin/csrv.py
cd $WAS_ROOT/bin
./wsadmin.sh  -lang jython  -conntype  SOAP  -user $username  -password $password -f $WAS_ROOT/bin/csrv.py
}







echo "�ű����п��Դ���WebSphere��Ⱥ��server������Դ
create_dis_cluster�������ֲ�ʽ��Ⱥ�����ݽڵ���ÿ���ڵ㴴��һ��server,��������ÿ��server��jvm�Ѵ�С(512,1536).jvm����.�̳߳�
create_datasource��ÿ���ڵ㴴������Դ,Ŀǰ��֧��DB2/oracle,Ŀǰֻ�ܴ���jdbc/v6td��jdbc/v6hd����Դ,������������Դ���ӳش�С(30,300),��Ҫ�����ݿ�����������õ�/opt/IBM/WebSphere/dbdriver
create_server�����ṩ�ļ�Ⱥ���ڵ���Ϣ����server��ͬʱ����server��jvm�Ѵ�С��512,1536����jvm�������̳߳�"
select var in "create_dis_cluster" "create_datasource" "create_server" ; do
    break;
done
$var

