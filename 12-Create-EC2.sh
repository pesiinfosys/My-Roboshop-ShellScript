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
HOSTED_ZONE_ID="Z050078223X0WDORRWD3F"
DOMAIN_NAME="cloudevops.cloud"


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

INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "cart" "user" "shipping" "payment" "dispatch" "web")

# CONDITION: For MongoDB and MySQL instance type is t3.small and for others t2.micro
for i in ${INSTANCES[@]}
do 
    if [[ $i == "MongoDB" || $i == "MySQL" ]]
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi
    echo -e "Creating Instance : $B $i $N ===> Instance Type: $Y $INSTANCE_TYPE $N" &>> $LOGFILE
    PRIVATE_IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID --count 1 --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress') &>> $LOGFILE
    VALIDATION $? "Creating Instance $i"
    echo -e "$B ============================================================================ $N" &>> $LOGFILE
    
    # Creating AWS Route53 Records
    aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch '{
                "Comment": "CREATE a record ",
                "Changes": [{
                "Action": "CREATE",
                            "ResourceRecordSet": {
                                        "Name": "'$i.$DOMAIN_NAME'",
                                        "Type": "A",
                                        "TTL": 300,
                                    "ResourceRecords": [{ "Value": "'$PRIVATE_IP_ADDRESS'"}]
    }}]
    }'

done

