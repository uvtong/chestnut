#!/bin/bash
#echo $0
#echo $1
#echo $2
#bash redis.sh
cd ./../../3rd/skynet
export LD_LIBRARY_PATH=./../../bin:$LD_LIBRARY_PATH 
./skynet ../../config/ball/crazy_m1.config

