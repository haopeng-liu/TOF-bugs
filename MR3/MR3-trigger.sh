prefix=/home/fcatch/MR3

mkdir -p $prefix/temp/dfs/data
mkdir -p $prefix/temp/dfs/name

config="--config $prefix/hadoop-config"
hadoop=$prefix/hadoop-2.1.0-beta-src/hadoop-dist/target/hadoop-2.1.0-beta/

$hadoop/bin/hdfs $config namenode -format 2>/dev/null
$hadoop/sbin/start-dfs.sh $config 2>/dev/null

$hadoop/bin/hdfs $config dfs -mkdir /input 2>/dev/null
$hadoop/bin/hdfs $config dfs -put $hadoop/etc/hadoop/httpfs-site.xml /input 2>/dev/null
$hadoop/bin/hdfs $config dfs -put $hadoop/etc/hadoop/yarn.xml /input 2>/dev/null
$hadoop/bin/hdfs $config dfs -put $hadoop/etc/hadoop/core-site.xml /input 2>/dev/null

$hadoop/sbin/start-yarn.sh $config 2>/dev/null

if [ ! -f "/tmp/MR3-crash.flag" ]; then
  touch /tmp/MR3-crash.flag
fi

echo "Running wordcount job"
$hadoop/bin/hadoop $config jar $hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.1.0-beta.jar wordcount /input /output 2> /dev/null

echo "Job status:"
sleep 1
$hadoop/bin/hadoop $config job -list all 2>/dev/null| grep -iE "^\s+job" | cut -d$'\t' -f1,2,3,4

$hadoop/sbin/stop-yarn.sh $config 2>/dev/null 1>&2
$hadoop/sbin/stop-dfs.sh $config 2>/dev/null 1>&2

rm -rf $prefix/temp
