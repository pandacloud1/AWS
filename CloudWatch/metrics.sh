#!/bin/bash

# Create a token for IMDSv2 that expires after 60 seconds
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60" -s`

# Use the token to fetch the EC2 instance ID
INSTANCE_ID=`curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id`

# Get memory usage and put metric data to CloudWatch
MEMORY_USAGE=$(free | awk '/Mem/{printf("%d", ($2-$7)/$2*100)}')
aws cloudwatch put-metric-data --region us-east-1 --namespace "Custom/Memory" --metric-name "MemUsage" --value "$MEMORY_USAGE" --unit "Percent" --dimensions "Name=InstanceId,Value=$INSTANCE_ID"


# Make the metrics.sh file executable by running below command
# sudo chmod +x metrics.sh
