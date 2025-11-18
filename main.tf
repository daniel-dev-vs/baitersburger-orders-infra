module "dynamodb" {
  source = "./aws-dynamodb"

  table_name   = "Orders"
  billing_mode = "PAY_PER_REQUEST"

  tags = {
    Environment = "dev"
    Project     = "BaitersBurger"
  }
}