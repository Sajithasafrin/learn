# locals {
#   s3_buckets = [
#     {
#       name          = "inbound-bucket"
#       if_encrypted  = false
#       if_versioning = false
#     },
#     {
#       name          = "outbound-bucket"
#       if_encrypted  = false
#       if_versioning = false
#     },
#     {
#       name          = "3rd-party-inbound-bucket"
#       if_encrypted  = false
#       if_versioning = false

#     },
#     {
#       name          = "3rd-party-outbound-bucket"
#       if_encrypted  = false
#       if_versioning = false
#     },
#     {
#       name          = "intermediate-bucket"
#       if_encrypted  = false
#       if_versioning = false
#     }
#   ]
#   s3_info = { for bucket in local.s3_buckets : bucket.name => bucket }



# source_bucket_name = "dev-3rd-party-inbound-bucket-879381241087"
# destination_bucket_name    = "dev-inbound-bucket-879381241087"
# # source_bucket_arn     = "arn:aws:s3:::dev-3rd-party-inbound-bucket-879381241087"
# # destination_bucket_arn = "arn:aws:s3:::dev-inbound-bucket-879381241087"
# source_bucket_arn     = "arn:aws:s3:::${local.source_bucket_name}"
# destination_bucket_arn = "arn:aws:s3:::${local.destination_bucket_name}"
# }
# output "s3" {
#   value = local.s3_info
# }