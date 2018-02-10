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
	grep -A1 "smbd/service.c:close_cnum" $samba_logfile  | grep -B2 $users >> $templog

getuser=$(cat $templog | grep -B2 $users | tail -n1 | awk '{ print $7 }')
gethost=$(cat $templog | grep -B2 $users | tail -n1 | awk '{ print $1 }')
getdate=$(cat $templog | grep -B2 $users | tail -n2 | head -n1 | awk '{ print $1 }' | cut -d "[" -f2)
gethour=$(cat $templog | grep -B2 $users | tail -n2 | head -n1 | awk '{ print $2 }' | cut -d "," -f1)
logfile="/var/log/samba/audit/logoff_$(date +%Y%m%d).log"

#===================#
#=== Geting Logs ===#
#===================#
	
echo "#---   Audit Logoff from $users   ---#" >> $logfile
echo >> $logfile
echo >> $logfile
echo "User.: $getuser" >> $logfile
echo "Host.: $gethost" >> $logfile
echo "Date.: $date" >> $logfile
echo "Logoff on.: $gethour" >> $logfile
echo >> $logfile
echo >> $logfile

done

#=======================#
#=== Remove temp log ===#
#=======================#

rm -rf $templog
