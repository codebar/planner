provider "aws" {
  region = "eu-north-1"
}

# 1. S3 Bucket (private by default)
resource "aws_s3_bucket" "auth_bucket" {
  bucket = "codebar-planner-auth-bucket"
}

# 2. IAM User for Heroku app
resource "aws_iam_user" "heroku_reader" {
  name = "heroku-s3-reader"
}

# 3. IAM Policy: Read-only access to just this bucket
resource "aws_iam_policy" "read_write_policy" {
  name = "HerokuS3ReadWrite"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",       # List files in bucket
          "s3:GetObject",        # Read/download files
          "s3:PutObject",        # Upload files
          "s3:DeleteObject"      # Optional: allow deleting files
        ],
        Resource = [
          aws_s3_bucket.auth_bucket.arn,
          "${aws_s3_bucket.auth_bucket.arn}/*"
        ]
      }
    ]
  })
}


# 4. Attach the policy to the user
resource "aws_iam_user_policy_attachment" "attach_policy" {
  user       = aws_iam_user.heroku_reader.name
  policy_arn = aws_iam_policy.read_write_policy.arn
}

# 5. Create access keys for the user
resource "aws_iam_access_key" "heroku_user_keys" {
  user = aws_iam_user.heroku_reader.name
}

