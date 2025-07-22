module "lambda_function" {
  for_each = local.lambda_functions
  source   = "terraform-aws-modules/lambda/aws"

  function_name = each.value.name
  description   = each.value.description
  handler       = each.value.handler
  runtime       = each.value.runtime
  publish       = true
  timeout       = 60

  source_path = each.value.path

    layers = each.value.layers

  environment_variables = each.value.environments_variables

  tags = {
    repo = "may-bootcamp/class14"
  }
}