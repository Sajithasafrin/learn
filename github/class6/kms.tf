resource "aws_kms_key" "rds_kms" {
  description             = "KMS key for RDS and Secrets Manager"
  deletion_window_in_days = 7

  tags = {
    Name        = "${var.environment}-rds-kms-key-new1"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "rds_kms_alias" {
  name          = "alias/${var.environment}-rds-kms-key-new1"
  target_key_id = aws_kms_key.rds_kms.id
}
#KMS key name updated to new1