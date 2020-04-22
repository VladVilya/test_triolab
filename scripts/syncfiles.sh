#!/usr/bin/env bash

# Make sure configuration file exists.
if [ ! -f "../web/docker_conf/configuration.sh" ]; then
	echo "Error: can't open configuration file ../web/docker_conf/configuration.sh"
	exit 255
fi
source ../web/docker_conf/configuration.sh

cd ../web/

SYNCFOLDERS=($SYNC_FOLDERS)
for i in "${SYNCFOLDERS[@]}"; do
	echo "==> Syncronize folder $REMOTE_HOST:root@$REMOTE_HOST:$REMOTE_INSTALLATION_PATH/$i $i"
    mkdir -p $i
	rsync -azhqv --rsh="ssh -p$REMOTE_PORT" root@$REMOTE_HOST:$REMOTE_INSTALLATION_PATH/$i $i
done
SYNCFILES=($SYNC_FILES)
for i in "${SYNCFILES[@]}"; do
	echo "==> Syncronize files $REMOTE_HOST:root@$REMOTE_HOST:$REMOTE_INSTALLATION_PATH/$i $i"
    rsync -azhqv --rsh="ssh -p$REMOTE_PORT" root@$REMOTE_HOST:$REMOTE_INSTALLATION_PATH/$i $i
done

cd ../scripts/