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

yum module disable mysql -y >> $LOGFILE
VALIDATION $? "disable existing mysql"

cp mysql.repo /etc/yum.repos.d/mysql.repo >> $LOGFILE
VALIDATION $? "copying mysql repo file"

yum install mysql-community-server -y >> $LOGFILE
VALIDATION $? "Installing mysql"

systemctl enable mysqld
VALIDATION $? "Enable mysql"

systemctl start mysqld
VALIDATION $? "Starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1 >> $LOGFILE
VALIDATION $? "Changing default password to RoboShop@1"

