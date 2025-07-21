locals {
  s3_buckets = [
    {
      name          = "inbound-bucket"
      if_encrypted  = false
      if_versioning = false
    },
    {
      name          = "outbound-bucket"
      if_encrypted  = false
      if_versioning = false
      replicate_to  = "3rd-party-outbound-bucket"
    },
    {
      name          = "3rd-party-inbound-bucket"
      if_encrypted  = false
      if_versioning = false
      replicate_to  = "inbound-bucket"
    },
    {
      name          = "3rd-party-outbound-bucket"
      if_encrypted  = false
      if_versioning = false
    },
    {
      name          = "intermediate-bucket"
      if_encrypted  = false
      if_versioning = false
    }
  ]
  s3_info = { for bucket in local.s3_buckets : bucket.name => bucket }
  s3_replication_info = {
    for bucket in local.s3_buckets : bucket.name => bucket
    if lookup(bucket, "replicate_to", null) != null
  }

}

output "replication_info" {
  value = local.s3_replication_info

}