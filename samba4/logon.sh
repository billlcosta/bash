#!/bin/bash
#=======================================================================================#
#					Log by User					#
#											#
# Created by.: pH									#
# Date.: 2017/06/07									#
# Version.: 1.0										#
# Note.: Script development for generate log of Samba per user (logon)			#
#											#
#=======================================================================================#

#==================#
#=== Usage Mode ===#
#==================#

if [ $# -ne 1 ]; then
   echo "Sintaxe: $0 <listfile>";
   exit 1;
fi

#=================#
#=== Variables ===#
#=================#

date=$(date +%Y/%m/%d)
samba_logfile="/var/log/samba/samba.log"
templog="/tmp/$RANDOM.log"
	
for users in $(cat $1);do
	grep -B1 "connect to service netlogon initially as user $users" $samba_logfile >> $templog

getuser=$(cat $templog | grep -B1 $users | tail -n1 | awk '{ print $10 }')
gethost=$(cat $templog | grep -B1 $users | tail -n1 | awk '{ print $1 }')
getdate=$(cat $templog | grep -B1 $users | head -n1 | awk '{ print $1 }' | cut -d "[" -f2)
gethour=$(cat $templog | grep -B1 $users | head -n1 | awk '{ print $2 }' | cut -d"," -f1)
logfile="/var/log/samba/audit/logon_$(date +%Y%m%d).log"

#===================#
#=== Geting Logs ===#
#===================#
	
echo "#---   Audit Logon from $users   ---#" >> $logfile
echo >> $logfile
echo >> $logfile
echo "User.: $getuser" >> $logfile
echo "Host.: $gethost" >> $logfile
echo "Date.: $date" >> $logfile
echo "Logon on.: $gethour" >> $logfile
echo >> $logfile
echo >> $logfile

done

#=======================#
#=== Remove temp log ===#
#=======================#

rm -rf $templog
