

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