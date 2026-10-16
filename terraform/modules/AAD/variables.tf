variable "environment" {
  description = "The name of the environment to create the resources for."
  type        = string
  validation {
    condition     = contains(["dev","test","prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

variable "redirect_uris" {
  description = "Redirect URIs for the AKS-hosted application (must be https, except localhost)"
  type        = list(string)
  default     = []
}

variable "logout_url" {
  description = "Optional front-channel logout URL"
  type        = string
  default     = null
}