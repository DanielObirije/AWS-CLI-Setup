

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
    name = "cli s3 policy"
    purpose = "adding correct s3 polity"
    recipe = "aws-cli-setup"
     manageBy ="terraform"
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
    name = "cli s3 role"
    purpose = "adding correct s3 role"
    recipe = "aws-cli-setup"
     manageBy ="terraform"
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
      name = "ec2 cli profile"
      purpose = "adding profile for ec2 cli"
      recipe = "aws-cli-setup"
      manageBy ="terraform"
    }
}

