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

yum install maven -y >> $LOGFILE
VALIDATION $? "maven installation"

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip >> $LOGFILE
VALIDATION $? "downloading application code"

cd /app
unzip /tmp/shipping.zip >> $LOGFILE
VALIDATION $? "extracting application code"

mvn clean package >> $LOGFILE
VALIDATION $? "application build"

mv target/shipping-1.0.jar shipping.jar >> $LOGFILE
VALIDATION $? "renaming package"

# Set-up Shipping service
cd -
cp shipping.service /etc/systemd/system/shipping.service >> $LOGFILE
VALIDATION $? "copying service file"

systemctl daemon-reload
VALIDATION $? "loading shipping service"

systemctl enable shipping 
VALIDATION $? "enabling shipping service"

systemctl start shipping
VALIDATION $? "starting shipping service"

yum install mysql -y >> $LOGFILE 
VALIDATION $? "Installing mysql client"

mysql -h mysql.cloudevops.cloud -uroot -pRoboShop@1 < /app/schema/shipping.sql >> $LOGFILE 
VALIDATION $? "Loading Schema"

systemctl restart shipping
VALIDATION $? "restarting shipping service"