#!/usr/bin/env bash
routers=( 172.16.5.1 172.17.5.1 )
project="int.lan"
backupage="42"
login="username"
privatekey="/root/.ssh/mik_rsa"
backupdir="/mnt/data/mik-backup/$project"
# - #
fulldir="${backupdir}/`date +%Y`/`date +%m`/`date +%d`"
curdate="$(date +%d-%m-%Y)"
logfile="${project}.log"

# Условие для проверки наличия директории и ее очистки;
if [ -d $backupdir ]; then
	find ${backupdir}/* -type d -mtime +$backupage -exec rm -rf {} \; > /dev/null
fi

# Задаем функцию утилиты logger;
function logger() {
	echo "["`date "+%H:%M:%S"`"]: $1" >> $backupdir/$logfile
}
# - #
mkdir -p $fulldir
echo >> $backupdir/$logfile
logger "--- $curdate - START BACKUP: $project ---"

# Функция проверки доступности хостов;
check_host() {
	ping -c 3 ${r} > /dev/null ; status_ch=$?
	if [ $status_ch -ne 0 ] ; then logger "[-] Хост: ${r} недоступен" ; fi
}

# Функция создания бекапа;
create_backup() {
	cmd_cleanup="/ip dns cache flush; /console clear-history"
	ssh ${login}@$r -i $privatekey "${cmd_cleanup}" > /dev/null
	cmd_backup="/system backup save name=${r}.backup"
	ssh ${login}@$r -i $privatekey "${cmd_backup}" > /dev/null
	cmd_backup="/export compact file=${r}"
	ssh ${login}@$r -i $privatekey "${cmd_backup}" > /dev/null
}

# Функция загрузки бекапа;
upload_backup() {
	scp -i $privatekey ${login}@${r}:${r}.backup ${fulldir}
	scp -i $privatekey ${login}@${r}:${r}.rsc ${fulldir}
	ssh ${login}@$r -i $privatekey "/file remove \"${r}.backup\""
	ssh ${login}@$r -i $privatekey "/file remove \"${r}.rsc\""
}

# Цикл;
for r in ${routers[@]}; do
	check_host ; if [ $status_ch -ne 0 ] ; then continue ; fi
	create_backup && sleep 3
	upload_backup
	logger "[+] Хост: ${r} успешно"
done

logger "--- $curdate - END BACKUP: $project ---"
