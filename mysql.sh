#!/bin/bash
#check if root user

USER_ID=$(id -u)


Curr_Dir=$PWD
Log_Dir="/var/log/shell-shipping/"
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


if [ $USER_ID -ne 0 ]; then
echo -e "$R Please execute the script with sudo access $N" | tee -a $Log_File
exit 1
fi

dnf install mysql-server -y &>>$Log_File
validate $? "MYSQL Installation.."

systemctl enable mysqld &>>$Log_File
validate $? "MYSQL enable.."
systemctl start mysqld &>>$Log_File
validate $? "MYSQL Start.."

mysql_secure_installation --set-root-pass RoboShop@1
validate $? "MYSQL password setup.."