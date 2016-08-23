bin/hdfs namenode -format
bin/hdfs namenode
bin/hdfs secondarynamenode
bin/hdfs datanode -Ddfs.datanode.address=0.0.0.0:50010 -Ddfs.datanode.http.address=0.0.0.0:50080 -Ddfs.datanode.ipc.address=0.0.0.0:50020 -Ddfs.datanode.data.dir=file:/hadoop/hdfs/dn0
bin/hdfs datanode -Ddfs.datanode.address=0.0.0.0:50011 -Ddfs.datanode.http.address=0.0.0.0:50081 -Ddfs.datanode.ipc.address=0.0.0.0:50021 -Ddfs.datanode.data.dir=file:/hadoop/hdfs/dn1
bin/hdfs datanode -Ddfs.datanode.address=0.0.0.0:50012 -Ddfs.datanode.http.address=0.0.0.0:50082 -Ddfs.datanode.ipc.address=0.0.0.0:50022 -Ddfs.datanode.data.dir=file:/hadoop/hdfs/dn2

