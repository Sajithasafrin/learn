resource "aws_ecr_repository" "student_portal_app" {
  name = "${var.prefix}-${var.environment}-${var.app_name}"
}