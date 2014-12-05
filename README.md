was-install
===========
1:脚本运行可以创建WebSphere集群，server，数据源                                                                          
1.1:create_dis_cluster创建纯分布式集群，根据节点在每个节点创建一个server,并且设置每个server的jvm堆大小(512,1536).jvm参数.线程池                                                                                                                                                    1.2:create_datasource在每个节点创建数据源,目前仅支持DB2/oracle,目前只能创建jdbc/v6td和jdbc/v6hd数据源,并且设置数据源连接池大小(30,300),需要将数据库驱动程序放置到/opt/IBM/WebSphere/dbdriver
1.3:create_server根据提供的集群、节点信息创建server，同时设置server的jvm堆大小（512,1536）、jvm参数、线程池
