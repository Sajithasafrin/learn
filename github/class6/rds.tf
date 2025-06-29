
resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  vpc_id      = aws_vpc.main.id
  description = "allow inbound access from the ECS only"

  ingress {
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# rds postgres instance
# user password is stored in secrets manager
# random -> random password -> secrets manager
# db_subnet_group -> subnet ids list 


resource "aws_db_subnet_group" "postgres" {
  name        = "${var.environment}-${var.app_name}-db-subnet-group"
  description = "Subnet group for RDS instance"
  subnet_ids = [
    aws_subnet.rds_1.id,
    aws_subnet.rds_2.id
  ]

  tags = {
    Name        = "${var.environment}-${var.app_name}-db-subnet-group"
    Environment = var.environment
  }
}

resource "random_password" "dbs_random_string" {
  length           = 10
  special          = false
  override_special = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
}

# secret manager and the secret key 
resource "aws_secretsmanager_secret" "db_link" {
  name                    = "db/${aws_db_instance.postgres.identifier}-v3"
  description             = "DB link"
  kms_key_id              = aws_kms_key.rds_kms.arn
  recovery_window_in_days = 30
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "dbs_secret_val" {
  secret_id     = aws_secretsmanager_secret.db_link.id
  secret_string = "postgresql://${aws_db_instance.postgres.username}:${random_password.dbs_random_string.result}@${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}/${aws_db_instance.postgres.db_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "postgres" {
  identifier            = "${var.environment}-${var.app_name}-db"
  allocated_storage     = var.db_default_settings.allocated_storage
  max_allocated_storage = var.db_default_settings.max_allocated_storage
  engine                = "postgres"
  engine_version        = 14.15
  instance_class        = "db.t3.micro"
  username              = "myadmin"
  password              = random_password.dbs_random_string.result
  port                  = 5432
  publicly_accessible   = false
  db_subnet_group_name  = aws_db_subnet_group.postgres.id
  ca_cert_identifier    = var.db_default_settings.ca_cert_name
  storage_encrypted     = true
  storage_type          = "gp3"
  kms_key_id            = aws_kms_key.rds_kms.arn
  skip_final_snapshot   = true
  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  backup_retention_period    = var.db_default_settings.backup_retention_period
  db_name                    = var.db_default_settings.db_name
  auto_minor_version_upgrade = true
  deletion_protection        = false
  copy_tags_to_snapshot      = true

  tags = {
    environment = var.environment
  }
}
