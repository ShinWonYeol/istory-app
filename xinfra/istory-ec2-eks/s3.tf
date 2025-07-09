# 운영용 S3 버킷
resource "aws_s3_bucket" "istory-prod-deploy-bucket" {
  bucket = "istory-prod-deploy-bucket-${data.aws_caller_identity.current.account_id}"
  tags = {
    Name        = "istory-deploy-prod"
    Environment = "Production"
  }
}

# 운영용 버킷 버전 관리
resource "aws_s3_bucket_versioning" "prod_deploy_bucket_versioning" {
  bucket = aws_s3_bucket.istory-prod-deploy-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 운영용 버킷 서버사이드 암호화
resource "aws_s3_bucket_server_side_encryption_configuration" "prod_bucket_encryption" {
  bucket = aws_s3_bucket.istory-prod-deploy-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 운영용 버킷 퍼블릭 액세스 차단
resource "aws_s3_bucket_public_access_block" "prod_bucket_access" {
  bucket = aws_s3_bucket.istory-prod-deploy-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "prod_deploy_bucket_name" {
  value       = aws_s3_bucket.istory-prod-deploy-bucket.id
  description = "Name of the production deployment S3 bucket"
}
