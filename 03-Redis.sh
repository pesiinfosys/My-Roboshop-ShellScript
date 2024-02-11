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

yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y >> $LOGFILE
VALIDATION $? "Installing Redis repo"

yum module enable redis:remi-6.2 -y >> $LOGFILE
VALIDATION $? "Enabling Redis Package"

yum install redis -y  >> $LOGFILE
VALIDATION $? "Installing Redis"

# Update listen address from 127.0.0.1 to 0.0.0.0 in /etc/redis.conf & /etc/redis/redis.conf
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf
VALIDATION $? "Update listen address in /etc/redis.conf"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
VALIDATION $? "Update listen address /etc/redis/redis.conf"

systemctl enable redis
VALIDATION $? "enable redis service"

systemctl start redis
VALIDATION $? "starting redis service"

