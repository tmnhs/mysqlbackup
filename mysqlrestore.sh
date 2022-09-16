#!/bin/bash
mysql_user="root" 
mysql_password="gjq.0058" 
mysql_host="localhost"
mysql_port="3306"
mysql_charset="utf8" 
restore_db="notes"

backup_location=/tmp/mysql  
welcome_msg="Welcome to use MySQL backup tools!"
#The first argument is the path backup file
sql_file=$1

mysql_ps=`ps -ef |grep mysql |wc -l`
mysql_listen=`netstat -an |grep LISTEN |grep $mysql_port|wc -l`
if [ [$mysql_ps == 0] -o [$mysql_listen == 0] ]; then
        echo "ERROR:MySQL is not running! backup stop!"
        exit
else
        echo $welcome_msg
fi

mysql -h$mysql_host -P$mysql_port -u$mysql_user -p$mysql_password <<end
use mysql;
select host,user from user where user='root' and host='localhost';
exit
end

flag=`echo $?`
if [ $flag != "0" ]; then
        echo "ERROR:Can't connect mysql server! backup stop!"
        exit
else
        echo "MySQL connect ok! Please wait......"
fi

if [ "$sql_file" == "" ]; then
  cd $backup_location
  restore_dir=`ls -t`
  if [ ! -n "$restore_dir" ]; then
    echo "Sorry, there is no backup file. Please confirm whether there is a backup file already."
  fi

  restore_dir=`echo $restore_dir |awk -F ' ' '{print $1}'`

  echo "You are using dir:  "$restore_dir"  for recovery..."
  cd $restore_dir
  gz_dir=`ls -t`

  if [ ! -n "$gz_dir" ]; then
    echo "Sorry, there is no backup file. Please confirm whether there is a backup file already."
  fi

  echo "gunziping..."
  gz_dir=`echo $gz_dir |awk -F ' ' '{print $1}'`
  gunzip $gz_dir
  sql_file=`ls -t`
  sql_file=`echo $sql_file |awk -F ' ' '{print $1}'`
  echo "last:"$sql_file
fi

echo "database $dbname restore start..."
`mysql -h$mysql_host -P$mysql_port -u $mysql_user -p$mysql_password $restore_db < $sql_file`
flag=`echo $?`
if [ $flag == "0" ];then
               echo "database $dbname success restore with file:$sql_file"
else
               echo "database $dbname restore fail!"
fi
