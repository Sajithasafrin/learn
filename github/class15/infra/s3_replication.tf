
# # iam role that can be assumed by s3
# resource "aws_iam_role" "s3_replication_role" {
#   name = "${var.environment}-s3-replication-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "s3.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# # iam policy that will allow replication from source to destination bucket
# resource "aws_iam_policy" "s3_replication_policy" {
#   name        = "${var.environment}-s3-replication-policy"
#   description = "Policy to allow S3 replication"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:GetReplicationConfiguration",
#           "s3:ListBucket",
#         ]
#         Resource = [local.source_bucket_arn]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:GetObjectVersionForReplication",
#           "s3:GetObjectVersionAcl",
#           "s3:GetObjectVersionTagging",
#         ]
#         Resource = ["${local.source_bucket_arn}/*"]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:ReplicateObject",
#           "s3:ReplicateDelete",
#           "s3:ReplicateTags",
#         ]
#         Resource = ["${local.destination_bucket_arn}/*"]
#       }
#     ]
#   })
# }

# # attach the policy to the role
# resource "aws_iam_role_policy_attachment" "s3_replication_role_policy_attachment" {
#   role       = aws_iam_role.s3_replication_role.name
#   policy_arn = aws_iam_policy.s3_replication_policy.arn
# }

# # replication_rule
# resource "aws_s3_bucket_replication_configuration" "replication" {
#   # Must have bucket versioning enabled first
#   role   = aws_iam_role.s3_replication_role.arn
#   bucket = local.source_bucket_name

#   rule {
#     id = "${var.environment}-replication-rule"

#     # filter {
#     #   prefix = "example"
#     # }

#     status = "Enabled"

#     destination {
#       bucket        = local.destination_bucket_arn
#       storage_class = "STANDARD"
#     }
#   }
#     depends_on = [
#         aws_iam_role_policy_attachment.s3_replication_role_policy_attachment,
#         module.buckets
#     ]
# }





## use this with advanced_local

# iam role that can be assumed by s3
resource "aws_iam_role" "s3_replication_role" {
  for_each = local.s3_replication_info
  name     = "${var.environment}-${each.value.name}-replication-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}

# iam policy that will allow replication from source to destination bucket
resource "aws_iam_policy" "s3_replication_policy" {
  for_each    = local.s3_replication_info
  name        = "${var.environment}-${each.value.name}-replication-policy"
  description = "Policy to allow S3 replication"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket",
        ]
        Resource = ["arn:aws:s3:::${var.environment}-${each.value.name}-${data.aws_caller_identity.current.account_id}"]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging",
        ]
        Resource = ["arn:aws:s3:::${var.environment}-${each.value.name}-${data.aws_caller_identity.current.account_id}/*"]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
        ]
        Resource = ["arn:aws:s3:::${var.environment}-${each.value.replicate_to}-${data.aws_caller_identity.current.account_id}/*"]
      }
    ]
  })
}

# attach the policy to the role
resource "aws_iam_role_policy_attachment" "s3_replication_role_policy_attachment" {
  for_each   = local.s3_replication_info
  role       = aws_iam_role.s3_replication_role[each.key].name
  policy_arn = aws_iam_policy.s3_replication_policy[each.key].arn
}

# # replication_rule
resource "aws_s3_bucket_replication_configuration" "replication" {
  for_each = local.s3_replication_info
  # Must have bucket versioning enabled first
  role   = aws_iam_role.s3_replication_role[each.key].arn
  bucket = "${var.environment}-${each.value.name}-${data.aws_caller_identity.current.account_id}"

  rule {
    id = "${var.environment}-${each.key}-replication-rule"

    # filter {
    #   prefix = "example"
    # }

    status = "Enabled"

    destination {
      bucket        = "arn:aws:s3:::${var.environment}-${each.value.replicate_to}-${data.aws_caller_identity.current.account_id}"
      storage_class = "STANDARD"
    }
  }
  depends_on = [
    aws_iam_role_policy_attachment.s3_replication_role_policy_attachment,
    module.buckets
  ]
}