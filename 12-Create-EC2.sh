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

IMAGE_ID="ami-0f3c7d07486cad139"
INSTANCE_TYPE=""
SECURITY_GROUP_ID="sg-0e9b5d0072920d28e"


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

INSTANCES=("MongoDB" "Redis" "MySQL" "RabbitMQ" "Catalogue" "Cart" "User" "Shipping" "Payment" "Dispatch" "Roboshop-WebServer")

# CONDITION: For MongoDB and MySQL instance type is t3.small and for others t2.micro
for i in ${INSTANCES[@]}
do 
    if [ [ '$i' == "MongoDB" || '$i' == "MySQL" ] ]
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi
    echo -e "Creating Instance : $B $i $N ===> Instance Type: $Y $INSTANCE_TYPE $N"
    # aws ec2 run-instances --image-id $IMAGE_ID --count 1 --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID

done
