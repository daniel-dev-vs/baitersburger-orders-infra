module "dynamodb" {
  source = "./aws-dynamodb"

  table_name   = "Orders"
  billing_mode = "PAY_PER_REQUEST"

  tags = {
    Environment = "dev"
    Project     = "BaitersBurger"
  }
}

module "ecs_cluster" {
  source = "./cluster-ecs"

  cluster_name              = "BaitersBurgerECSCluster"
  capacity_providers        = ["FARGATE", "FARGATE_SPOT"]
  enable_container_insights = true

  tags = {
    Environment = "dev"
    Project     = "BaitersBurger"
  }
}

module "ecr_order_app" {
  source = "./elastic-container-registry"

  tags = {
    Environment = "dev"
    Project     = "BaitersBurger"
  }

}


module "alb" {
  source = "./alb"

  tags = {
    Environment = "dev"
    Project     = "BaitersBurger"
  }
}

module "cognito" {
  source                     = "./cognito"
  aws_region                 = "us-east-1"
  domain_prefix              = "baiters-orders"
  lambda_authorizer_role_arn = data.aws_iam_role.lab_role.arn
  tags = {
    Environment = "dev"
    Project     = "BaitersBurger"
  }
}

module "api-gateway" {
  source                                = "./api-gateway"
  cognito_user_pool_arn                 = module.cognito.user_pool_arn
  cognito_user_pool_id                  = module.cognito.user_pool_id
  lambda_authorizer_role_arn            = data.aws_iam_role.lab_role.arn
  lambda_authorizer_function_invoke_arn = module.lambda_authorizer.invoke_arn
  lambda_authorizer_function_name       = module.lambda_authorizer.function_name

  tags = {
    Environment = "dev"
    Project     = "BaitersBurger"
  }

  alb_dns_name      = module.alb.alb_dns_name
  alb_listener_path = "/api/v1"
}

module "secret_manager_orders_app" {
  source = "./secret-manager"

  name        = "OrdersAppSecretManager"
  description = "Secret for Orders App"

  tags = {
    Environment = "dev"
    Project     = "BaitersBurger"
  }
}


module "lambda_authorizer" {
  source = "./lambda-authorizer"

  cognito_user_pool_id = module.cognito.user_pool_id
  cognito_client_id    = module.cognito.client_id

  tags = {
    Environment = "dev"
    Project     = "BaitersBurger"
  }
}

