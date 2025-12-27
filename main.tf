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

module "api-gateway" {
  source = "./api-gateway"

  tags = {
    Environment = "dev"
    Project     = "BaitersBurger"
  }

  alb_dns_name      = module.alb.alb_dns_name
  alb_listener_path = "/api/v1"
  aws_region        = "us-east-1"
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