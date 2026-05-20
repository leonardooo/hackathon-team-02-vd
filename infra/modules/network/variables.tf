variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, stage, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags merged with SIFAP defaults"
  type        = map(string)
  default     = {}
}
