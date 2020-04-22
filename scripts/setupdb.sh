#!/usr/bin/env bash

# Make sure configuration file exists.
if [ ! -f "/var/www/html/web/docker_conf/configuration.sh" ]; then
	echo "Error: can't open configuration file /var/www/html/web/docker_conf/configuration.sh"
	exit 255
fi
# Make sure mysql configuration file exists.
if [ ! -f "/var/www/html/web/docker_conf/custom-mysql.cnf" ]; then
	echo "Error: can't open mysql configuration file /var/www/html/web/docker_conf/custom-mysql.cnf"
	exit 255
fi

# INCLUDE GLOBAL VARIABLES
source /var/www/html/web/docker_conf/configuration.sh

# SHOW DATABASES
mysql --defaults-extra-file=/var/www/html/web/docker_conf/custom-mysql.cnf -e "SHOW DATABASES;"

if [ "`mysql --defaults-extra-file=/var/www/html/web/docker_conf/custom-mysql.cnf -e 'show databases;' | grep ${DATABASE_NAME}`" == "${DATABASE_NAME}" ]; then
    # Drop database
    echo "Dropping DB $DATABASE_NAME ..."
    mysql --defaults-extra-file=/var/www/html/web/docker_conf/custom-mysql.cnf -e "DROP DATABASE $DATABASE_NAME;"
fi

# Create new database
echo "Creating DB $DATABASE_NAME ..."
mysql --defaults-extra-file=/var/www/html/web/docker_conf/custom-mysql.cnf -e "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME CHARACTER SET utf8 COLLATE utf8_general_ci;"
echo "Creating DB user $T3KIT_USER ..."
mysql --defaults-extra-file=/var/www/html/web/docker_conf/custom-mysql.cnf -e "GRANT ALL PRIVILEGES ON $DATABASE_NAME.* TO '$T3KIT_USER'@'$T3KIT_USER_DOMAIN' IDENTIFIED BY '$T3KIT_PASSWORD';"
echo "Importing mysql dump to DB ..."
pv /scripts/custom.sql.bak | mysql --defaults-extra-file=/var/www/html/web/docker_conf/custom-mysql.cnf $DATABASE_NAME

UPDATE_DOMAINS=($SYS_DOMAINS)
for i in "${UPDATE_DOMAINS[@]}"; do
    RECORD_UID=$(echo $i | awk -F':' '{print $1'})
    RECORD_DOMAIN=$(echo $i | awk -F':' '{print $2'})
    mysql --defaults-extra-file=/var/www/html/web/docker_conf/custom-mysql.cnf -e "UPDATE $DATABASE_NAME.sys_domain SET domainName = '$RECORD_DOMAIN' WHERE uid = $RECORD_UID;"
    echo " » Set domainName to $RECORD_DOMAIN in sys_domain record with uid $RECORD_UID"
done

if [ ! -z "$SYS_TEMPLATE_EMPTY_BASEURL" ]; then
    mysql --defaults-extra-file=/var/www/html/web/docker_conf/custom-mysql.cnf -e "UPDATE $DATABASE_NAME.sys_template SET config = CONCAT(config,'\nconfig.baseURL >') WHERE uid IN ($SYS_TEMPLATE_EMPTY_BASEURL);"	
    echo " » Set config.baseUrl > in sys_templates with uid:s $SYS_TEMPLATE_EMPTY_BASEURL"
fi

CDNEXISTS=`mysql --defaults-extra-file=/var/www/html/web/docker_conf/custom-mysql.cnf -e "SHOW COLUMNS FROM $DATABASE_NAME.sys_domain LIKE 'tx_pxacdn_enable';" | wc -l`
if [ $CDNEXISTS == "0" ]; then
    echo " » No pxa_cdn, no need to uncheck tx_pxacdn_enable"
else
    mysql --defaults-extra-file=/var/www/html/web/docker_conf/custom-mysql.cnf -e "UPDATE $DATABASE_NAME.sys_domain SET tx_pxacdn_enable=0 WHERE tx_pxacdn_enable=1;"
    echo " + tx_pxacdn_enable was unchecked on all domains"
fi
