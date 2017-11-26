prefix=/home/fcatch/CA3

rm -rf $prefix/exp/
mkdir -p $prefix/exp
tar -xzf $prefix/cassandra/build/apache-cassandra-1.1.11-SNAPSHOT-bin.tar.gz -C $prefix/exp/
mv $prefix/exp/apache-cassandra-1.1.11-SNAPSHOT $prefix/exp/cassandra
rm $prefix/exp/cassandra/resources/*
cp -r $prefix/exp/cassandra $prefix/exp/cassandra-2

cp data-prepare/conf-1/* $prefix/exp/cassandra/conf/
cp data-prepare/conf-2/* $prefix/exp/cassandra-2/conf/

cd $prefix/exp/
cassandra/bin/cassandra
cassandra-2/bin/cassandra

while [ true ]
do
  sleep 1
  startComplete=`grep "Bootstrap/Replace/Move completed! Now serving reads" $prefix/exp/cassandra/resources/system.log`
  echo "startComplete: "$startComplete
  if [ "$startComplete" != "" ];then
   echo "Check: Cassandra-1 has completed initialization."
   break;
  fi

  pnum=`jps| grep "Cassandra" | wc -l`
  if [ "$pnum" != "2" ];then
    $prefix/exp/cassandra/bin/cassandra
    $prefix/exp/cassandra-2/bin/cassandra
    echo "restart !"
  fi
done

while [ true ]
do
  sleep 1
  startComplete=`grep "Bootstrap/Replace/Move completed! Now serving reads" $prefix/exp/cassandra-2/resources/system.log`
  echo "startComplete: "$startComplete
  if [ "$startComplete" != "" ];then
   echo "Check: Cassandra-2 has completed initialization."
   break;
  fi

  pnum=`jps| grep "Cassandra" | wc -l`
  if [ "$pnum" != "2" ];then
    $prefix/exp/cassandra/bin/cassandra
    $prefix/exp/cassandra-2/bin/cassandra
    echo "restart !"
  fi
done

$prefix/exp/cassandra/bin/cassandra-cli -h 127.0.0.1 -f $prefix/data-prepare/CA5393-workload.statements
$prefix/exp/cassandra/bin/nodetool -h 127.0.0.1 repair -snapshot 

kill -9 `jps | grep CassandraDaemon | awk -F " " '{print $1}'`
