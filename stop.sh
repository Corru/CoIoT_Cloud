#!/bin/bash
CONT_NGINX=coiot-nginx
CONT_MYSQL=coiot-mysql
CONT_HUB=coiot-hub
echo "[*] Stopping nginx container"
docker stop $CONT_NGINX &> /dev/null
echo "[*] Stopping hub container"
docker stop $CONT_HUB &> /dev/null
echo "[*] Stopping mysql container"
docker stop $CONT_MYSQL &> /dev/null

