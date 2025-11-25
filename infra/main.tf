provider "aws" {
  region = "eu-north-1"
}

# Create the IAM user who will assume the basic role
resource "aws_iam_user" "basic_user" {
  name = "basic-user"
}

# Basic Role - trust the specific IAM user to assume this role
resource "aws_iam_role" "basic_role" {
  name = "terraform-basic-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_user.basic_user.arn  # <--- Trust this IAM user
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Policy allowing the basic role to assume the admin role
resource "aws_iam_policy" "assume_admin_policy" {
  name = "AssumeTerraformAdminRole"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Resource = aws_iam_role.admin_role.arn
      }
    ]
  })
}

# Attach the assume admin role policy to the basic role
resource "aws_iam_role_policy_attachment" "basic_assume_admin_attach" {
  role       = aws_iam_role.basic_role.name
  policy_arn = aws_iam_policy.assume_admin_policy.arn
}

# Admin role (trusts the basic role)
resource "aws_iam_role" "admin_role" {
  name = "terraform-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.basic_role.arn
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "admin_attach" {
  role       = aws_iam_role.admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# 1. S3 Bucket (private by default)
resource "aws_s3_bucket" "auth_bucket" {
  bucket = "codebar-planner-auth-bucket"
}

# 2. IAM User for Heroku app
resource "aws_iam_user" "heroku_role" {
  name = "heroku-s3-access"
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
  user       = aws_iam_user.heroku_role.name
  policy_arn = aws_iam_policy.read_write_policy.arn
}

# 5. Create access keys for the user
resource "aws_iam_access_key" "heroku_user_keys" {
  user = aws_iam_user.heroku_role.name
}
