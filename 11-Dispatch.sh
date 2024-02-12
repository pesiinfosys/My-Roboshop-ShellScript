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
echo -e "Executing The Script... $Y For log verification check $LOGFILE $N"
echo -e "$B###############################################$N" > $LOGFILE
echo -e "$Y Script Execution At: $DATE by $(whoami)" &>> $LOGFILE
echo -e "$B###############################################$N" >> $LOGFILE

yum install golang -y >> $LOGFILE
VALIDATION $? "Installing golang"

# Creating System User
id -u roboshop >> $LOGFILE
if [ $? -ne 0 ];
then
    echo -e "$B Creating Sroboshop User $N" 
    useradd roboshop 
else
    echo -e "$Y User roboshop Already Exists $N"
fi >> $LOGFILE

# Creating App Directory
if [ ! -d /app ];
then
    echo -e "$B Creating /app directory $N" >> $LOGFILE
    mkdir /app
else 
    echo -e "$Y directory /app already exists" >> $LOGFILE
fi >> $LOGFILE

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip
VALIDATION $? "Downloading Application Code"

cd /app 
unzip /tmp/dispatch.zip
VALIDATION $? "Extracting Application Code"

go mod init dispatch
go get 
VALIDATION $? "Installing Dependencies"

go build
VALIDATION $? "Building The Application"

cd -
cp dispatch.service /etc/systemd/system/dispatch.service

systemctl daemon-reload
VALIDATION $? "Load The service"

systemctl enable dispatch 
VALIDATION $? "Enabling The service"

systemctl start dispatch
VALIDATION $? "Starting The service"