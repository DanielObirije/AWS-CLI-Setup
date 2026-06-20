
# S3 Bucket Information
output "s3_bucket_name" {
  description = "Name of the s3 bucket create for cli"
  value = aws_s3_bucket.s3_cli_bucket
}

output "s3_bucket_arn" {
  description = "Arn for s3 bucket"
  value = aws_s3_bucket.s3_cli_bucket.arn
}

output "s3_bucket_region" {
  description = "s3 bucket region"
  value = aws_s3_bucket.s3_cli_bucket.region
}

output "s3_bucket_domain_name" {
  description = "s3 bucket domain name"
  value = aws_s3_bucket.s3_cli_bucket.bucket_domain_name
}

output "s3_bucket_hosted_zone_id" {
  description = "s3 bucket hosted_zone_id"
  value = aws_s3_bucket.s3_cli_bucket.hosted_zone_id
}


# IAM Policy Information
output "s3_access_policy_arn" {
  description = "Arn of the iam role for s3 access "
  value = aws_iam_policy.cli_s3_iam_policy.arn
}

output "s3_access_policy_name" {
  description = "Name of the iam policy for s3 access "
  value = aws_iam_policy.cli_s3_iam_policy.name
}


# IAM Role Information if(created)
output "ec2_role_arn" {
  description = "Arn of instance profile for EC2 (if created)"
  value = var.create_ec2_role ? aws_iam_role.cli_ec2_role[0].arn : null
}

output "ec2_role_name" {
  description = "Name of instance profile for EC2 (if created)"
  value = var.create_ec2_role ? aws_iam_role.cli_ec2_role[0].name : null
}

output "ec2_instance_profile_name" {
  description = "Name of the instance profile for EC2 (if created)"
  value = var.create_ec2_role  ? aws_iam_instance_profile.cli_ec2_profile.name[0]: null
}


# CloudWatch Log Group Information (if created)
output "cloudwatch_log_group_name" {
  description = "Name of the cloud watch group (if created)"
  value =  var.enable_cloudwatch_logging ?  aws_cloudwatch_log_group.cli_logs[0].name : null
}

output "cloudwatch_log_group_arn" {
  description = "Arn of the cloud watch group (if created)"
  value =  var.enable_cloudwatch_logging ?  aws_cloudwatch_log_group.cli_logs[0].arn : null
}

output "simple_objects" {
  description = "list of objects created in s3 bucket"
  value = var.create_simple_objects ? {
    welcome_file = aws_s3_object.sample_file[0].key
    config_file = aws_s3_object.sample_json_file[0].key
    logs_dir = aws_s3_object.logs_directory[0].key
  } : {}
}


# Aws Account and Region information

output "aws_account_id" {
  description = "AWS Account ID where resources were created"
  value =  data.aws_caller_identity.current.id
}


output "aws_account_region" {
  description = "AWS Account region where resources were created"
  value =  data.aws_region.current.id
}

