#!/bin/bash
#check if root user

USER_ID=$(id -u)


Curr_Dir=$PWD
Log_Dir="/var/log/shell-shipping/"
mkdir -p $Log_Dir
Log_File="$Log_Dir/$0.log"
MYSQL_HOST=mysql.anildevops.online

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

dnf install maven -y &>>$Log_File
validate $? "maven installation.."

id roboshop &>>$Log_File

if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "System user creation..."
else 
echo -e "User already exists $Y Skipping creation $N" | tee -a $Log_File
fi

mkdir -p /app 
cd /app
rm -rf /app/*
validate $? "removing existing code ..."

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$Log_File
validate $? "shipping code download.."
unzip /tmp/shipping.zip &>>$Log_File

mvn clean package &>>$Log_File
validate $? "dependencies installation..."
mv target/shipping-1.0.jar shipping.jar 
validate $? "moving shipping.jar to current working directory..."


cp $Curr_Dir/shipping.service /etc/systemd/system/shipping.service
validate $? "copying shipping.service to systemd folder..."

systemctl daemon-reload &>>$Log_File


dnf install mysql -y &>>$Log_File
validate $? "mysql installation ..."

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'
if [ $? -ne 0 ]; then
mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql
mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql
mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql
validate $? "SQL Data loading"
else 
echo -e "data is already loaded ... $Y SKIPPING $N"
fi

systemctl enable shipping &>>$Log_File
systemctl start shipping &>>$Log_File
validate $? "enable and start shipping ..."