#!/bin/bash
file=`date -d "-1 day" +%Y%m%d`

if [ `ls /imagedata/imagedata/imagesWechat | grep $file` = "" ]
then
  echo warning! $file没有图片 >> /home/tnmspon/warning_$file.log
  expect <<EOF
  spawn scp /home/tnmspon/warning.log tnmspon@10.221.64.10:~
  expect "*password"
  send "Ddzj5@ni\r"
  expect eof
EOF
fi

tar -zcf /home/tnmspon/$file.tar.gz /imagedata/imagedata/imagesWechat/$file
expect <<EOF
set timeout 300
spawn scp /home/tnmspon/$file.tar.gz tnmspon@10.221.64.10:~
expect "*password"
send "Ddzj5@ni\r"
expect eof
EOF

rm -rf /home/tnmspon/$file.tar.gz
