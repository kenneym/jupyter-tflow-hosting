#!/bin/bash
# Author: Matt Kenney, October 2019

usage="usage ./compose.sh [gpu | cpu | stop]"

# Ensure correct num arguments were passed:
if [ "$#" -lt 1 ]; then
    echo 1>&2 "$usage"
    exit 1
fi

option=$1 # Option passed to command line

if [ "$option" == "gpu" ]; then
    docker-compose -f ./docker-compose-gpu.yml up -d

elif [ "$option" == "cpu" ]; then
    docker-compose -f ./docker-compose-cpu.yml up -d

elif [ "$option" == "down" ]; then
    docker-compose down

else 
    echo 1>&2 "$usage"
    exit 1
fi
