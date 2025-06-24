#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0004821aded493804"
INSTANCES=("mongodb" "mysql" "rabbitmq" "redis" "catalogue" "user" "cart" "shipping" "pyement" "dispatch" "frontend")
ZONE_ID="Z08241221PV7NRI1REOJQ"
DOMAIN_NAME="ranjithdaws.site"


#for instance in ${INSTANCES[@]}

for instance in $@
do  
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-0004821aded493804 --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
if [ $instance != "frontend" ] 
    then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME"
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
        RECORD_NAME="$DOMAIN_NAME"
     fi
        echo "$instance IP Address: $IP"    

      aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating or Updating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$RECORD_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP'"
            }]
        }
        }]
    }'
done  

