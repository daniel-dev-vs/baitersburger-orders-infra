resource "aws_secretsmanager_secret" "ecs_task_secret" {
  name                        = var.name
  description                 = var.description
  kms_key_id                  = var.kms_key_id
  recovery_window_in_days     = 7

  tags = var.tags
}


resource "aws_secretsmanager_secret_version" "current" {
  secret_id     = aws_secretsmanager_secret.ecs_task_secret.id
  secret_string = jsonencode({
    MERCADO_PAGO_ACCESS_TOKEN    = ""
    MERCADO_PAGO_EXTERNAL_POS_ID = ""
    MERCADO_PAGO_URL             = ""
    CUSTOMER_SERVICE_URL         = ""
    PRODUCT_SERVICE_URL          = ""
    VALIDATE_SERVICE             = false
    AWS_REGION                   = ""
    TABLE_ORDER                  = ""
    AWS_ACCESS_KEY               = ""
    AWS_SECRET_KEY               = ""
  })
}
