variable "pool_name" {
  type        = string
  default     = "orders-app-pool"
}

variable "domain_prefix" {
  type        = string
  description = "Prefixo único para o domínio do Cognito (ex: baiters-orders)"
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
  description = "ARN da IAM Role já existente para o Lambda Authorizer"
}