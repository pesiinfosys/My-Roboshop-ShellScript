#!/bin/bash

# Variable Declaration
LOGDIR=/tmp
DATE=$(date +%F:%H:%M)
SCRIPT=$0
LOGFILE=$LOGDIR/$SCRIPT-$DATE.log
USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# Function Declaration
VALIDATION(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 Was.... $R FAILE $N"
        exit 1
    else
        echo -e "$2 Was.... $G SUCCESS $N"
    fi
}

# Main Section
if [ $USERID -ne 0 ];
then 
    echo -e "$R FAIL $N... Need root privilages" 
    exit 1 
fi

cp mongo.repo /etc/yum.repos.d/
VALIDATION $? "Copying mongo.repo"

yum install mongodb-org -y
VALIDATION $? "install mongodb"

systemctl enable mongod
VALIDATION $? "mogod sevice enable"

systemctl start mongod
VALIDATION $? "mongod service start"

sed -i 's/127.0.0.1/0.0.0.0/g'/etc/mongod.conf
VALIDATION $? "Update listen address from 127.0.0.1 to 0.0.0.0 in /etc/mongod.conf"

systemctl restart mongod
VALIDATION $? "mongod service restart"

