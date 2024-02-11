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
        echo -e "$2 Was.... $R FAILE $N"
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

cp mongo.repo /etc/yum.repos.d/ &>> $LOGFILE
VALIDATION $? "Copying mongo.repo"

yum install mongodb-org -y &>> $LOGFILE
VALIDATION $? "install mongodb"

systemctl enable mongod &>> $LOGFILE
VALIDATION $? "mogod sevice enable"

systemctl start mongod &>> $LOGFILE
VALIDATION $? "mongod service start"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>> $LOGFILE
VALIDATION $? "Update listen address from 127.0.0.1 to 0.0.0.0 in /etc/mongod.conf"

systemctl restart mongod  &>> $LOGFILE
VALIDATION $? "mongod service restart"

