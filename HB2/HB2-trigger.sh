hadoop1_dir=hbase-1
hadoop2_dir=hbase-2

echo  
echo "*******************************************************************"
echo " [1]Initialization: clean if last run data exists ... "
echo "*******************************************************************"
echo 

rm -rf hbase-1/logs/*
rm -rf hbase-2/logs/*
rm -rf /tmp/data-1
rm -rf /tmp/data-2

cp -r ./data/data-1 /tmp/
cp -r ./data/data-2 /tmp/

if [ ! -f "/tmp/HB2-crash.flag" ]; then
  touch /tmp/HB2-crash.flag
fi

echo 
echo "*******************************************************************"
echo " [2]Start: run master cluster hbase-1 and slave cluster hbase-2 ... " 
echo "*******************************************************************"
echo 

$hadoop1_dir/bin/start-hbase.sh

$hadoop1_dir/bin/local-regionservers.sh start 1
$hadoop1_dir/bin/local-regionservers.sh start 3

$hadoop2_dir/bin/start-hbase.sh
$hadoop2_dir/bin/local-regionservers.sh start 2

while [ true ]
do
  sleep 1
  cnt=`grep "1511494455926's hlogs to my queue" $hadoop1_dir/logs/*`
  if [ "$cnt" != "" ]; then
   echo "TransferQueue done."
   break;
  else
   echo -n "."
  fi
done

$hadoop1_dir/bin/stop-hbase.sh

#$hadoop2_dir/bin/start-hbase.sh
#$hadoop2_dir/bin/local-regionservers.sh start 2

#echo -n "Starting slave cluster: hbase-2"
#
#  while [ true ]
#   do
#     sleep 1; 
#     startComplete=`grep "org.apache.hadoop.hbase.master.HMaster: Master has completed initialization" $hadoop2_dir/logs/hbase-fcatch-master-ubuntu.log`
#     if [ "$startComplete" != "" ];then
#       echo -e "\nCheck: Slave cluster hbase-2 has completed initialization."
#       break
#     else
#       echo -n "."
#     fi
#   done

   
#echo -n "Starting master cluster: hbase-1"
#  
#  while [ true ]
#   do
#     sleep 1; 
#     startComplete=`grep "org.apache.hadoop.hbase.master.HMaster: Master has completed initialization" $hadoop1_dir/logs/hbase-fcatch-master-ubuntu.log`
#     if [ "$startComplete" != "" ];then
#       echo "Check: Master cluster hbase-1 has completed initialization."
#       break
#     else
#       echo -n "."
#     fi
#      rsCrashed=`grep "Crash Here After Deleting" $hadoop1_dir/logs/hbase-fcatch-1-regionserver-ubuntu.log`
#      if [ "$rsCrashed" != "" ];then
#         echo -e "\n"$rsCrashed
#         echo "Master cluster hbase-1: RegionServer 1 has crashed, restart and recover it"
#         $hadoop1_dir/bin/local-regionservers.sh start 1
#         break
#       fi
#   done


#echo 
#echo "*******************************************************************"
#echo " [3]Data Status: show data in master and slave clusters ..."
#echo "*******************************************************************"
#echo 
#
#./data/showData.sh
#
#echo
#echo "It can be found that the data of table hb5 in master cluster fails to migrate to slave cluster due to crash"
#echo 
#echo "*******************************************************************"
#echo " [4]Stop: shutdown master cluster to imitate cluster outage and then show data again..."
#echo "*******************************************************************"
#echo 
#
#echo "Shutdown master cluster"
#
#$hadoop1_dir/bin/stop-hbase.sh
#
#./data/showData.sh
#
#echo
#echo "It can be found that the data of table hb5 is lost in both master and slave clusters"
#echo
