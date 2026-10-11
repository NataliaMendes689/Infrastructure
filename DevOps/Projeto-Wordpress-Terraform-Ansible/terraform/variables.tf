variable "aws_region" {
  description = "Region the stack is deployed into."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix applied to every resource name and tag."
  type        = string
  default     = "wordpress-lab"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,30}$", var.project_name))
    error_message = "project_name must be lowercase alphanumeric with hyphens, 3-31 characters."
  }
}

variable "environment" {
  description = "Environment tag."
  type        = string
  default     = "lab"

  validation {
    condition     = contains(["lab", "dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: lab, dev, staging, prod."
  }
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair used for SSH access."
  type        = string
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to reach SSH. Must not be open to the internet."
  type        = list(string)

  validation {
    condition     = !contains(var.ssh_allowed_cidrs, "0.0.0.0/0")
    error_message = "Refusing 0.0.0.0/0 on SSH. Pass your own address, e.g. [\"203.0.113.4/32\"]."
  }

  validation {
    condition     = length(var.ssh_allowed_cidrs) > 0
    error_message = "At least one CIDR is required, otherwise the instance is unreachable."
  }
}

variable "http_allowed_cidrs" {
  description = "CIDR blocks allowed to reach HTTP and HTTPS. Public by design for a web server."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "root_volume_size_gb" {
  description = "Size of the root EBS volume."
  type        = number
  default     = 16

  validation {
    condition     = var.root_volume_size_gb >= 8 && var.root_volume_size_gb <= 100
    error_message = "root_volume_size_gb must be between 8 and 100."
  }
}
