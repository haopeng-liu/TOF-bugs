prefix=/home/fcatch/ZK

rm -rf $prefix/exp/
mkdir -p $prefix/exp
zk1=$prefix/exp/zookeeper-3.5.0-1
zk2=$prefix/exp/zookeeper-3.5.0-2
zk3=$prefix/exp/zookeeper-3.5.0-3

tar -xzf $prefix/trunk/build/zookeeper-3.5.0.tar.gz  -C $prefix/exp/
mv $prefix/exp/zookeeper-3.5.0 $zk1
cp -r $zk1 $zk2
cp -r $zk1 $zk3

mkdir -p $zk1/data/version-2
mkdir -p $zk2/data/version-2
mkdir -p $zk3/data/version-2
#cp $prefix/data-prepare/snapshot.200000000 $zk1/data/version-2
#cp $prefix/data-prepare/snapshot.200000000 $zk2/data/version-2
#cp $prefix/data-prepare/snapshot.200000000 $zk3/data/version-2
cp $prefix/data-prepare/zoo1.cfg $zk1/conf/zoo.cfg
cp $prefix/data-prepare/zoo2.cfg $zk2/conf/zoo.cfg
cp $prefix/data-prepare/zoo3.cfg $zk3/conf/zoo.cfg

echo "1" > $zk1/data/myid
echo "2" > $zk2/data/myid
echo "3" > $zk3/data/myid

if [ ! -f "/tmp/ZK-crash.flag" ]; then
  touch /tmp/ZK-crash.flag
fi

cd $zk1
bin/zkServer.sh start
cd ..

cd $zk2
bin/zkServer.sh start
cd ..

cd $zk3
bin/zkServer.sh start
cd ..

echo -n "."
sleep 1;
ZKPidNum=`jps | grep QuorumPeerMain | awk -F " " '{print $1}' | wc -l`
if [ "$ZKPidNum" != "3" ];then
 for i in 1 2 3
    do
        pidInFile=`cat $prefix/exp/zookeeper-3.5.0-$i/data/zookeeper_server.pid`
        isRunning=0
        #echo $i: $pidInFile
        for pid in `jps | grep QuorumPeerMain | awk -F " " '{print $1}'`
        do
            #echo "cur jps: " $pid
            if [ "$pid" = "$pidInFile" ];then
                isRunning=1
            fi
        done
        if [ "$isRunning" = "0" ];then
           echo $i crashed, restart it
           rm $prefix/exp/zookeeper-3.5.0-$i/data/zookeeper_server.pid
           mv $prefix/exp/zookeeper-3.5.0-$i/zookeeper.out $prefix/exp/zookeeper-3.5.0-$i/zookeeper.out_crashed
           cd $prefix/exp/zookeeper-3.5.0-$i
           rm ./data/version-2/snapshot.0
           cp $prefix/data-prepare/snapshot.200000000 ./data/version-2
           ./bin/zkServer.sh start
           waitTime=`expr $waitTime + 20`
           break
        fi
    done
fi
