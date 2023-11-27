# bucket 생성
resource "aws_s3_bucket" "fs-front-bucket" {
  bucket = "fs-front-bucket"
  tags = {
    Name = "fs-front-bucket"
  }
}

# 정적 웹 사이트의 기본 index 페이지에 연결
resource "aws_s3_bucket_website_configuration" "fs-front-bucket" {
  bucket = aws_s3_bucket.fs-front-bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "fs-front-bucket" {
  bucket = aws_s3_bucket.fs-front-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Amazon S3 버킷 소유권 컨트롤을 정의
resource "aws_s3_bucket_ownership_controls" "fs-front-bucket" {
  bucket = aws_s3_bucket.fs-front-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

#  Amazon S3 버킷에 대한 퍼블릭 액세스 허용
resource "aws_s3_bucket_public_access_block" "fs-front-bucket" {
  bucket = aws_s3_bucket.fs-front-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# ACL 공개 읽기 권한 설정 -정적 웹 호스팅을 위해
resource "aws_s3_bucket_acl" "fs-front-bucket" {
   depends_on = [  
    aws_s3_bucket_ownership_controls.fs-front-bucket,  
    aws_s3_bucket_public_access_block.fs-front-bucket
   ]
  
  bucket = aws_s3_bucket.fs-front-bucket.id
  acl = "public-read"
}

output "fs-front-bucket-url" {
  value = aws_s3_bucket.fs-front-bucket.website_endpoint
}