#!/bin/bash
CONT_NETWORK=coiot
CONT_NGINX=coiot-nginx
CONT_MYSQL=coiot-mysql
CONT_HUB=coiot-hub
HTTP_PORT=80
HTTPS_PORT=443
MQTT_PORT=1883
MQTTS_PORT=8883
MYSQL_PORT=3306

# NGINX:
echo "[*] Running nginx server"
docker start $CONT_NGINX
sleep 2s
if [[ $(curl localhost 2> /dev/null) = *"<html>"* ]]; then
    echo "[.] nginx server is up"
else
    echo "[!] nginx server is down"
    exit 1
fi

# MYSQL:
echo "[*] Running mysql server"
docker start $CONT_MYSQL
sleep 2s
if [[ -z $(docker ps | grep $CONT_MYSQL) ]]; then
    echo "[!] mysql server is down"
    exit 1
fi
echo "[*] Waiting mysql server"
until nc -z -v -w30 localhost $MYSQL_PORT
do
  sleep 5
done

# HUB:
echo "[*] Running hub server"
docker start $CONT_HUB
sleep 2s
if [[ -z $(docker ps | grep $CONT_HUB) ]]; then
    echo "[!] hub server is down"
    exit 1
fi
echo "[*] Waiting hub server"
until nc -z -v -w30 localhost $MQTT_PORT
do
  sleep 5
done
