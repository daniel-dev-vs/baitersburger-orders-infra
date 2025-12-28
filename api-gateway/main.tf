
resource "aws_api_gateway_deployment" "orders_deployment" {
  rest_api_id = aws_api_gateway_rest_api.orders_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.orders_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "orders_stage" {
  rest_api_id   = aws_api_gateway_rest_api.orders_api.id
  deployment_id = aws_api_gateway_deployment.orders_deployment.id
  stage_name    = "prod"
}

output "api_gateway_orders_url" {
  value = "${aws_api_gateway_stage.orders_stage.invoke_url}/orders"
}

# Atualizar o REST API para usar o novo authorizer via OpenAPI template
resource "aws_api_gateway_rest_api" "orders_api" {
  name        = "orders-api-gateway"
  description = "API Gateway for integration with the ALB of the orders application"
  body = templatefile("${path.module}/openapi.yaml", {
    alb_dns_name            = var.alb_dns_name
    cognito_user_pool_arn   = var.cognito_user_pool_arn
  })

}