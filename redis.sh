#!/bin/bash
#check if root user

USER_ID=$(id -u)


Curr_Dir=$PWD
Log_Dir="/var/log/shell-redis/"
mkdir -p $Log_Dir
Log_File="$Log_Dir/$0.log"

Redis_Host=redis.anildevops.online
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


if [ $USER_ID -ne 0 ]; then
echo -e "$R Please execute the script with sudo access $N" | tee -a $Log_File
exit 1
fi

dnf module disable redis -y &>>$Log_File
validate $? "Disable redis.. "

dnf module enable redis:7 -y &>>$Log_File
validate $? "enable redis.. "

dnf install redis -y &>>$Log_File
validate $? "redis installation.."

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
validate $? "Repacing IP using sed ..."

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
validate $? "Allowing remote connections ..."

sed -i '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
validate $? "updating Protected mode using sed ..."

systemctl enable redis &>>$Log_File
validate $? "enable redis .."

systemctl start redis &>>$Log_File
validate $? "start redis.."