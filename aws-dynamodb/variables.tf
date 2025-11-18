variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "order-table"
}

variable "hash_key" {
  description = "Partition (hash) key name"
  type        = string
  default     = "id"
}

variable "hash_key_type" {
  description = "Type of the partition key: S (string), N (number) or B (binary)"
  type        = string
  default     = "S"
}

variable "billing_mode" {
  description = "PAY_PER_REQUEST (on-demand) or PROVISIONED"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "tags" {
  description = "Tags applied to the table"
  type        = map(string)
  default = {
    Owner       = "dev"
    Environment = "dev"
  }
}
