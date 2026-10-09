variable "environment" {
  description = "The name of the environment to create the resources for."
  type        = string
  validation {
    condition     = contains(["dev","test","prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "storage_account_name" {
  type = string
}

variable "storage_resource_group_name" {
  type = string
}

variable "location" {
  description = "The location to create the resources in."
  type        = string
}