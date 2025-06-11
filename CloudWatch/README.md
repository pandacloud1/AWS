# Custom CloudWatch Metric Monitoring using EC2

This guide walks through setting up a custom memory metric on an EC2 instance and monitoring it with Amazon CloudWatch.

> **Note**: These commands can be executed directly from **AWS CloudShell**.

---

## 🚀 Step 1: Create IAM Role and Instance Profile

### ✅ Create an IAM Policy

```bash
aws iam create-policy --policy-name "CloudWatch-Put-Metric-Data" --policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["cloudwatch:PutMetricData"],"Resource":"*"}]}'
```

### ✅ Create an IAM Role

```bash
aws iam create-role --role-name "CloudWatch-Role" --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}'
```

### ✅ Attach the Policy to the Role

> ⚠️ Replace `<POLICY_ARN>` with the actual ARN of the policy created above.

```bash
aws iam attach-role-policy --role-name "CloudWatch-Role" --policy-arn <POLICY_ARN>
```

### ✅ Create an Instance Profile

```bash
aws iam create-instance-profile --instance-profile-name "CloudWatch-Instance-Profile"
```

### ✅ Add Role to Instance Profile

```bash
aws iam add-role-to-instance-profile --instance-profile-name "CloudWatch-Instance-Profile" --role-name "CloudWatch-Role"
```

---

## 💻 Step 2: Launch an EC2 Instance

### ✅ Create a Security Group

```bash
aws ec2 create-security-group --group-name CustomMetricLab --description "Temporary SG for the Custom Metric Lab"
```

### ✅ Allow SSH Access

```bash
aws ec2 authorize-security-group-ingress --group-name CustomMetricLab --protocol tcp --port 22 --cidr 0.0.0.0/0
```

### ✅ Launch EC2 Instance (in `us-east-1a`)

> ⚠️ Replace `<IMAGE_ID>` and `<SECURITY_GROUP_ID>` with actual values.

```bash
aws ec2 run-instances --image-id <IMAGE_ID> --instance-type t2.micro --placement AvailabilityZone=us-east-1a --security-group-ids <SECURITY_GROUP_ID> --iam-instance-profile Name="CloudWatch-Instance-Profile"
```

---

## 🛠️ Step 3: Configure EC2 Instance

### ✅ Install `stress-ng`

```bash
sudo dnf install stress-ng -y
```

---

## 📊 Step 4: Create a Custom Metric Script

### ✅ Create the Shell Script

```bash
sudo nano mem-usage.sh
```

### ✅ Script Content

```bash
#!/bin/bash

# Create a token for IMDSv2
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token"   -H "X-aws-ec2-metadata-token-ttl-seconds: 60" -s)

# Get EC2 instance ID
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN"   -s http://169.254.169.254/latest/meta-data/instance-id)

# Calculate memory usage
MEMORY_USAGE=$(free | awk '/Mem/{printf("%d", ($2-$7)/$2*100)}')

# Push custom metric to CloudWatch
aws cloudwatch put-metric-data   --region us-east-1   --namespace "Custom/Memory"   --metric-name "MemUsage"   --value "$MEMORY_USAGE"   --unit "Percent"   --dimensions "Name=InstanceId,Value=$INSTANCE_ID"
```

### ✅ Make the Script Executable

```bash
sudo chmod +x mem-usage.sh
```

---

## ⏱️ Step 5: Schedule the Script via Crontab

### ✅ Install and Start Crond

```bash
sudo dnf install cronie
sudo systemctl enable crond
sudo systemctl start crond
```

### ✅ Edit Crontab

```bash
crontab -e
```

### ✅ Add the Line Below

```cron
* * * * * /home/ec2-user/mem-usage.sh
```

Then save with `:wq`.

---

## 🔥 Step 6: Generate Load Using `stress-ng`

```bash
stress-ng --vm 15 --vm-bytes 80% --vm-method all --verify -t 60m -v
```

---

## 📈 Step 7: Create CloudWatch Alarm

Use the AWS Console or CLI to create an alarm for the custom metric `MemUsage` under namespace `Custom/Memory`.

---

## ✅ Done!

You now have a fully working custom CloudWatch metric setup using an EC2 instance.