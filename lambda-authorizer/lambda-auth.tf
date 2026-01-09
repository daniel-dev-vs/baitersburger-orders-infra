data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/index.py" # Caminho para o seu script Python
  output_path = "${path.module}/auth_lambda_payload.zip"
}


resource "aws_lambda_function" "authorizer" {
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name = "orders-jwt-authorizer"
  role          = data.aws_iam_role.lab_role.arn
  handler       = "index.handler"
  runtime       = "python3.9"

  layers = [aws_lambda_layer_version.python_jose_lib.arn]

  environment {
    variables = {
      USER_POOL_ID  = var.cognito_user_pool_id 
      APP_CLIENT_ID = var.cognito_client_id
    }
  }
}


resource "aws_lambda_layer_version" "python_jose_lib" {
  filename            = "python_jose_layer.zip"
  layer_name          = "python-jose-cryptography"
  description         = "library layer for python-jose with cryptography for validating JWT tokens"
  compatible_runtimes = ["python3.9"]
}

