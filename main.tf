provider "aws" {
  region  = "ap-southeast-1"
  profile = "default"  # Ensure that the AWS CLI profile used matches the one in the credentials file
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Create a public subnet in the VPC
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true
}

# Create an S3 bucket (must be globally unique)
resource "aws_s3_bucket" "my_bucket" {
  bucket = "s3-list-flask-app"  # Use a globally unique bucket name
}

# Create an EC2 security group in the VPC
resource "aws_security_group" "my_security_group" {
  vpc_id      = aws_vpc.my_vpc.id
  name_prefix = "flask-sg-"
  description = "Allow SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 instance (VM) in the created VPC and subnet
resource "aws_instance" "my_ec2" {
  ami                    = "ami-07c9c7aaab42cba5a"  # Replace with your chosen ec2-user AMI ID
  instance_type          = "t2.micro"
  key_name               = "s3-instance-RSA"
  subnet_id             = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  associate_public_ip_address = true

  # User Data to install Python, Flask, and start the Flask app on ec2-user
  user_data = <<-EOF
             #!/bin/bash
              # Update the system and install Python 3 and pip
              sudo yum update -y
              sudo yum install -y python3 python3-pip

              # Install Flask and Boto3
              sudo pip3 install flask boto3

              # Start Flask app in the background
              cd /home/ec2-user/flask_app
              nohup python3 app.py > /home/ec2-user/flask_app/app.log 2>&1 &
              EOF

  # Provisioning the Flask app (Copying the app.py file)
  provisioner "file" {
    source      = "./s3_app_list.py"   # The local Flask app file on your machine
    destination = "/home/ec2-user/flask_app/app.py"  # Where to copy the file on the EC2 instance

    # Connection configuration to use SSH
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("./s3-instance-RSA.pem")  # Use the correct path to your private key
      host        = self.public_ip  # Use the public IP of the EC2 instance
    }
  }

  tags = {
    Name = "MyFlaskAppInstance"
  }
}

# Output the EC2 public IP
output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.my_ec2.public_ip
}

# Output the S3 bucket name
output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.my_bucket.bucket
}
