resource "aws_cognito_user_pool" "orders" {
  name = var.pool_name

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = false
  }

  mfa_configuration = "OFF"
  tags              = var.tags
}

resource "aws_cognito_resource_server" "orders_api" {
  user_pool_id = aws_cognito_user_pool.orders.id
  identifier   = "orders"         
  name         = "Orders API"

  scope {
    scope_name        = "read"
    scope_description = "Read orders"
  }
  scope {
    scope_name        = "write"
    scope_description = "Write orders"
  }
}

resource "aws_cognito_user_pool_client" "orders_app" {
  name                       = "${var.pool_name}-client"
  user_pool_id               = aws_cognito_user_pool.orders.id
  generate_secret            = true
  supported_identity_providers = ["COGNITO"]

  allowed_oauth_flows                 = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                = aws_cognito_resource_server.orders_api.scope_identifiers

  prevent_user_existence_errors = "ENABLED"

  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 30
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}

resource "aws_cognito_user_pool_domain" "orders_domain" {
  domain      = var.domain_prefix
  user_pool_id = aws_cognito_user_pool.orders.id
}