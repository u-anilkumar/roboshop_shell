#!/bin/bash
#check if root user

USER_ID=$(id -u)

if [ $USER_ID -ne 0 ]; then
echo -e "$R Please execute the script with sudo access $N" | tee -a $Log_File
exit 1
fi

Curr_Dir=$PWD
Log_Dir="/var/log/shell-mongo/"
mkdir -p $Log_Dir
Log_File="$Log_Dir/$0.log"

#enable colours
R='\e[31m'
G='\e[32m'
N='\e[0m'
Y='\e[33m'

validate()
{
    if [ $1 -ne 0 ]; then 
    echo -e " $2... $R FAILURE $N" | tee -a $Log_File
    else 
    echo -e " $2... $G SUCCESS $N" | tee -a $Log_File
    fi
}

#check if root user
USER_ID=$(id -u)

if [ $USER_ID -ne 0 ]; then
echo -e "$R Please execute the script with sudo access $N" | tee -a $Log_File
exit 1
fi

cp $Curr_Dir/mongodb.repo /etc/yum.repos.d/mongo.repo
validate $? "Copying repo file repo folder"

dnf install mongodb-org -y 
validate $? "mongodb installation..."

systemctl enable mongod 
systemctl start mongod 
validate $? "mongodb start..."

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "Repacing IP using sed ..."

systemctl restart mongod
validate $? "Restart os mongodb ...."