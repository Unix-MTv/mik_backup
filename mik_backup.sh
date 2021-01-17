#!/usr/bin/env bash
routers=( 172.16.5.1 172.17.5.1 )
backupdir="/mnt/data/mik-backup/backup"
backupage="42"
privatekey="/root/.ssh/mik_rsa"
login="username"
#passwd="pa$Sw0rd"
fulldir="${backupdir}/`date +%Y`/`date +%m`/`date +%d`"

# Условие для проверки наличия директории и ее очистки;
if [ -d $backupdir ]; then
	find ${backupdir}/* -type d -mtime +${backupage} -exec rm -rf {} \; > /dev/null
fi

# Функция проверки хостов;
check_host() {
	ping -c 3 ${r} > /dev/null
}

# Функция создание бекапа;
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
	mkdir -p $fulldir
	scp -i $privatekey ${login}@${r}:${r}.backup ${fulldir}
	scp -i $privatekey ${login}@${r}:${r}.rsc ${fulldir}
	ssh ${login}@$r -i $privatekey "/file remove \"${r}.backup\""
	ssh ${login}@$r -i $privatekey "/file remove \"${r}.rsc\""
}

# Цикл для функций;
for r in ${routers[@]}; do
	check_host || continue
	create_backup && sleep 5
	upload_backup
done
