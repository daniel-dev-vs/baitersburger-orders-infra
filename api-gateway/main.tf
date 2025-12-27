resource "aws_api_gateway_rest_api" "orders_api" {
  name        = "orders-api-gateway"
  description = "API Gateway para integrar com o ALB da aplicação de pedidos"
  
  body = templatefile("${path.module}/openapi.yaml", {
    alb_dns_name = var.alb_dns_name
  })
}

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