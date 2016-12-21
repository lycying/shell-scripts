### Basic Installation
You can install this via the command-line with either `curl` or `wget`.
#### via curl
```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/lycying/shell-scripts/master/install.sh)"
```
#### via wget
```shell
sh -c "$(wget https://raw.githubusercontent.com/lycying/shell-scripts/master/install.sh -O -)"
```
### Usage
##### dump_java.sh
dump_java.sh $pid 
一次性dump java进程各种信息到特定目录
```shell
jstack jinfo jstat jmap lsof 
netstat iostat mpstat vmstat
free sar uptime
```
##### dump_memroy_use_gdb.sh 
dump_memroy_use_gdb.sh $pid

使用gdb拷贝进程内存信息到当前目录,如果没有gdb命令,`yum install gdb` 安装之

##### killall.sh 
killall.sh $desc

killall的sh版本,使用grep来匹配，批量杀死

##### who_use_swap.sh
who_use_swap.sh

找到哪些进程在使用交换分区

##### pmap_jre.py
pmap_jre.py $pid

根据pmap信息查看java进程占用内存的概况，仅供参考用

##### strace_cmd.sh
strace_cmd.sh $pid

strace的常用方式

##### server_list.sh
通过修改文件 ~/.oh-my-shell-scripts/bin/servers_list/servers.txt

加入你的服务器，运行此命令将显示一个好看的屏幕，输入数字即可进入主机

##### 更新脚本
update_oh_my_shell_scripts.sh

