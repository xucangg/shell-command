#! /bin/bash
web_url=(
http://10.222.55.67:8080/hbss/active.do 
http://10.222.55.67:8280/hbss/active.do 
)
exprot_url=http://10.222.55.67:8084/export/active.do
sms_url=http://10.222.55.67:8083/sms_server/active.do

start_time=`stat -c '%Y' 10.222.55.67_app.log`

for i in ${web_url[*]}
do
  result=`curl -is $i | grep -o 'HTTP/1.1 200 OK'`
  if [ "$result" = "" ]
  then  
        port=`echo $i | awk -F ':' '{print $3}' | awk -F '/' '{print $1}'`
	echo `date` app端口$port服务出错 >> /home/tnmspon/10.222.55.67_app.log
        ps_id=`netstat -antp | grep $port | grep LISTEN| awk '{print $7}' | awk -F '/' '{print $1}'`
	kill 9 $ps_id
	echo `date` app端口$port服务已杀掉 >> /home/tnmspon/10.222.55.67_app.log
  fi
done
sleep 1

if [ "`curl -is $exprot_url | grep -o 'HTTP/1.1 200 OK'`" = "" ]
then
   echo `date` 导出服务端口8084服务出错 >> /home/tnmspon/10.222.55.67_app.log
   ps_id=`netstat -antp | grep 8084 | grep LISTEN| awk '{print $7}' | awk -F '/' '{print $1}'`
   kill 9 $ps_id
   echo `date` 导出服务端口8084服务已杀掉 >> /home/tnmspon/10.222.55.67_app.log
fi

sleep 1

if [ "`curl -is $sms_url | grep -o 'HTTP/1.1 200 OK'`" = "" ]
then
   echo `date` 导出服务端口8083服务出错 >> /home/tnmspon/10.222.55.67_app.log
   ps_id=`netstat -antp | grep 8083 | grep LISTEN| awk '{print $7}' | awk -F '/' '{print $1}'`
   kill 9 $ps_id
   echo `date` 导出服务端口8083服务已杀掉 >> /home/tnmspon/10.222.55.67_app.log
fi

sleep 1

disk=`mount | grep /home | awk ' {print $6}' | awk -F ',' '{print $1}' | grep -o rw`
if [ "$disk" = "" ]
then
   echo `date` mount 指令检测到/home目录下挂载磁盘出错` >> /home/tnmspon/10.222.55.67_app.log
fi

end_time=`stat -c '%Y' 10.222.55.67_app.log`
if [ "$start_time" != "$end_time" ]
then
  expect <<EOF
  spawn scp /home/tnmspon/10.222.55.67_app.log tnmspon@10.222.55.74:/home/tnmspon/maintain_log/
  expect "*password"
  send "Ddzj5@ni\r"
  expect eof
EOF
fi
