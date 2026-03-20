#!/bin/bash
#check if root user

USER_ID=$(id -u)


Curr_Dir=$PWD
Log_Dir="/var/log/shell-rabbitmq/"
mkdir -p $Log_Dir
Log_File="$Log_Dir/$0.log"

Mongo_Host=mongodb.anildevops.online
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

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "copying rabbitmq.repo to /etc/yum.repos folder.."

dnf install rabbitmq-server -y &>>$Log_File

systemctl enable rabbitmq-server &>>$Log_File
systemctl start rabbitmq-server &>>$Log_File
validate $? "enabled and Start rabbitmq server.."

id roboshop &>>$Log_File

if [ $? -ne 0 ]; then
rabbitmqctl add_user roboshop roboshop123 &>>$Log_File
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$Log_File
validate $? "System user creation and giving permissions..."
else 
echo -e "User already exists $Y Skipping creation" | tee -a $Log_File
fi
