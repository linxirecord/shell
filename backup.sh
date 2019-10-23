#!/bin/bash

# 帮助说明
help()
{
	cat <<- EOF
	Usage: $0 [OPTIONS]
	Options:
		  -u, --user=name    		   User for login if not current user.
		  -p, --passwd	                   Password to use when connecting to server.
		  -h, --host=name                  Connect to host.
		  -t, --type=sql/csv	           The type of baclup files.
		  -d, --directory		   The directory of backup files
		  -P, --port=#        		   Port number to use for connection.default 3306.
		  -S, --socket=name   		   The socket file to use for connection.
		  -D, --database=name 		   Database to use.
		   &  				   background.
	EOF
	exit 0
}

# 参数输入错误的提示
error (){
	cat << EOF
$0: invalid option "$1"
Try '$0 --help' for more information
EOF
	exit 1
}

# 根据传递的参数输出对应的提示
while [ -n "$1" ]; do
	case $1 in
		--help) help;;
		-u) user=`echo $OPTARG` break;;
		-p) passwd=`echo $OPTARG` break;;
		-h) host=`echo $OPTARG` break;;
		-t) bft=`echo $OPTARG` break;;
		-d) dir=`echo $OPTARG` break;;
		-P) port=`echo $OPTARG` break;;
                -S) sock=`echo $OPTARG` break;;
		-D) database=`echo $OPTARG` break;;
		 *) error;;
	esac
done




# 获取传递的参数值
while getopts "u:p:h:t:d:P:S:D:" opt

do
	case $opt in 
		u)user=$OPTARG;;
		p)passwd=$OPTARG;;
	        h)host=$OPTARG;;
		t)type=$OPTARG;;
		d)dir=$OPTARG;;
		P)port=$OPTARG;;
		S)sock=$OPTARG;;
		D)db=$OPTARG;;

	esac
done
# 判断dir是否输入，如未输入，默认为当前目录
if [ ! ${dir} ]
then
	dir=.
fi

echo $dir

# 查看数据库的所有表格
connect="/usr/local/mysql3306/bin/mysql -u$user -p$passwd -D $db -S $sock"
tables=`${connect} -e "show tables"`

# 创建有名管道，使用其控制后台运行进程
thread_num=50
mkfifo fifo
exec 5<>fifo
rm -fr fifo
 
for ((i=0;i<${thread_num};i++))
do
	echo >&5
done


# 根据备份文件类型判断
if [ ! ${type} ];
then
	for table in ${tables};
		do
		{
			read -u5
			if ( echo ${table} | grep  Tables_in );then
				echo >&5
				continue
			else
			{
			/usr/local/mysql3306/bin/mysqldump -u$user -p$passwd -S $sock $db $table > $dir/$table.sql 
			echo $table备份成功;
			echo >&5
			}	&	
			fi
		}
	done
	wait
	exec 3<&-
	exec 3>&-
else
	for table in ${tables}
		do
		{
			if ( echo ${table} | grep -q Tables_in );then 
				continue
			else
			{
			`${connect} -e "select * from $table into outfile '$dir/$table.csv' fields terminated by ',' optionally enclosed by '"' escaped by '"' lines terminated by '\r\n'; "`
			echo $table备份成功;
			echo >&5
			}	&
			fi
		}
	done
	wait
	exec 3<&-
	exec 3>&-
fi
