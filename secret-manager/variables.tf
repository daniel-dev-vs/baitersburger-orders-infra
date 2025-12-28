variable "name" {
  description = "Name of the secret"
  type        = string
}

variable "description" {
  description = "Description of the secret"
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "KMS Key ID/ARN to encrypt the secret (optional)"
  type        = string
  default     = null
}


variable "tags" {
  description = "Tags to apply to the secret"
  type        = map(string)
  default     = {}
}
