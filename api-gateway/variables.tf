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