#!/bin/bash 

AMI_ID=ami-0220d79f3f480ecf5
SG_ID=sg-0e8969e6e41d87dbb
HOST_ZONE_ID=Z0865515W1UBV3KOHFVD
DNS_NAME=anildevops.online

validate()
{
    if [ $1 -ne 0 ]; then
     echo -e "$2 $R FAILURE $N" 
     exit 1
    else 
    echo -e "$2 $G SUCCESS $N"
    fi

}

for instance in $@
do
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --security-group-ids $SG_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$instance'}]' \
    --query 'Instances[0].InstanceId' \
    --output text)
validate $? "$INSTANCE_ID Instance generation"    

INSTANCE_NAME=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value[]' --output text)
validate $? "$INSTANCE_NAME is the Instance Name"

if [ $INSTANCE_NAME == 'frontend']; then
 IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
 validate $? "$IP is the Private IP"
else
 IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
 validate $? "$IP is the public IP"
fi

aws route53 change-resource-record-sets --hosted-zone-id $HOST_ZONE_ID \
 --change-batch '
 {
        "Comment": "Updating record",
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                {
                    "Value": "'$IP'"
                }
                ]
            }
            }
        ]
    }'
  

validate $? "A records Update is"

done

