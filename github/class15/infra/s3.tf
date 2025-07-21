module "buckets" {
  for_each = local.s3_info

  source      = "./modules/s3"
  bucket_name = "${var.environment}-${each.value.name}-${data.aws_caller_identity.current.account_id}"
  # if_versioning = each.value.if_versioning
  if_versioning = true
  if_encrypted  = each.value.if_encrypted
  kms_key_arn   = var.kms_key_arn
  log_bucket    = var.logging_bucket
}