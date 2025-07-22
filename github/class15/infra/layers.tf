module "layer" {
  for_each = local.lambda_layers
  source   = "terraform-aws-modules/lambda/aws"

  create_layer = true

  layer_name          = each.value.name
  description         = each.value.description
  compatible_runtimes = each.value.compatible_runtimes
  runtime             = "python3.12"

  source_path = {
    path             = "${path.module}/../${each.value.path}",
    pip_requirements = true,
    prefix_in_zip    = "python"
  }
  store_on_s3 = true
  s3_bucket   = "storage-layer-1"
}

# module.lambda_layer_s3.lambda