#---------------------------------------------function-----------------------------------------------
#相对路径传输文件函数
execSyncRe(){
  operaMode=$1
  fileName=$2
  serverNameList=$3
  serverIpList=$4

  if [ $operaMode == "distGet" ]
  then
    index=0
    for sname in ${serverNameList[*]}
    do
      baseCommand="scp -oStrictHostKeyChecking=no "$sname"@"${serverIpList[index]}":"$fileName" ./"
      echo $baseCommand
      index=$(( $index + 1 ))
    done
  fi
}

#绝对路径传输文件函数
execSyncAb(){
  operaMode=$1
  remote=$2
  localtion=$3
  serverIpList=$4

  for sIp in ${serverIpList[*]}
  do
    if [ $operaMode == "distGet" ]
    then
      baseCommand="scp -oStrictHostKeyChecking=no root@"$sIp":"$remote" "$localtion
      echo $baseCommand
    elif [ $operaMode == "distPut" ]
    then
      baseCommand="scp -oStrictHostKeyChecking=no "$localtion" root@"$sIp":"$remote
      echo $baseCommand
    fi
  done
}

#警示
isTruePath(){
  remoteJ="[Remote:]  "$1
  localtionJ="[Local: ]  "$2
  operaMode=$3
  second=0
  clear
  from=""
  to=""
  if [ $operaMode == "distGet" ]
  then
    from=$remoteJ
    to=$localtionJ
  elif [ $operaMode == "distPut" ]
  then
    from=$localtionJ
    to=$remoteJ
  else
    echo "Param error!!!"
    exit 8
  fi
  while [[ second -lt 10 ]]; do
    echo -e "你有"$((10-$second))"秒确认！ 文件走向=  \033[31m "$from"   >>   "$to"\033[0m"
    #echo "你有"$((10-$second))"秒确认！ 文件夹走向=  "$from" >> "$to
    sleep 1
    clear
    second=$(($second + 1))
  done
}

#删除shell数组元素
delEleFArray(){
  array=$1
  index=$2
  echo ${array[*]}
  if [ $index -ge ${#array[*]} ]||[ $index -lt 0 ]
  then
    return array
  fi
  for ((i=$index+1;i<=${#array[*]};i++))
  do
    if [ $i ]
    then
      array[$i-1]=${array[$i]}
    fi
  done
  echo ${array[*]}
}

#使用绝对路径时删除重复ip
reRedundancy(){
  serverIpList=$1
  j=0
  k=0

  while (( $j < ${#serverIpList[*]} ))
  do
    k=$(( $j + 1 ))
    echo $k
    while (( $k <= ${#serverIpList[*]} ))
    do
      #echo ${serverIpList[$j]}"--"${serverIpList[$k]}
      if [[ ${serverIpList[$j]} == ${serverIpList[$k]} ]]
      then
        unset serverIpList[$k]
      fi
      k=$(( $k + 1 ))
      #echo ${serverIpList[*]}
    done
    j=$(( $j + 1 ))
  done

  length=${#serverIpList[*]}
  echo $length
  echo ${serverIpList[$length-1]}
  j=0
  while [[ $j -lt 10 ]] 
  do
    echo ${serverIpList[$j]}
    j=$(( $j + 1 ))
  done
}
#----------------------------------------------function-end-------------------------------


#----------------------------------main----------------------------------------
#Distributed cp file
accountIp="127.0.0.1"
GAME_SERVER_DATA=('gs1' '192.168.0.2' 'gs2' '192.168.0.3')

#服务器相对路径模式(relative)和绝对路径模式(absolute)
pathMode=$1
#文件操作模式: distGet-从游戏服务器获取文件或目录 distPut-从中心服分发文件
operaMode=$2
#远程文件名or目录名
remote=$3
#当前文件名or目录名
localtion=$4

#参数警示
#isTruePath $remote $localtion $operaMode

#获取需要处理的服务器列表
serverNameList=()
serverIpList=()
i=0
serverName=""
serverip=""
sNameInd=0
sIpInd=0
for element in ${GAME_SERVER_DATA[*]}
do
  if [ $i -gt 1 ]
  then
    temp=$(($i % 2 ))
    if [ $temp == 0 ]
    then
      serverNameList[$sNameInd]=$element
      sNameInd=$(( $sNameInd + 1 ))
    else
      serverIpList[$sIpInd]=$element
      sIpInd=$(( $sIpInd + 1 ))
    fi
  fi
  i=$(( $i + 1 ))
done

echo ${serverIpList[*]}
#处理
if [ $pathMode == "relative" ] #相对路径
then
  execSyncRe $operaMode $remote $localtion $serverNameList $serverIpList
elif [ $pathMode == "absolute" ] #绝对路径
then
  reRedundancy $serverIpList
  execSyncAb $operaMode $remote $localtion $serverIpList
else
  exit 8
  echo "pathMode err!"
fi

echo "处理服务器数量： "${#serverIpList[*]}


#---------------------------------main-end------------------------------------


#----------------------------------instructions-------------------------------------------------------------------
#you should use this format: ./DisOperFile.sh [pathmode] [operamode] [remoteFile/Dir] [locationFile/Dir]
#pathmode: relative/absolute 相对路径/绝对路径
#operamode: distGet/distPut 从服务器获取文件/分发当前服务器文件
#remoteFile/Dir: 远程文件或文件目录名
#locationFile/Dir:本地文件或文件目录名
#notes: pathmode onlay
#example: ./DistOperFile.sh absolute distGet /data/allserver/test.log ./
#----------------------------------instructions-end---------------------------------------------------------------
