data "aws_caller_identity" "current" {}
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  force_destroy = false     # 버킷 비우기 없이 삭제 방지

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "bucket" { # 퍼블릭 액세스(즉, 누구나 접근 가능하게 만드는 설정)를 막기 위한 보안 장치
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = false  # 버킷 정책은 허용해야 하므로 false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket      = aws_s3_bucket.bucket.id
  depends_on  = [aws_s3_bucket_public_access_block.bucket]

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowPublicReadProfileFolder",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.bucket.arn}/profile/*"
      },
      {
        Sid       = "AllowPublicReadFileFolder",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.bucket.arn}/file/*"
      },
      {
        Sid       = "AllowReadPiiLogsFolder",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.bucket.arn}/pii-logs/*"
      },
      {
        Sid       = "AllowReadResumesFolder",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.bucket.arn}/resumes/*"
      },
      {
        Sid       = "AllowReadDocumentsFolderRecursive",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.bucket.arn}/documents/*",
      },
      {
        Sid       = "AllowReadDocumentsSubfolders",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.bucket.arn}/documents/*/*"
      },
      {
        Sid       = "AllowReadFrontBuildsFolder",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.bucket.arn}/jemyeonso-front-builds/*"
      },
      {
        Sid       = "AllowReadDBFolder",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.bucket.arn}/db/*"
      },
      {
        Sid       = "AllowELBLogPut",
        Effect    = "Allow",
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.bucket.arn}/alb-logs/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      },
      {
        Sid       = "AllowELBGetAcl",
        Effect    = "Allow",
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        },
        Action   = "s3:GetBucketAcl",
        Resource = aws_s3_bucket.bucket.arn
      }
    ]
  })
}

resource "aws_s3_bucket_cors_configuration" "bucket_cors" {
  bucket = aws_s3_bucket.bucket.bucket  # 이미 정의된 S3 버킷 이름을 참조

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT"]
    allowed_origins = [
      "http://localhost:5173",
      "https://jemyeonso.com",
    ]
    expose_headers = ["ETag"]
    max_age_seconds = 3000
  }
}

