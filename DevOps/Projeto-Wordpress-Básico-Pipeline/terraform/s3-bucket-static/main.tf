provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "static-site"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

resource "aws_s3_bucket" "static_site" {
  bucket = "static-site-${var.bucket_name}"
}

resource "aws_s3_bucket" "logs" {
  bucket = "static-site-${var.bucket_name}-logs"
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "expire-access-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_logging" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "access/"
}

# Separate resource since AWS provider v4. The inline `website {}` block on
# aws_s3_bucket is removed, not merely deprecated, and fails to plan.
resource "aws_s3_bucket_website_configuration" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }
}

resource "aws_s3_bucket_ownership_controls" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Public read is served by a bucket policy, not by object ACLs. ACLs are disabled
# by BucketOwnerEnforced above, which is the current AWS default and the reason
# the old acl = "public-read" approach no longer works.
#
# No aws:SecureTransport deny is attached, deliberately: the S3 website endpoint
# only speaks HTTP, so that condition would make the site unreachable rather than
# secure. TLS here means fronting the bucket with CloudFront and making the bucket
# private behind an Origin Access Control — see the README.
resource "aws_s3_bucket_public_access_block" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "public_read" {
  statement {
    sid       = "PublicReadGetObject"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_site.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.static_site.id
  policy = data.aws_iam_policy_document.public_read.json

  # The access block must be relaxed before a public policy is accepted.
  depends_on = [aws_s3_bucket_public_access_block.static_site]
}

resource "aws_s3_bucket_versioning" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
