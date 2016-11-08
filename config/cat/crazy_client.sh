#!/bin/bash
#echo $0
#echo $1
#echo $2
cd ./../../3rd/skynet
echo -n "enter server name:"
read server
echo -n "enter user:"
read user
echo -n "enter password:"
read password
./3rd/lua/lua ./../../config/cat/client.lua $server $user $password

