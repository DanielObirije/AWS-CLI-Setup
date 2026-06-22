# AWS CLI + Terraform S3 Infrastructure Project

## Project Title
AWS S3 Infrastructure Setup using Terraform (with IAM, CloudWatch, and CLI Practice Resources)



## Short Description

This project uses **Terraform** to automate the creation of AWS resources for learning and practicing AWS CLI.

At its core, it provisions an **S3 bucket** along with supporting resources like IAM policies, optional EC2 roles, CloudWatch logging, and sample objects inside the bucket. It’s designed as a hands-on learning setup for understanding how AWS services connect in a real-world but simple environment.


## AWS Services Used

- **Amazon S3**
  Used as the main storage service. The project creates a bucket with versioning, encryption, lifecycle rules, and public access protection enabled. It also uploads sample files for CLI practice.

- **AWS IAM (Identity and Access Management)**
  Used to create policies and optionally an EC2 role. This helps practice how permissions are attached to AWS resources securely.

- **Amazon CloudWatch**
  (Optional) Used to store logs if enabled. This helps understand basic monitoring and logging in AWS.

- **AWS STS (via data source)**
  Used to fetch account identity details for generating dynamic outputs and templates.

- **Terraform Random Provider**
  Generates a unique suffix for the S3 bucket name to avoid naming conflicts.

- **Terraform Local Provider**
  Used to generate local template files for learning and CLI practice.


##  Architecture Overview

This is a simple single-region infrastructure:

1. Terraform generates a unique S3 bucket name using a random ID.
2. An S3 bucket is created with:
   - Versioning enabled (optional toggle)
   - Server-side encryption (AES256 or KMS)
   - Public access blocked by default
   - Lifecycle rules for automatic cleanup
3. IAM policy is created to allow controlled access to the bucket.
4. (Optional) EC2 IAM role + instance profile is created and attached to the policy.
5. Sample files (JSON, text, and folder structure) are uploaded to the bucket.
6. (Optional) CloudWatch log group is created for CLI activity tracking.
7. Outputs expose important values like bucket name, ARN, and policy details.

In simple terms:

 Terraform → provisions everything  
 AWS S3 → stores files  
 IAM → controls access  
 CloudWatch → logs activity (optional)


## Setup Instructions

### 1. Install Prerequisites
Make sure you have:

- AWS CLI installed → https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html  
- Terraform installed → https://developer.hashicorp.com/terraform/downloads  
- AWS credentials configured:
```bash
aws configure