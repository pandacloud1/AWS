These commands can be executed using AWS CloudShell

Create an IAM role and instance profile
Create an IAM policy
aws iam create-policy --policy-name "CloudWatch-Put-Metric-Data" --policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["cloudwatch:PutMetricData"],"Resource":"*"}]}'

Create an IAM role that uses the policy document
aws iam create-role --role-name "CloudWatch-Role" --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}'

Attach the policy to the role (update policy ARN)
aws iam attach-role-policy --role-name "CloudWatch-Role" --policy-arn "<Policy-ARN>"

Create an instance profile
aws iam create-instance-profile --instance-profile-name "CloudWatch-Instance-Profile"

Add the role to the instance profile
aws iam add-role-to-instance-profile --instance-profile-name "CloudWatch-Instance-Profile" --role-name "CloudWatch-Role"

Launch an EC2 instance
Create a security group
aws ec2 create-security-group --group-name CustomMetricLab --description "Temporary SG for the Custom Metric Lab"

Add a rule for SSH inbound to the security group
aws ec2 authorize-security-group-ingress --group-name CustomMetricLab --protocol tcp --port 22 --cidr 0.0.0.0/0

Launch instance in US-EAST-1A
aws ec2 run-instances --image-id <Image-ID> --instance-type t2.micro --placement AvailabilityZone=us-east-1a --security-group-ids <SG-id> --iam-instance-profile Name="CloudWatch-Instance-Profile"

Run the remaining commands from the EC2 instance
Install stress
sudo dnf install stress-ng -y

Configure a shell script that uses the put-metric-data API
Create a shell script named mem-usage.sh
sudo nano mem-usage.sh

Add the following code and save:
#!/bin/bash

# Create a token for IMDSv2 that expires after 60 seconds
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60" -s`

# Use the token to fetch the EC2 instance ID
INSTANCE_ID=`curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id`

# Get memory usage and put metric data to CloudWatch
MEMORY_USAGE=$(free | awk '/Mem/{printf("%d", ($2-$7)/$2*100)}')
aws cloudwatch put-metric-data --region us-east-1 --namespace "Custom/Memory" --metric-name "MemUsage" --value "$MEMORY_USAGE" --unit "Percent" --dimensions "Name=InstanceId,Value=$INSTANCE_ID"
Make the script executable
sudo chmod +x mem-usage.sh

Run the following commands to install and run crontab
sudo dnf install cronie
sudo systemctl enable crond
sudo systemctl start crond
crontab -e
Then, add the following line to execute the script every minute
/home/ec2-user/mem-usage.sh
Save by typing the following and pressing enter
:wq

Run the stres utility to generate load
stress-ng --vm 15 --vm-bytes 80% --vm-method all --verify -t 60m -v

Create an alarm in CloudWatch
Create an alarm that is based on the custom metric
