output "user_pool_id" {
  value = aws_cognito_user_pool.orders.id
}
output "user_pool_arn" {
  value = aws_cognito_user_pool.orders.arn
}
output "client_id" {
  value = aws_cognito_user_pool_client.orders_app.id
}
output "client_secret" {
  value       = aws_cognito_user_pool_client.orders_app.client_secret
  sensitive   = true
}
output "issuer" {
  value = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.orders.id}"
}
output "jwks_uri" {
  value = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.orders.id}/.well-known/jwks.json"
}
output "token_url" {
  value = "https://${aws_cognito_user_pool_domain.orders_domain.domain}.auth.${var.aws_region}.amazoncognito.com/oauth2/token"
}