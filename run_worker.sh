#!/bin/bash
if [[ -z $1 ]]; then
    echo "USAGE: $0 [NUMBER]"
    exit
fi
docker run --name coiot-worker-$1 --net coiot --ip 10.11.0.$(($1 + 8)) -d mathtin/coiotworker
