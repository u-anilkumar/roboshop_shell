#!/bin/bash

#enable colours
R='\e[31m'
G='\e[32m'
N='\e[0m'
Y='\e[33m'
#check if root user
USER_ID=$(id -u)

if [ $USER_ID -ne 0 ]; then

echo -e "$R Please execute the $G script with$Y sudo $N access"
exit 1
fi
