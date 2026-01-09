# BaitersBurger Orders Infra — Projeto de Alto Nível (HLD)

Infraestrutura como Código (Terraform) para o microserviço de Pedidos do BaitersBurger na AWS.  Este documento descreve a arquitetura de alto nível, responsabilidades dos módulos, integrações principais e considerações operacionais.

## Visão Geral

- Propósito: Provisionar e conectar recursos AWS para o serviço de Pedidos:  ingresso, autenticação, computação, dados, imagens e segredos.
- Stack: Terraform (backend S3), AWS API Gateway, ALB, ECS (Fargate/Spot), ECR, Cognito (OAuth2), DynamoDB, Secrets Manager, Lambda Authorizer.
- Composição: Módulos instanciados em `main.tf`; provider e backend em `provider.tf`.

## Arquitetura

- Ingresso: Cliente → API Gateway (Autorizador Lambda Customizado usando Cognito) → Proxy HTTP para ALB. 
- Roteamento: ALB listener `:80` → Target Group `:8080` → Serviço ECS (app de Pedidos).
- Dados: App de Pedidos persiste no DynamoDB com GSI para `status` e `createdAt`.
- Segredos: Configurações de runtime armazenadas no Secrets Manager e injetadas nas definições de tarefas ECS.
- Imagens: Builds de CI enviam imagens para ECR; serviços ECS baixam por tag. 
- Identidade: Servidor de Recursos Cognito `orders` com OAuth2 Client Credentials e escopos `read`/`write`.

## Módulos

### alb
- Função: Application Load Balancer público para o serviço de Pedidos.
- Recursos: `aws_lb`, `aws_lb_listener` (HTTP 80), `aws_lb_target_group` (HTTP 8080), `aws_security_group`.
- Entradas: `tags`.
- Saídas: `alb_dns_name`, `alb_arn`, `alb_zone_id`, `target_group_arn`.
- Arquivos: [alb/main.tf](alb/main.tf), [alb/outputs.tf](alb/outputs.tf).

### api-gateway
- Função:  Superfície de API pública com autenticação centralizada e proxy para ALB.
- Recursos: `aws_api_gateway_rest_api`, `aws_api_gateway_deployment`, `aws_api_gateway_stage`, `aws_lambda_permission`.
- Entradas: `alb_dns_name`, `cognito_user_pool_arn`, `cognito_user_pool_id`, `lambda_authorizer_function_invoke_arn`, `lambda_authorizer_function_name`, `authorizer_required_scopes`, `tags`.
- Saídas: `api_gateway_orders_url` (base do estágio prod para `/orders`).
- Arquivos: [api-gateway/main.tf](api-gateway/main.tf), [api-gateway/variables.tf](api-gateway/variables.tf), [api-gateway/openapi.yaml](api-gateway/openapi. yaml).
- Integração: OpenAPI define `http_proxy` para ALB e um `CustomAuthorizer` usando o ARN de invocação do Lambda. 

### aws-dynamodb
- Função: Armazenamento de dados de Pedidos. 
- Recursos: `aws_dynamodb_table` com PK `orderId` e GSI `status-createdAt-index` (hash `status`, range `createdAt`).
- Entradas: `table_name`, `billing_mode` (padrão `PAY_PER_REQUEST`), `tags`.
- Saídas: (nenhuma definida).
- Arquivos: [aws-dynamodb/main.tf](aws-dynamodb/main.tf), [aws-dynamodb/outputs.tf](aws-dynamodb/outputs.tf).

### cluster-ecs
- Função: Cluster ECS hospedando o serviço de Pedidos.
- Recursos: `aws_ecs_cluster`, `aws_ecs_cluster_capacity_providers`.
- Entradas: `cluster_name`, `capacity_providers` (`FARGATE`, `FARGATE_SPOT`), `default_capacity_provider_strategy`, `enable_container_insights`, `tags`.
- Saídas: `cluster_arn`, `cluster_name`.
- Arquivos: [cluster-ecs/main.tf](cluster-ecs/main.tf), [cluster-ecs/outputs.tf](cluster-ecs/outputs.tf).

### elastic-container-registry
