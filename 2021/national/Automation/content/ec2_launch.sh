#!/bin/bash
if [ -z "$1" ]; then
    echo "No argument supplied"
else
    instance_id=$(aws ec2 run-instances --image-id ${image_id} --count 1 --instance-type t3.small --key-name ${key_name} --security-group-ids ${security_group_id} --subnet-id ${subnet_id} --iam-instance-profile Name=${iam_role_name} --user-data file:///opt/user_data.sh --query 'Instances[0].InstanceId' --output text)
    aws ec2 create-tags --resources $instance_id --tags Key=Name,Value=$1 Key=wsi:deploy:group,Value=dev-api
fi