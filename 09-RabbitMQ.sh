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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash
VALIDATION $? "Configuring yum repo from shell script provided by vendor"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash
VALIDATION $? "Configuring yum repo for rabbitmq"

yum install rabbitmq-server -y 
VALIDATION $? "Installing Rabbit MQ"

systemctl enable rabbitmq-server 
VALIDATION $? "Enable RabbitMQ Service"

systemctl start rabbitmq-server 
VALIDATION $? "Starting RabbitMQ Service"

rabbitmqctl add_user roboshop roboshop123
VALIDATION $? "Creating roboshop user for RabbitMQ"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATION $? "Set-up Permissions for roboshop user"