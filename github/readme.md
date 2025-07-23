dig +short <record_name> CNAME
_cf618dba0c052030bb07a3c1fd2d17a6.sajitha.tech
_cf618dba0c052030bb07a3c1fd2d17a6.sajitha.tech.

import boto3    
import json
# Create IAM client
iam_client = boto3.client('iam')

# Replace with your group name
group_name = 'third_party'

# List users in the group
response = iam_client.get_group(GroupName=group_name)
#print (response)
print(json.dumps(response, indent=2, default=str))
# Extract user names
#users = response['Users']
#print(f"Users in group '{group_name}':")
#for user in users:
    #print(f"- {user['UserName']}")


    locals {
  lambda_info = [

    {
      name        = "lambda1"
      path        = "../lambdas/lambda1"
      handler     = "main.lambda_handler"
      description = "My awesome lambda function"
      runtime     = "python3.12"
      layers      = [module.layer["layer1"].lambda_layer_arn]
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action   = ["s3:*"]
            Effect   = "Allow"
            Resource = "*"
          }
        ]
      })
      environments_variables = {
        source_bucket      = "${var.environment}-inbound-bucket-${data.aws_caller_identity.current.account_id}"
        destination_bucket = "${var.environment}-intermediate-bucket-${data.aws_caller_identity.current.account_id}"
      }
    },
    {
      name        = "lambda2"
      path        = "/lambdas/lambda2"
      handler     = "main.lambda_handler"
      description = "My awesome lambda function 2"
      runtime     = "python3.12"
      layers      = [module.layer["layer2"].lambda_layer_arn]
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action   = ["s3:*"]
            Effect   = "Allow"
            Resource = "*"
          }
        ]
      })
      environments_variables = {
        source_bucket      = "${var.environment}-intermediate-bucket-${data.aws_caller_identity.current.account_id}"
        destination_bucket = "${var.environment}-outbound-bucket-${data.aws_caller_identity.current.account_id}"
      }
    }
  ]

  layers_info = [
    {
      name                = "layer1"
      path                = "layers/layer1"
      description         = "pandas"
      compatible_runtimes = ["python3.12", "python3.13", "python3.11"]
    },
    {
      name                = "layer2"
      path                = "layers/layer2"
      description         = "openpyxl"
      compatible_runtimes = ["python3.12", "python3.13", "python3.11"]
    }

  ]

  lambda_functions = { for lambda in local.lambda_info : lambda.name => lambda }
  lambda_layers    = { for layer in local.layers_info : layer.name => layer }
}