resource "aws_s3_bucket" "photos" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  tags = {
    Name = "${var.project_name}-photos"
  }
}

resource "aws_s3_bucket_versioning" "photos" {
  bucket = aws_s3_bucket.photos.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "photos" {
  bucket = aws_s3_bucket.photos.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "photos" {
  bucket = aws_s3_bucket.photos.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "photos" {
  bucket = aws_s3_bucket.photos.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "photos_public_read" {
  statement {
    sid     = "AllowPublicReadForUploads"
    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.photos.arn}/uploads/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "photos" {
  bucket = aws_s3_bucket.photos.id
  policy = data.aws_iam_policy_document.photos_public_read.json

  depends_on = [aws_s3_bucket_public_access_block.photos]
}
