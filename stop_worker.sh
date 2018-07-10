#!/bin/bash
if [[ -z $1 ]]; then
    echo "USAGE: $0 [NUMBER]"
    exit
fi
docker stop coiot-worker-$1
docker rm coiot-worker-$1
