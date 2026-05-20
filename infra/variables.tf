variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "brazilsouth"
}

variable "environment" {
  description = "Deployment environment (dev, stage, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "environment deve ser dev, stage ou prod."
  }
}

variable "owner" {
  description = "Responsible team or person for billing/alerting"
  type        = string
  default     = "team-02-vd"
}

variable "tags" {
  description = "Extra tags merged with default SIFAP tags"
  type        = map(string)
  default     = {}
}
