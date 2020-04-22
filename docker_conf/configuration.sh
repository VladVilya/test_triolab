#!/usr/bin/env bash

# Path to installation on remote server
REMOTE_INSTALLATION_PATH="/mnt/persist/www/sites_docroot/siteroot"
# Remote server host name
REMOTE_HOST="hostname.cloudnet.se"
# Remote server ssh port
REMOTE_PORT="22"

# What folders from site on server to syncronize, separate list by space
SYNC_FOLDERS="typo3conf/l10n/"
# What files from site on server to syncronize, separate list by space
SYNC_FILES=""

# Path on server where database dumps are stored including trailing slash
DB_DUMP_PATH="/mnt/mysqldump"
# Filename of database dump file on server (note, some backups are gz files)
DB_DUMP_FILENAME="custom.sql.bak"

# The name of the web docker-comtainer (defined in docker-compose.yaml) 
DOCKER_WEB_CONTAINER_NAME="triolab_web"
# The name of the database docker-comtainer (defined in docker-compose.yaml) 
DOCKER_DB_CONTAINER_NAME="triolab_db"

# Change TYPO3 domains in sys_domains (uid:new.domain uid:new.domain ...)
SYS_DOMAINS="1:localhost:8888"
# Add config.baseURL > to sys_templates with these id:s (x,x,x)
SYS_TEMPLATE_EMPTY_BASEURL="1"

# If standard t3kit docker is used, there is no need to change this, if Development/Docker context is added in AdditionalConfiguration.php
DATABASE_NAME="t3kit"
T3KIT_USER="t3kit"
T3KIT_USER_DOMAIN="localhost"
T3KIT_PASSWORD="t3kit1234"
