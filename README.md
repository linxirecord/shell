### 参数说明:
```yaml
-u:连接数据库的用户名
-p:连接数据库使用的用户密码
-h:远程连接时的主机ip
-t:备份文件的类型(sql/csv)
-d:备份文件的存放目录(sql文件可以随意选择，csv文件需要与数据库中设置的secure_file_priv值相同)
-P:数据库端口(默认3306)
-S:sock文件
-D:需要备份的目标库
```
### 脚本功能:
* 详细的help
* 根据传递的db，备份出db下的所有表，并且备份文件的名称与表名对应。
* 根据传递的type值，备份sql或csv文件。
* 根据db下表的数量启动多线程。
* 使用有名管道对后台运行的线程数量控制(默认为50,可以根据需求修改thread_num值)。
### 使用说明:
* 根据实际使用的环境需要修改的参数（如下图）:
```yaml
/usr/local/mysql3306/bin/mysql: mysql脚本存放路径，根据实际环境修改
/usr/local/mysql3306/bin/mysqldump: mysqldump脚本存放路径，根据实际环境修改
sock:如果没有使用到sock文件可以删除
多实例环境下需要添加$port
```
