#!/bin/bash

# Variable Declaration
LOGDIR=/tmp
DATE=$(date +%F::%H:%M)
SCRIPT=$0
LOGFILE=$LOGDIR/$SCRIPT-$DATE.log
USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

# Function Declaration
VALIDATION(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 Was.... $R FAIL $N"
        exit 1
    else
        echo -e "$2 Was.... $G SUCCESS $N"
    fi
}

# Main Section
if [ $USERID -ne 0 ];
then 
    echo -e "$Y ERROR:$N... Need root privilages" 
    exit 1 
fi

echo -e "$B###############################################$N" > $LOGFILE
echo -e "$Y Script Execution At: $DATE by $(whoami)" &>> $LOGFILE
echo -e "$B###############################################$N" >> $LOGFILE

curl -sL https://rpm.nodesource.com/setup_lts.x | bash >> $LOGFILE
VALIDATION $? "Downloading Node Repo"

yum install nodejs -y >> $LOGFILE
VALIDATION $? "Installing Nodejs"
# creating system user roboshop
USER=$(id -u roboshop)
if [ $USER -ne 0 ];
then
    echo "$B creating roboshop userv $N" >> $LOGFILE
    useradd roboshop
else
    echo "$Y roboshop user exists $N" >> $LOGFILE
fi

# creating app directory
if [ ! -d /app ];
then
    echo "$B Creating app directory $N" >> $LOGFILE
    mkdir /app
else
    echo "$Y /app directory exists $N" >> $LOGFILE
fi

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip >> $LOGFILE
VALIDATION $? "Download the application code"

cd /app 
unzip /tmp/catalogue.zip >> $LOGFILE
VALIDATION $? "UNZIP of catalogue.zip"
ls -ltr /app

# downloading dependencies
npm install >> $LOGFILE/home/centos/My-Roboshop-ShellScript
VALIDATION $? "Downloading Dependencies Using npm install"

cd -
# Setting UP Catalogue Service
cp catalogue.service /etc/systemd/system/catalogue.service
VALIDATION $? "Copying catalogue.service file"

systemctl daemon-reload >> $LOGFILE
VALIDATION $? "load Services"

systemctl enable catalogue >> $LOGFILE
VALIDATION $? "Enable Catalogue Service"

systemctl start catalogue >> $LOGFILE
VALIDATION $? "Start Catalogue Service"

# Installing mongodb-client
cp mongo.rep /etc/yum.repos.d/mongo.repo >> $LOGFILE
VALIDATION $? "copying mongo.rep file"

yum install mongodb-org-shell -y >> $LOGFILE
VALIDATION $? "Installing mongodb client"

# Load schema
mongo --host mongodb.cloudevops.cloud < /app/schema/catalogue.js >> $LOGFILE
VALIDATION $? "Loading Schema to MongoDB sever"