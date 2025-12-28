variable "alb_dns_name" {
  type        = string
  description = "DNS público do ALB (ex: my-alb-123.us-east-1.elb.amazonaws.com)"
}

variable "alb_listener_path" {
  type        = string
  description = "Path base exposto pelo ALB (ex: /api/v1)"
  default     = "/"
}

variable "aws_region" {
  type        = string
  description = "aws region to deploy resources"
  default     = "us-east-1"
}


variable "tags" {
  description = "Tags applied to the table"
  type        = map(string)
  default = {
    Owner       = "dev"
    Environment = "dev"
  }
}

variable "cognito_user_pool_arn" {
  type        = string
  description = "ARN do Cognito User Pool para o authorizer do API Gateway"
}

variable "cognito_user_pool_id" {
  type        = string
  description = "ID do Cognito User Pool (ex: us-east-1_XXXXXX)"
}

variable "authorizer_required_scopes" {
  type        = string
  description = "Escopos requeridos (ex: \"orders/read orders/write\")"
  default     = ""
}

variable "lambda_authorizer_role_arn" {
  type        = string
  description = "ARN da IAM Role já existente para o Lambda Authorizer"
}