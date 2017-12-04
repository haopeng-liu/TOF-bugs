prefix=/home/fcatch/MR1

mkdir -p $prefix/temp/dfs/data
mkdir -p $prefix/temp/dfs/name
rm -rf /tmp/hadoop-yarn

config="--config $prefix/hadoop-config"
hadoop=$prefix/hadoop-common/hadoop-dist/target/hadoop-0.23.1/

export HADOOP_HOME=$hadoop
export YARN_HOME=$hadoop
export YARN_LOG_DIR=$hadoop/logs
if [ -f "$hadoop/share/hadoop/hdfs/lib/slf4j-log4j12-1.6.1.jar" ]; then
  rm $hadoop/share/hadoop/hdfs/lib/slf4j-log4j12-1.6.1.jar
fi
if [ -f "$hadoop/share/hadoop/mapreduce/lib/slf4j-log4j12-1.6.1.jar" ]; then
  rm $hadoop/share/hadoop/mapreduce/lib/slf4j-log4j12-1.6.1.jar
fi
cp ./yarn-daemon.sh $hadoop/sbin

$hadoop/bin/hdfs $config namenode -format
$hadoop/sbin/start-dfs.sh $config

$hadoop/bin/hdfs $config dfs -mkdir /input
$hadoop/bin/hdfs $config dfs -put $hadoop/etc/hadoop/httpfs-site.xml /input
$hadoop/bin/hdfs $config dfs -put $hadoop/etc/hadoop/yarn-site.xml /input
$hadoop/bin/hdfs $config dfs -put $hadoop/etc/hadoop/core-site.xml /input

$hadoop/sbin/start-yarn.sh $config

if [ ! -f "/tmp/MR1-crash.flag" ]; then
  touch /tmp/MR1-crash.flag
fi

echo "Running wordcount job"
$hadoop/bin/hadoop $config jar $hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-0.23.1.jar wordcount /input /output

echo "Job status:"
sleep 1
$hadoop/bin/hadoop $config job -list all 2>/dev/null| grep -iE "^\s+job" | cut -d$'\t' -f1,2,3,4
echo "$hadoop/bin/hadoop $config job -list all"

