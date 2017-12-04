prefix=/home/fcatch/HB1

rm -rf $prefix/exp/
rm -rf /tmp/hbase-fcatch
rm -rf /tmp/data-*
rm -rf /tmp/hsperfdata_fcatch
mkdir -p $prefix/exp

tar -xzf $prefix/hbase/hbase-assembly/target/hbase-0.96.1-bin.tar.gz -C $prefix/exp/
hbase_prefix=$prefix/exp/hbase-0.96.1

cp -r $prefix/hbase-conf/* $hbase_prefix/conf

rm -rf $hbase_prefix/logs/*

$hbase_prefix/bin/start-hbase.sh

while [ true ]
do
  sleep 1
  startComplete=`grep "master.HMaster: Master has completed initialization" $hbase_prefix/logs/*`
  echo "Log: "$startComplete
  if [ "$startComplete" != "" ];then
    echo "Check: Master(hbase) has completed initialization."
    break
  fi

done

