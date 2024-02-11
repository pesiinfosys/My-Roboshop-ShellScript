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

curl -sL https://rpm.nodesource.com/setup_lts.x | bash >> $LOGFILE
VALIDATION $? "Set-Up Nodejs repo"

yum install nodejs -y >> $LOGFILE
VALIDATION $? "Install Nodejs"

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
    echo -e "$B Creating /app directory $N"
    mkdir /app
else 
    echo -e "$Y directory /app already exists"
fi >> $LOGFILE

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip  >> $LOGFILE
VALIDATION $? "Downloading Apllication Code"

cd /app
unzip /tmp/user.zip  >> $LOGFILE
VALIDATION $? "Extracting user.zip"

npm install  >> $LOGFILE
VALIDATION $? "Installing Dependencies"

# Creating User service
cd -
cp user.service /etc/systemd/system/user.service >> $LOGFILE
VALIDATION $? "Copying user.service file"

systemctl daemon-reload >> $LOGFILE
VALIDATION $? "loading services"

systemctl enable user >> $LOGFILE 
VALIDATION $? "Enable User Service"

systemctl start user >> $LOGFILE 
VALIDATION $? "Starting User Service"

# Installing MongoDB Client
cp mongo.repo /etc/yum.repos.d/mongo.repo >> $LOGFILE
VALIDATION $? "Copying mongo.rep file was"

yum install mongodb-org-shell -y >> $LOGFILE
VALIDATION $? "mongodb client installation"

mongo --host mongodb.cloudevops.cloud < /app/schema/user.js >> $LOGFILE
VALIDATION $? "Loading Schema into MongoDB"

