variable "cluster_name" {
  description = "The name of the ECS cluster."
  type        = string
}

variable "capacity_providers" {
  description = "The capacity providers to associate with the cluster."
  type        = list(string)
  default     = []
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the ECS cluster."
  type        = map(string)
  default     = {}
}



variable "managed_termination_protection" {
  description = "Whether to enable managed termination protection for the capacity providers"
  type        = string
  default     = "ENABLED"
}

variable "default_capacity_provider_strategy" {
  description = "Default capacity provider strategy"
  type = list(object({
    capacity_provider = string
    weight           = number
    base             = optional(number)
  }))
  default = []
}