variable "cognito_user_pool_id" {
  type        = string
  description = "User pool ID for the Lambda Authorizer"
}

variable "cognito_client_id" {
  type        = string
  description = "App client ID for the Lambda Authorizer"
}

variable tags {
  description = "A map of tags to assign to the ALB resources."
  type        = map(string)
  default     = {}
}