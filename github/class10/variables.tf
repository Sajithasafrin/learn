variable "environment" {
  description = "The environment for the resources (e.g., dev, prod)"
  type        = string
  default     = "dev"
  
}
variable "prefix" {
  description = "The project prefix"
  type        = string
  default     = "may-bootcamp"
}