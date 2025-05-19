resource "aws_s3_bucket" "inpost-static-assets" {
  bucket = vr.s3-inpost["bucket"]
}

resource "aws_s3_bucket_ownership_controls" "inpost-static-assets" {
  bucket = aws_s3_bucket.inpost-static-assets.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "inpost-static-assets" {
  depends_on = [aws_s3_bucket_ownership_controls.inpost-static-assets]
  bucket     = aws_s3_bucket.inpost-static-assets.id
  acl        = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "inpost-static-assets" {
  bucket = aws_s3_bucket.inpost-static-assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "inpost-static-assets" {
  bucket = aws_s3_bucket.inpost-static-assets.bucket
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowECSTaskReadWriteAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.ecs_service_role.arn}"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "${aws_s3_bucket.inpost-static-assets.arn}/*"
    }
  ]
}
EOF
}