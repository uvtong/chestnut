#!/bin/bash
#echo $0
#echo $1
#echo $2
#bash redis.sh
cd ./../../3rd/skynet
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/alice/Documents/github/Crazy/bin
./skynet ../../config/ball/crazy_m1.config

