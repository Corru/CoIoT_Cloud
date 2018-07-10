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
MYSQL_PASSWORD=coiotpassword
MYSQL_ROOT_PASSWORD=root
if [[ -z $(docker network ls | grep $CONT_NETWORK) ]]; then 
    echo "[*] Creating 10.11.0.1/16 subnet 'coiot'"
    docker network create --subnet=10.11.0.1/16 $CONT_NETWORK
fi

if [[ -z $(docker images | grep nginx) ]]; then 
    echo "[*] Pulling nginx"
    docker pull nginx
fi

if [[ -z $(docker images | grep mysql/mysql-server) ]]; then 
    echo "[*] Pulling mysql"
    docker pull mysql/mysql-server
fi

if [[ -z $(docker images | grep mathtin/coiotworker) ]]; then 
    echo "[*] Pulling coiotworker"
    docker pull mathtin/coiotworker
fi

if [[ -z $(docker images | grep mathtin/coiothub) ]]; then 
    echo "[*] Pulling coiothub"
    docker pull mathtin/coiothub
fi

# NGINX:
echo "[*] Stopping previous nginx container"
docker stop $CONT_NGINX &> /dev/null
echo "[*] Removing previous nginx container"
docker rm $CONT_NGINX &> /dev/null
echo "[*] Running nginx server"
docker run --name $CONT_NGINX \
           --net $CONT_NETWORK --ip 10.11.0.2 \
           -v $PWD/nginx/conf/nginx.conf:/etc/nginx/nginx.conf:rw \
           -v $PWD/nginx/www:/www:ro \
           -v $PWD/nginx/conf:/conf:ro \
           -p $HTTP_PORT:80 -p $HTTPS_PORT:443 -p $MQTT_PORT:1883 -p $MQTTS_PORT:8883 \
           -d nginx
sleep 2s
if [[ $(curl localhost 2> /dev/null) = *"<html>"* ]]; then
    echo "[.] nginx server is up"
else
    echo "[!] nginx server is down"
    exit 1
fi

# MYSQL:
echo "[*] Stopping previous mysql container"
docker stop $CONT_MYSQL &> /dev/null
echo "[*] Removing previous mysql container"
docker rm $CONT_MYSQL &> /dev/null
echo "[*] Running mysql server"
docker run --name $CONT_MYSQL \
           --net $CONT_NETWORK --ip 10.11.0.3 \
           -v $PWD/mysql/storage:/storage \
           -v $PWD/mysql/conf/main.cnf:/etc/my.cnf:ro \
           --env="MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" \
           --env="MYSQL_USER=coiot" \
           --env="MYSQL_PASSWORD=$MYSQL_PASSWORD" \
           --env="MYSQL_DATABASE=coiot" \
           -p $MYSQL_PORT:3306 \
           -d mysql/mysql-server
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
echo "[*] Stopping previous hub container"
docker stop $CONT_HUB &> /dev/null
echo "[*] Removing previous hub container"
docker rm $CONT_HUB &> /dev/null
echo "[*] Running hub server"
docker run --name $CONT_HUB \
           --net $CONT_NETWORK --ip 10.11.0.4 \
           -d mathtin/coiothub
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
