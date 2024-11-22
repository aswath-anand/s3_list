# AWS Flask Application with S3 Bucket Integration

This project deploys a Flask web application on an AWS EC2 instance. The application interacts with an S3 bucket to list its contents via a REST API. The infrastructure is provisioned using Terraform.

---

## Features

- **Infrastructure as Code (IaC)**: Terraform is used to create and manage AWS resources.
- **Flask Application**: A Python web app that lists contents of an S3 bucket using Boto3.
- **AWS S3 Integration**: Dynamically fetches bucket directories and files via REST API endpoints.
- **Secure Deployment**: Utilizes SSH and security groups for secure access.

---

## Prerequisites

1. **AWS Account** with programmatic access enabled.
2. **AWS CLI** configured with a profile (`default`) for the desired region.
3. **Terraform** installed on your local machine.
4. **Python** (with Flask and Boto3 installed) for development/testing the app locally.
5. **SSH Key Pair**:
    - Create an SSH key pair named `s3-instance-RSA` in AWS or locally.
    - Place the private key (`s3-instance-RSA.pem`) in the project directory.

---

## Steps to Deploy

### 1. Clone the Repository
```bash
git clone <repository_url>
cd <repository_name>
