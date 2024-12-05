## =====================
## TERRAFORM CODE
## =====================
# (NOTE: Save the file with extension '.tf')

# STEP1: DEFINE AWS VERSION
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.52.0"
    }
  }
}

# STEP2: DEFINE AWS REGION
provider "aws" {
  region = "us-east-1"
}

# STEP3: CREATE EC2 INSTANCE
resource "aws_instance" "My_Server" {
  ami           = "ami-0d191299f2822b1fa"
  instance_type = "t2.micro"

  tags = {
    Name = "My_Server"
  }
}

## =====================
## TERRAFORM COMMANDS
## =====================
# To initialize & download provider plugin
terraform init

# To see what is planned to be created
terraform plan

# To create resources
terraform apply

# To delete resources
terraform destroy
