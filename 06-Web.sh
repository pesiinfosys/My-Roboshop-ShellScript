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

yum install nginx -y
VALIDATION $? "Installing Nginx Was"

systemctl enable nginx
VALIDATION $? " Enabling Nginx service Was"

systemctl start nginx
VALIDATION $? "Starting Nginx Service was"

rm -rf /usr/share/nginx/html/*
VALIDATION $? "Removing Default content was"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip
VALIDATION $? "Downloading Web content was"

cd /usr/share/nginx/html
unzip /tmp/web.zip
VALIDATION $? "Extract the frontend content was"

# Setting-Up Nginx Reverse Proxy Configuration
touch /etc/nginx/default.d/roboshop.conf
VALIDATION $? "Creating roboshop.conf file was"

cd -
cp roboshop.conf /etc/nginx/default.d/roboshop.conf
VALIDATION $? "Copying roboshop.conf file was" 



