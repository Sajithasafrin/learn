resource "aws_iam_user" "user" {
  name = "${var.environment}-3rdparty-user"
}

resource "aws_iam_policy" "policy" {
  name        = "${var.environment}-3rdparty-user-policy"
  description = "Policy for S3 upload and download operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Statement 1: List first bucket
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.environment}-3rd-party-inbound-bucket-${data.aws_caller_identity.current.account_id}"
        ]
        "Condition" : {
          "IpAddress" : {
            "aws:SourceIp" : var.allowd_ip_list
          }
        }
      },
      {
        # Statement 2: Upload to first bucket
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = [
          "arn:aws:s3:::${var.environment}-3rd-party-inbound-bucket-${data.aws_caller_identity.current.account_id}/*"
        ]
        "Condition" : {
          "IpAddress" : {
            "aws:SourceIp" : var.allowd_ip_list
          }
        }

      },
      {
        # Statement 3: List second bucket
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.environment}-3rd-party-outbound-bucket-${data.aws_caller_identity.current.account_id}"
        ]
        "Condition" : {
          "IpAddress" : {
            "aws:SourceIp" : var.allowd_ip_list
          }
        }
      },
      {
        # Statement 4: Download from second bucket
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectAcl"
        ]
        Resource = [
          "arn:aws:s3:::${var.environment}-3rd-party-outbound-bucket-${data.aws_caller_identity.current.account_id}/*"
        ]
        "Condition" : {
          "IpAddress" : {
            "aws:SourceIp" : var.allowd_ip_list
          }
        }
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "test-attach" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.policy.arn
}