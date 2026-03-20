#!/bin/bash

Curr_Dir=$PWD

echo "$Curr_Dir"
#enable colours
R='\e[31m'
G='\e[32m'
N='\e[0m'
Y='\e[33m'
#check if root user
USER_ID=$(id -u)

validate()
{
    if [ $1 -ne 0 ]; then 
    echo -e " $2... $R FAILURE $N"
    else 
    echo -e " $2... $G SUCCESS $N"
}

echo -e "user id is $G $USER_ID $N"
if [ $USER_ID -ne 0 ]; then

echo -e "$R Please execute the script with sudo access $N"
exit 1
fi

cp Curr_Dir/mongodb.repo /etc/yum.repos.d/mongo.repo
validate $? "Copying repo file repo folder"
