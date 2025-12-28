variable "pool_name" {
  type        = string
  default     = "orders-app-pool"
}

variable "domain_prefix" {
  type        = string
  description = "Unique prefix for the Cognito domain (e.g., baiters-orders)"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "dev"
    Project     = "BaitersBurger"
  }
}

variable "lambda_authorizer_role_arn" {
  type        = string
  description = "IAM Role already existing for the Lambda Authorizer"
}