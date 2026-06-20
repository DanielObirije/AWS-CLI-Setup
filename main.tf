
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "random_id" "bucket_prefix" {
 byte_length = 4
}

resource "aws_s3_bucket" "s3_cli_bucket" {
  bucket = "${var.bucket_prefix}-${random_id.bucket_prefix}"

  tags = {
    name = "aws cli setup"
    purpose ="setting up aws cli"
    managedBy = "Terraform"
    environment = var.environment
    recipe = "aws-cli-setup"
  }
}

resource "aws_s3_bucket_versioning" "s3_cli_bucket_versioning" {
  bucket = aws_s3_bucket.s3_cli_bucket.id
  versioning_configuration {
   status = "enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_cli_bucket_encription_congiguration" {
   bucket = aws_s3_bucket.s3_cli_bucket.id
   rule {
     apply_server_side_encryption_by_default {
       sse_algorithm = "AES256"
     }
     bucket_key_enabled = true
   }
}

resource "aws_s3_bucket_public_access_block" "s3_cli_public_access_config" {
  bucket = aws_s3_bucket.s3_cli_bucket.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_cli_lifecycle_config" {
  bucket = aws_s3_bucket.s3_cli_bucket.id
  rule {
    id = "cli_cleanup"
    status = "enabled"

    expiration {
      days = 7
    }

    noncurrent_version_expiration {
      noncurrent_days  = 1
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

resource "aws_iam_policy" "cli_s3_iam_policy" {
   name = "${var.iam_policy_prefix}-s3-access"
   description = "policy for s3 cli bucket"
   policy = jsondecode({
     version = "2012-10-17"
     statment = [
    {
       Effect = "Allow"
       Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketEncryption",
          "s3:GetBucketVersioning"
       ]
       Resource = aws_s3_bucket.s3_cli_bucket.id.arn
     },
     {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObjectVersion",
          "s3:GetObjectMetadata"
        ]
        Resource = "${aws_s3_bucket.s3_cli_bucket.id.arn}/*"
     }
     ]
   })

  tags = {
    name = "aws cli setup"
    purpose ="setting up aws cli"
    managedBy = "Terraform"
    environment = var.environment
    recipe = "aws-cli-setup"
  }
}

resource "aws_iam_role" "cli_ec2_role" {
  count =  var.create_ec2_role ? 1 : 0
  name = "${var.iam_role_prefix}-ec2-cli"

 assume_role_policy = jsondecode({
    Version = "2012-10-17"
    Statment = [
        {
           Effect = "Allow"
           Action = "sts:AssumeRole"
           Principal = {
               Service = "ec2.amazonaws.com"
           }
        }
    ]
    
 })

  tags = {
    name = "aws cli setup"
    purpose ="setting up aws cli"
    managedBy = "Terraform"
    environment = var.environment
    recipe = "aws-cli-setup"
  }
}

resource "aws_iam_role_policy_attachment" "ec2_cli_role_policy" {
  count = var.create_ec2_role ? 1 : 0
  role = aws_iam_role.cli_ec2_role[0].name
  policy_arn = aws_iam_policy.cli_s3_iam_policy
}

resource "aws_iam_instance_profile" "cli_ec2_profile" {
  count =  var.create_ec2_role ? 1 : 0
  name = "${var.iam_policy_prefix}-ec2-cli-profile"
  role = aws_iam_role.cli_ec2_role[0].name

  tags = {
    name = "aws cli setup"
    purpose ="setting up aws cli"
    managedBy = "Terraform"
    environment = var.environment
    recipe = "aws-cli-setup"
  }
}

resource "aws_s3_object" "sample_json_file" {
  count = var.create_simple_objects ? 1 : 0
  bucket = aws_s3_bucket.s3_cli_bucket.id
  key = "simple-files/welcom.txt"
  content = templatefile("${path.module}/templates/welcome.txt.tpl",{
    bucket_name = aws_s3_bucket.s3_cli_bucket.id
    aws_region = data.aws_region.current.name
    acccount_id = data.aws_caller_identity.current.account_id

  })
  content_type = "text/plain"
  metadata = {
    purpose = "aws cli "
    created_by = "terraform"
    recipe = "aws-cli-setup"
  }

 tags = {
    name = "aws cli setup"
    purpose ="setting up aws cli"
    managedBy = "Terraform"
    environment = var.environment
    recipe = "aws-cli-setup"
  }
}


resource "aws_s3_object" "sample_file" {
  count = var.create_simple_objects ? 1 : 0
  bucket = aws_s3_bucket.s3_cli_bucket.id
  key = "simple-files/config.json"
  content = jsonencode({
    tutoral = {
      name = "aws_cli_first_command"
      bucket_name = aws_s3_bucket.s3_cli_bucket.id
      region = data.aws_region.current.name
      version = "1.0"
    }
    commands = [
      "aws s3 ls",
      "aws s3 cp",
      "aws s3api head-bucket",
      "aws sts get-caller-identity"
    ]
  })
  content_type = "application/json"

  metadata = {
    purpose = "aws cli "
    created_by = "terraform"
    recipe = "aws-cli-setup"
  }

 tags = {
    name = "aws cli setup"
    purpose ="setting up aws cli"
    managedBy = "Terraform"
    environment = var.environment
    recipe = "aws-cli-setup"
  }
}

resource "aws_s3_object" "logs_directory" {
  count = var.create_simple_objects ? 1 : 0
  bucket = aws_s3_bucket.s3_cli_bucket.id
  key = "logs/"
  content_type = "application/x-dictionary"
 tags = {
    name = "aws cli setup"
    purpose ="setting up aws cli"
    managedBy = "Terraform"
    environment = var.environment
    recipe = "aws-cli-setup"
  }
}

resource "aws_cloudwatch_log_group" "cli_logs" {
  count = var.enable_cloudwatch_logging ? 1 : 0
  name = "/aws/cli/${random_id.bucket_prefix}"
  retention_in_days = 7
  tags = {
    name = "aws cli setup"
    purpose ="setting up aws cli"
    managedBy = "Terraform"
    environment = var.environment
    recipe = "aws-cli-setup"
  }
}

resource "local_file" "welcome_template" {
  count =  var.create_simple_objects ? 1 : 0
  filename =  "${path.module}/templates/welcom.txt.tpl"
  content = <<-EOT
    Welcome to the AWS CLI Tutorial!
    rf
    This file was created by Terraform to help you practice AWS CLI commands.

    Bucket Information:
    - Bucket Name: ${"{bucket_name}"}
    - AWS Region: ${"{aws_region}"}
    - Account ID: ${"{account_id}"}

    Practice Commands:
    1. List bucket contents: aws s3 ls s3://${"{bucket_name}"}/
    2. Copy this file: aws s3 cp s3://${"{bucket_name}"}/sample-files/welcome.txt ./
    3. Get bucket location: aws s3api get-bucket-location --bucket ${"{bucket_name}"}
    4. Check encryption: aws s3api get-bucket-encryption --bucket ${"{bucket_name}"}

    Happy learning with AWS CLI!
    Generated on: $(date)
EOT

depends_on = [ aws_s3_bucket.s3_cli_bucket ]
}