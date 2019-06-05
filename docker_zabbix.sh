#!/bin/bash

# Change these settings
MYSQL_ROOT_PASSWORD="rootpassword"
ZABBIX_DB_USER_PASSWORD="zabbixpw"
SERVER_IP="10.132.0.2"


# Deploy a mysql container for zabbix to use.
docker run -d \
  --name="zabbix-mysql-database" \
  --restart=always \
  -p 3306:3306 \
  -e MYSQL_DATABASE=zabbix \
  -e MYSQL_USER=zabbix \
  -e MYSQL_PASSWORD=$ZABBIX_DB_USER_PASSWORD \
  -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
  mysql:5.7

# Deploy the zabbix-server application container
docker run -d \
  --name zabbix-server \
  --restart=always \
  -e DB_SERVER_HOST=$SERVER_IP \
  -e MYSQL_USER="zabbix" \
  -e MYSQL_PASSWORD=$ZABBIX_DB_USER_PASSWORD \
  -p 10050:10050 \
  -p 10051:10051 \
  zabbix/zabbix-server-mysql:ubuntu-3.4-latest

# Deploy the webserver frontend.
docker run -d \
  --name zabbix-web-nginx \
  --restart=always \
  -e DB_SERVER_HOST="$SERVER_IP" \
  -e MYSQL_USER="zabbix" \
  -e MYSQL_PASSWORD=$ZABBIX_DB_USER_PASSWORD \
  -e ZBX_SERVER_HOST=$SERVER_IP \
  -e PHP_TZ="UTC" \
  -p 80:80 \
  -p443:443 \
  zabbix/zabbix-web-nginx-mysql:ubuntu-3.4-latest
