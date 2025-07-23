variable "logging_bucket" {
  description = "S3 bucket for logging"
  type        = string

}

variable "environment" {
  description = "Environment for the infrastructure"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encryption"
  type        = string

}

variable "allowd_ip_list" {
  type = list(string)
  default = [
    "10.146.161.7/32"
  ]
}