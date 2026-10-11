variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  description = "Suffix for the bucket name. Must be globally unique once prefixed."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,40}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be lowercase alphanumeric with hyphens, 3-42 characters, not starting or ending with a hyphen."
  }
}

variable "environment" {
  type    = string
  default = "lab"

  validation {
    condition     = contains(["lab", "dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: lab, dev, staging, prod."
  }
}

variable "index_document" {
  type    = string
  default = "index.html"
}

variable "error_document" {
  type    = string
  default = "404.html"
}
