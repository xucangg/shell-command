#! /bin/bash

usage(){
cat <<EOF
Usage: $0 [-m] 分页显示查询结果
  or:  $0 [-n 数字] 匹配多行查询结果
  or:  $0 [-l] 查询非log后缀日志
  or:  $0 [-r 结束日期] 关键字 开始日期 查询日期范围内日志 
EOF
}

#查询文件设置
#--------------------------------------------------
log_dir=~/TNMS_LOG/
dir=TNMS_LOG

#--------------------------------------------------

function getfile {
local filedate=`echo $1 | sed $'s/\'//g'`
if [ -z `echo $filedate | grep [2][0][0-9][0-9]-[0-1][0-9]-[0-3][0-9]$` ]
then
  echo warnging! 请输入正确的日期格式 yyyy-mm-dd
  return 1
fi

local files
if [ "$2" = "" ]
then
   files=`ls --full-time $log_dir | sed -n "/$filedate/p" | awk '{print $9}'|grep log`
elif [ "$2" = "l" ]
then
   files=`ls --full-time $log_dir | sed -n "/$filedate/p" | awk '{print $9}'|grep -v log`
fi
if [ "$files" = "" ]
then
   echo 该日期没有日志
   return 1
else
   echo $files
fi
}

function findky {
ky=`echo $1 | sed $'s/\'//g'`

for f in $2
do
  file=$dir/$f
  grep -H "$ky" $file
done
}

parameters=`getopt -q mn:lr: "$@"`
set --  $parameters

FILES=''
PARAMS=''
Model=""
M_PARAM=
end_time=
while [ -n "$1" ]
  do
    case $1 in
	--)
	  params=($@)
	  str=''
	  len=${#params[@]}
	  for((i=1;i<$[$len-1];i++))
	  do str+="${params[$i]}"" "
	  done
          PARAMS=(${params[0]} "$str" ${params[$len-1]})
	if [[ ${#PARAMS[*]} -eq 3 && "${PARAMS[1]}" != "" ]]
        then
	  FILES=$(getfile ${PARAMS[2]})
	  if [ $? -eq 1 ]
	  then
		 echo $FILES
		 exit
	  fi
	else
		echo 输入参数 [搜索关键词] [日期 yyyy-mm-dd]
		echo 
		usage
                exit
	  fi;;
	-m)
	  Model=more
          ;;
        -n)
	  M_PARAM=$2
	  Model=nline
	;;
	-l)
	Model=no_log
	;;
	-r)
	end_time=$2
	Model=range_time
    esac
    shift
done

if [ "$Model" = "more" ]
then
   findky "${PARAMS[1]}" "$FILES" | more
elif [ "$Model" = "" ]
then
   findky "${PARAMS[1]}" "$FILES"
   if [ "`findky "${PARAMS[1]}" "$FILES"`" = "" ]
   then
      echo 该日期没有查询到关键字信息
   fi
elif [ "$Model" = "nline" ]
then
  process=-`echo $M_PARAM | sed $'s/\'//g'`
  ky=`echo ${PARAMS[1]} | sed $'s/\'//g'`
  for i in $FILES
  do
    file=$dir/$i
    grep -H $process "$ky" $file
  done
elif [ "$Model" = "no_log" ]
then
    nologfile=$(getfile ${PARAMS[2]} l)
    findky "${PARAMS[1]}" "$nologfile"
elif [ "$Model" = "range_time" ]
then
   declare -a date_array
   index=0
   start_time=${PARAMS[2]}
   process1=`echo $start_time | sed $'s/\'//g'`
   process2=`echo $end_time | sed $'s/\'//g'`
   start_tmp=`date -d $process1 +%s`
   end_tmp=`date -d $process2 +%s`
   ky=`echo ${PARAMS[1]} | sed $'s/\'//g'`
   while (( "${start_tmp}" <= "${end_tmp}" ))
   do
  	cur_day=$(date -d @${start_tmp} +"%Y-%m-%d")
  	date_array[${index}]=${cur_day}
	start_tmp=$((${start_tmp}+86400))
	((index++))
   done
   for i in ${date_array[@]};
   do
	echo -------------------正在查询$i日志-----------------------------
 	date_file=$(getfile $i)	
	findky "$ky" "$date_file"
        if [ "`findky "$ky" "$date_file"`" = "" ]
        then
           echo 该日期没有查询到关键字信息
        fi
        echo ' '
        echo ' '
   done
fi
