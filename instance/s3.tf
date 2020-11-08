resource "aws_s3_bucket" "backup" {
  bucket_prefix = var.bucket_prefix
  acl           = "private"
  tags          = var.tags

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "old-saves"
    enabled = true

    prefix = "saves/"

    noncurrent_version_expiration {
      days = 180
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_policy" "backup" {
  bucket = aws_s3_bucket.backup.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.backup.arn}"
      },
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": "${aws_s3_bucket.backup.arn}"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.backup.arn}"
      },
      "Action": [
        "s3:GetObject",
        "s3:GetObjectTagging",
        "s3:GetObjectVersion",
        "s3:GetObjectVersionTagging",
        "s3:PutObject",
        "s3:PutObjectTagging",
        "s3:PutObjectVersionTagging"
      ],
      "Resource": "${aws_s3_bucket.backup.arn}/*"
    }
  ]
}
POLICY
}
