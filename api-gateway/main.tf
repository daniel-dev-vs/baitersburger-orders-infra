
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

resource "aws_api_gateway_rest_api" "orders_api" {
  name        = "orders-api-gateway"
  description = "API Gateway for integration with the ALB of the orders application"
  body = templatefile("${path.module}/openapi.yaml", {
    alb_dns_name            = var.alb_dns_name
    cognito_user_pool_arn   = var.cognito_user_pool_arn
    authorizer_invoke_arn   = var.lambda_authorizer_function_invoke_arn
  })

}

resource "aws_api_gateway_authorizer" "lambda_auth" {
  name                   = "jwt-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.orders_api.id
  authorizer_uri         = var.lambda_authorizer_function_invoke_arn
  authorizer_result_ttl_in_seconds = 300
  type                   = "TOKEN"
  identity_source        = "method.request.header.Authorization"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_authorizer_function_name //aws_lambda_function.auth_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.orders_api.arn}/*/*"
}