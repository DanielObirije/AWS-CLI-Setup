variable "bucket_prefix" {
  description = "prefix for s3 bucket name to ensure uniqueness"
  type = string
  default = "aws-cli-bucket"

  validation {
    condition = can(regex("^[a-z0-9]([a-z0-9-]{1,61}[a-z0-9])?$",var.bucket_prefix))
    error_message = "Bucket name must be 3–63 characters, lowercase letters and numbers only, may include hyphens, and cannot start or end with a hyphen."
  }
}

variable "environment" {
  description = "environment name (eg..staging, dev, prod)"
  type = string
  default = "cli-environment"

  validation {
   condition     = can(regex("^[a-zA-Z0-9-]{1,20}$", var.environment))
    error_message = "Environment must be alphanumeric with hyphens, maximum 20 characters."
  }
}

variable "iam_policy_prefix" {
  description = "prefix for iam policy"
  type = string
  default = "cli-policy"

  validation {
    condition = can(regex("^[a-zA-Z0-9-]{1,50}$", var.iam_policy_prefix))
    error_message = "IAM policy prefix must be alphanumeric with hyphens, maximum 50 characters."
  }
}

variable "iam_role_prefix" {
  description = "prefix for iam role"
  type = string
  default = "cli-role"

  validation {
    condition = can(regex("^[a-zA-Z0-9-]{1,50}$", var.iam_role_prefix))
    error_message = "IAM role prefix must be alphanumeric with hyphens, maximum 50 characters."
  }
}

variable "create_ec2_role" {
  description = "create role for ec2 instance"
  type = bool
  default = false
}

variable "create_simple_objects" {
  description = "create an s3 bucket"
  type =  bool
  default = true
}

variable "enable_cloudwatch_logging" {
  description = "enable cloud watching monitoring for cli activities"
  type = bool
  default = false
}

variable "bucket_lifycycle_days" {
  description = "Number of days before  bucket is deleted"
  type = number
  default = 7

  validation {
    condition = var.bucket_lifycycle_days >= 1 && var.bucket_lifycycle_days <= 365
    error_message = "bucket life cicle days must be between 1 to 365 days"
  }
}

variable "cloudwatch_logs_retention_days" {
   description = "Number of days before cloudwatch logs is deleted"
   type = number
   default =  7

   validation {
     condition = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365], var.cloudwatch_logs_retention_days)
     error_message = "cloudwatch retention period must be included in one of these days: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365"
   }
}

variable "enable_s3_versioning" {
  description = "enable s3 versioning for s3 bucket"
  type = bool
  default = true
}

variable "enable_bucket_encription" {
  description = "enable encription for s3 bucket"
  type = bool
  default = true
}

variable "encription_algorithm" {
  description = "enable encription algorithm"
  type =  string
  default = "AES256"

  validation {
    condition = contains(["AES256","aws:kms"], var.encription_algorithm)
    error_message = "encription must be  either AES256 or aws:kms"
  }
}

variable "kms_key_id" {
  description = "KMS key ID for S3 bucket encryption (only used if encryption_algorithm is 'aws:kms')"
  type = string
  default = null
}

variable "enable_public_access_block" {
  description = "block public access to s3 bucket"
  type = bool
  default = true
}

variable "tags" {
  description = "tags to apply to all resources"
  type = map(string)
  default = {}
  validation {
    condition = length(var.tags) <= 10
    error_message = "can not add more than 10 tags"
  }
}

variable "aws_region" {
  description = "aws region for resource"
  type = string
  default = null

    validation {
    condition = var.aws_region == null || can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in the format 'us-east-1', 'eu-west-1', etc."
  }
  
}

variable "bucket_force_destory" {
  description = "force destory s3 bucket even if it contains objects"
  type = bool
  default = false
}

variable "create_bucket_dirictories" {
  description = "create direcotry structure in s3"
  type = string
  default = "text/plain"

  validation {
    condition = can(regex("^[a-z]+/[a-z]+$", var.create_bucket_dirictories))
    error_message = "bucket directory must be in this format 'text/plain"
  }
}