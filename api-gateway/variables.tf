variable "alb_dns_name" {
  type        = string
  description = "Public DNS of the ALB (ex: my-alb-123.us-east-1.elb.amazonaws.com)"
}

variable "alb_listener_path" {
  type        = string
  description = "Base path exposed by the ALB (ex: /api/v1)"
  default     = "/"
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
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
  description = "ARN of the Cognito User Pool for the API Gateway authorizer"
}

variable "cognito_user_pool_id" {
  type        = string
  description = "ID of the Cognito User Pool (ex: us-east-1_XXXXXX)"
}

variable "authorizer_required_scopes" {
  type        = string
  description = "Required scopes (ex: \"orders/read orders/write\")"
  default     = ""
}

variable "lambda_authorizer_function_invoke_arn" {
  type        = string
  description = "ARN of the existing IAM Role for the Lambda Authorizer"
}

variable "lambda_authorizer_function_name" {
  type        = string
  description = "Name of the existing Lambda Authorizer function"
}

variable "lambda_authorizer_role_arn" {
  type        = string
  description = "ARN of the existing IAM Role for the Lambda Authorizer"
}

