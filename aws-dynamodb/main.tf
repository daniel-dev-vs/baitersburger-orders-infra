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
    type = "S" # ou "N" se for timestamp numérico
  }

  # GSI para consultar pedidos por status e ordenar por createdAt
  global_secondary_index {
    name               = "status-createdAt-index"
    hash_key           = "status"
    range_key          = "createdAt"
    projection_type    = "INCLUDE"                     # ou "ALL" / "KEYS_ONLY"
    non_key_attributes = ["customerId", "totalPrice", "productsId"] # ajuste conforme necessário
  }

  tags = var.tags
}