# bucket 생성
resource "aws_s3_bucket" "fs-back-bucket" {
  bucket = "fs-back-bucket"

  tags = {
    Name = "fs-back-bucket"
  }
}

resource "aws_s3_bucket_versioning" "fs-back-bucket" {
  bucket = aws_s3_bucket.fs-back-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

#  Amazon S3 버킷에 대한 퍼블릭 액세스 차단
resource "aws_s3_bucket_public_access_block" "fs-back-bucket" {
  bucket = aws_s3_bucket.fs-back-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# bucket 정책 설정
resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.fs-back-bucket.id

  depends_on = [
    aws_s3_bucket_public_access_block.fs-back-bucket
  ]

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "codedeploy.amazonaws.com"
        },
        "Action": "s3:Get*",
        "Resource": [
          "${aws_s3_bucket.fs-back-bucket.arn}",
          "${aws_s3_bucket.fs-back-bucket.arn}/*"
        ]
      },
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "codedeploy.amazonaws.com"
        },
        "Action": "s3:List*",
        "Resource": [
          "${aws_s3_bucket.fs-back-bucket.arn}"
        ],
        "Condition": {
          "StringEquals": {
            "s3:prefix": [
              "",
              "folder/"
            ],
            "s3:delimiter": [
              "/"
            ]
          }
        }
      }
    ]
  }
  EOF
}

output "fs-back-bucket-arn" {
  value = aws_s3_bucket.fs-back-bucket.arn
}