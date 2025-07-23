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