#!/bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOG_PATH="$CURRENT_DIR/log_backup"

rm -rf $LOG_PATH
touch $LOG_PATH

log_message() {
    echo -e $1 >> $LOG_PATH
	echo -e $1
}

log_message "\n\n\n\n\n\n\n"
for i in {1..5}
do
    log_message "===============*****************===================="
done


for i in `seq 0 7`; do
	BACKUP_DATE=$(date -d "$i days ago" +"%d-%m-%Y")
	YEAR=$(date -d "$i days ago" +"%Y")
	MONTH=$(date -d "$i days ago" +"%-m")
	DAY=$(date -d "$i days ago" +"%-d")
	RECORD_PATH='/home/record'/$YEAR/$YEAR$MONTH/$YEAR$MONTH$DAY
	
    ListIp=(172.16.16.100)
    ListFolder=(/root/storerecord/)
	
	# convert wav2 to mp3
	HOURS=$(date -d "$i days ago" +"%H")
	if [ $HOURS -gt 0 ] && [ $HOURS -lt 5 ] ; then
		cd '/home/record'/$YEAR/$YEAR$MONTH/$YEAR$MONTH$DAY
		for temp in *.wav; do
		 if [ -e "$temp" ]; then
		   file=`basename "$temp" .wav`
		   lame "$temp" "$file.mp3"
		 fi
		done
	fi	

	for i in "${!ListIp[@]}"; do	
		
		BACKUP_ADDRESS=${ListIp[$i]}
		log_message "\n\n================================ Start sync to $BACKUP_ADDRESS ======================================"
		log_message "Backup data for this date ========> $BACKUP_DATE"
		log_message "RECORD_PATH =============> $RECORD_PATH"

		REMOTE_PATH=${ListFolder[$i]}/$YEAR/$YEAR$MONTH
		log_message "BACKUP_ADDRESS ======> $BACKUP_ADDRESS"
		log_message "REMOTE_PATH ======> $REMOTE_PATH"

		log_message "Create local directory if not existed..."
		/bin/mkdir -p "$RECORD_PATH"
		log_message "RECORD_PATH ============> $RECORD_PATH"

		log_message "Create remote directory if not existed..."
		ssh $BACKUP_ADDRESS "mkdir -p $REMOTE_PATH"
		log_message "REMOTE_PATH ============> $BACKUP_ADDRESS:$REMOTE_PATH"

		CMD_BACKUP="rsync -av --progress --exclude=*.wav $RECORD_PATH root@$BACKUP_ADDRESS:$REMOTE_PATH/ > $LOG_PATH 2>&1 &"
		log_message "Sync file cmd ===> $CMD_BACKUP"
		eval "$CMD_BACKUP"
	done
done

# remove old folder
for i in `seq 60 400`; do
	YEAR=$(date -d "$i days ago" +"%Y")
	MONTH=$(date -d "$i days ago" +"%-m")
	DAY=$(date -d "$i days ago" +"%-d")
	log_message "remove old day =====> /home/record/$YEAR/$YEAR$MONTH/$YEAR$MONTH$DAY"
	rm -rf '/home/record'/$YEAR/$YEAR$MONTH/$YEAR$MONTH$DAY	
done

log_message "Backup done!!!!!!!!!!!!!!!!!"

