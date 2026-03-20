#!/bin/bash
#check if root user

USER_ID=$(id -u)


Curr_Dir=$PWD
Log_Dir="/var/log/shell-catalogue/"
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

dnf module disable nodejs -y &>>$Log_File
validate $? "Disable node js.." 

dnf module enable nodejs:20 -y &>>$Log_File
validate $? "Enable nodejs 20.." 

dnf install nodejs -y &>>$Log_File
validate $? "Install nodejs.." 

app_user=$(id roboshop) &>>$Log_File

if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "System user creation..."
else 
echo -e "User already exists $Y Skipping creation" | tee -a $Log_File
fi

mkdir -p /app 
cd /app
rm -rf /app/*
validate $? "removing existing code ..."

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$Log_File
validate $? "catalogue code download.."
unzip /tmp/catalogue.zip &>>$Log_File

npm install &>>$Log_File
validate $? "Installing Dependencies..."

cp $Curr_Dir/catalogue.service /etc/systemd/system/catalogue.service
validate $? "copying catalogue.service to systemd folder..."

systemctl daemon-reload &>>$Log_File

systemctl enable catalogue &>>$Log_File
validate $? "Catalogue enable ..."
systemctl start catalogue &>>$Log_File
validate $? "Catalogue start..."

#intsall mangodb client

cp $Curr_Dir/mongodb.repo /etc/yum.repos.d/mongo.repo
validate $? "copying mongo.repo ..."

dnf install mongodb-mongosh -y &>>$Log_File
validate $? "Mongo installation..."

#SCHEMA=$(mongosh "mongodb://$Mongo_Host" --quiet --eval "db.getCollectionInfos({name: '<collectionName>'})[0].options.validator" <catalogue>)
SCHEMA_CHECK=$(mongosh "mongodb://$Mongo_Host:27017/catalogue" --quiet --eval "
  var info = db.getCollectionInfos({name: 'products'})[0];
  info && info.options ? info.options.validator : 'none'
")

echo -e " schema check vale is $SCHEMA_CHECK"
if [ $SCHEMA_CHECK -eq 'none' ]; then
mongosh --host $Mongo_Host </app/db/master-data.js &>>$Log_File
validate $? "loading Db's..."
else
echo -e "Schema is already loaded $Y SKIPPING $N" | tee -a $Log_File
fi


#mongosh --host $Mongo_Host