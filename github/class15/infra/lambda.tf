module "lambda_function" {
  for_each = local.lambda_functions
  source   = "terraform-aws-modules/lambda/aws"

  function_name = each.value.name
  description   = each.value.description
  handler       = each.value.handler
  runtime       = each.value.runtime
  publish       = true
  timeout       = 60

  # source_path = each.value.path
  source_path = "${path.module}/lambdas/${each.value.name}"

  store_on_s3 = true
  s3_bucket   = "storage-layer-1"
  layers      = each.value.layers

  environment_variables = each.value.environments_variables
  attach_policy_json    = true
  policy_json           = each.value.policy

  tags = {
    repo = "may-bootcamp/class14"
  }
}
# Give S3 permission to invoke lambda1
resource "aws_lambda_permission" "allow_s3_invoke_lambda1" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function["lambda1"].lambda_function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.environment}-inbound-bucket-${data.aws_caller_identity.current.account_id}"
}

# S3 bucket notification to trigger lambda1 on object upload
resource "aws_s3_bucket_notification" "trigger_lambda1_on_upload" {
  bucket = "${var.environment}-inbound-bucket-${data.aws_caller_identity.current.account_id}"

  lambda_function {
    lambda_function_arn = module.lambda_function["lambda1"].lambda_function_arn
    events              = ["s3:ObjectCreated:*"]

    # Optional filters (you can remove these if not needed)
    # filter_prefix     = "incoming/"
    # filter_suffix     = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke_lambda1]
}

