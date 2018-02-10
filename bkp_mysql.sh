#/bin/bash!
#----------------------------------------------------------------------------------#
#                           Backup Full MySQL                                      #
#                                                                                  #
# Create by.: pH (phillipe@phillipefarias.com.br)                                  #
# Date.: 04/01/2016                                                                #
# Version.:                                                                        #
#                                                                                  #
#----------------------------------------------------------------------------------#

#---------------------#
#      Variables      #
#---------------------#

dir_bkp="/backups/databases" # Set your backup directory here!
data=`date +%Y%m%d`
mysql_user="root" # Set user to run backup
log="/var/log/backup_mysql.errorlog" # Set log file

#--------------------#
#--- Start backup ---#
#--------------------#

export MYSQL_PWD="#Modify@2018$" # Set password

if [ $# -ne 1 ]; then
   echo "Sintaxe: run backup mysql <dir_destino>";
   exit 1;
fi
DIRBAK="${1}";

mkdir -p "$DIRBAK" || exit 1;
cd "$DIRBAK" || exit 1;

MYSQL="$(which mysql)";
if [ ! -x ${MYSQL} ]; then
   echo "mysql (${MYSQL}) not found.";
   exit 1;
fi

echo "show databases;" | mysql -h 127.0.0.1 -u $mysql_user -s | grep -vE "information_schema" | while read BANCO; do

   echo ${BANCO};

   nice mysqldump -h 127.0.0.1 -u $mysql_user --routines ${BANCO} | gzip -9 > ${BANCO}_$(date "+%Y%m%d").sql.gz;

   if [ "$?" != "0" ]; then
      echo "Error to run backup ${BANCO}";
      echo "ERROR: ${BANCO}" >> $log
      exit 1;
   fi
done

$(which find) $dir_bkp -maxdepth 1 -type f -mtime +30 | $(which xargs) rm -rf
