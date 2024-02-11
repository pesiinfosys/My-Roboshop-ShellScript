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

yum install nginx -y >> $LOGFILE
VALIDATION $? "Installing Nginx Was"

systemctl enable nginx >> $LOGFILE
VALIDATION $? " Enabling Nginx service Was"

systemctl start nginx >> $LOGFILE
VALIDATION $? "Starting Nginx Service was"

rm -rf /usr/share/nginx/html/* >> $LOGFILE
VALIDATION $? "Removing Default content was"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip >> $LOGFILE
VALIDATION $? "Downloading Web content was"

cd /usr/share/nginx/html
unzip /tmp/web.zip >> $LOGFILE
VALIDATION $? "Extract the frontend content was"

# Setting-Up Nginx Reverse Proxy Configuration
touch /etc/nginx/default.d/roboshop.conf >> $LOGFILE
VALIDATION $? "Creating roboshop.conf file was"

cd -
cp roboshop.conf /etc/nginx/default.d/roboshop.conf >> $LOGFILE
VALIDATION $? "Copying roboshop.conf file was" 



