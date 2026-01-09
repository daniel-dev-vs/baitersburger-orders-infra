resource "aws_dynamodb_table" "orders" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = "orderId"

  attribute {
    name = "orderId"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  attribute {
    name = "createdAt"
    type = "S" 
  }

  global_secondary_index {
    name               = "status-createdAt-index"
    hash_key           = "status"
    range_key          = "createdAt"
    projection_type    = "INCLUDE"                     
    non_key_attributes = ["customerId", "totalPrice", "productsId"]
  }

  tags = var.tags
}