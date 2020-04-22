#!/usr/bin/env bash

# INCLUDE GLOBAL VARIABLES

# Make sure configuration file exists.
if [ ! -f "../web/docker_conf/configuration.sh" ]; then
	echo "Error: can't open configuration file ../web/docker_conf/configuration.sh"
	exit 255
fi

source ../web/docker_conf/configuration.sh

WEB_CONTAINER_STATUS=$(docker inspect -f {{.State.Running}} $DOCKER_WEB_CONTAINER_NAME)
if [ "$WEB_CONTAINER_STATUS" = false ] ; then
    echo "Docker container '$DOCKER_WEB_CONTAINER_NAME' is not running..."
    exit 255
fi

DB_CONTAINER_STATUS=$(docker inspect -f {{.State.Running}} $DOCKER_DB_CONTAINER_NAME)
if [ "$DB_CONTAINER_STATUS" = false ] ; then
    echo "Docker container '$DOCKER_DB_CONTAINER_NAME' is not running..."
    exit 255
fi

scp root@$REMOTE_HOST:$DB_DUMP_PATH$DB_DUMP_FILENAME .

if [[ $DB_DUMP_FILENAME == *.gz ]]; then
    gzip -d $DB_DUMP_FILENAME
    DB_DUMP_FILENAME="${DB_DUMP_FILENAME//.gz/}"
fi

mv $DB_DUMP_FILENAME custom.sql.bak

docker exec -it $DOCKER_WEB_CONTAINER_NAME /scripts/setupdb.sh

rm custom.sql.bak
