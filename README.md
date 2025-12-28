# BaitersBurger Orders Infra — High‑Level Design (HLD)

Infrastructure as Code (Terraform) for the BaitersBurger Orders microservice on AWS. This document describes the high‑level architecture, module responsibilities, key integrations, and operational considerations. No icons are used.

## Overview

- Purpose: Provision and wire AWS resources for the Orders service: ingress, auth, compute, data, images, and secrets.
- Stack: Terraform (S3 backend), AWS API Gateway, ALB, ECS (Fargate/Spot), ECR, Cognito (OAuth2), DynamoDB, Secrets Manager, Lambda Authorizer.
- Composition: Modules instantiated in `main.tf`; provider and backend in `provider.tf`.

## Architecture

- Ingress: Client → API Gateway (Custom Lambda Authorizer using Cognito) → HTTP proxy to ALB.
- Routing: ALB listener `:80` → Target Group `:8080` → ECS service (Orders app).
- Data: Orders app persists to DynamoDB with GSI for `status` and `createdAt`.
- Secrets: Runtime configuration stored in Secrets Manager and injected to ECS task definitions.
- Images: CI builds push images to ECR; ECS services pull by tag.
- Identity: Cognito Resource Server `orders` with OAuth2 Client Credentials and scopes `read`/`write`.

## Modules

### alb
- Role: Public Application Load Balancer for the Orders service.
- Resources: `aws_lb`, `aws_lb_listener` (HTTP 80), `aws_lb_target_group` (HTTP 8080), `aws_security_group`.
- Inputs: `tags`.
- Outputs: `alb_dns_name`, `alb_arn`, `alb_zone_id`, `target_group_arn`.
- Files: [alb/main.tf](alb/main.tf), [alb/outputs.tf](alb/outputs.tf).

### api-gateway
- Role: Public API surface with centralized auth and proxy to ALB.
- Resources: `aws_api_gateway_rest_api`, `aws_api_gateway_deployment`, `aws_api_gateway_stage`, `aws_lambda_permission`.
- Inputs: `alb_dns_name`, `cognito_user_pool_arn`, `cognito_user_pool_id`, `lambda_authorizer_function_invoke_arn`, `lambda_authorizer_function_name`, `authorizer_required_scopes`, `tags`.
- Outputs: `api_gateway_orders_url` (prod stage base for `/orders`).
- Files: [api-gateway/main.tf](api-gateway/main.tf), [api-gateway/variables.tf](api-gateway/variables.tf), [api-gateway/openapi.yaml](api-gateway/openapi.yaml).
- Integration: OpenAPI defines `http_proxy` to ALB and a `CustomAuthorizer` using the Lambda invoke ARN.

### aws-dynamodb
- Role: Orders data store.
- Resources: `aws_dynamodb_table` with PK `orderId` and GSI `status-createdAt-index` (hash `status`, range `createdAt`).
- Inputs: `table_name`, `billing_mode` (default `PAY_PER_REQUEST`), `tags`.
- Outputs: (none defined).
- Files: [aws-dynamodb/main.tf](aws-dynamodb/main.tf), [aws-dynamodb/outputs.tf](aws-dynamodb/outputs.tf).

### cluster-ecs
- Role: ECS cluster hosting the Orders service.
- Resources: `aws_ecs_cluster`, `aws_ecs_cluster_capacity_providers`.
- Inputs: `cluster_name`, `capacity_providers` (`FARGATE`, `FARGATE_SPOT`), `default_capacity_provider_strategy`, `enable_container_insights`, `tags`.
- Outputs: `cluster_arn`, `cluster_name`.
- Files: [cluster-ecs/main.tf](cluster-ecs/main.tf), [cluster-ecs/outputs.tf](cluster-ecs/outputs.tf).

### elastic-container-registry
- Role: Container image registry for the Orders app.
- Resources: `aws_ecr_repository` with on‑push image scanning.
- Inputs: `tags`.
- Outputs: `ecr_repository_url`.
- Files: [elastic-container-registry/main.tf](elastic-container-registry/main.tf).

### cognito
- Role: OAuth2 authorization and scopes for the Orders API.
- Resources: `aws_cognito_user_pool`, `aws_cognito_resource_server` (`read`, `write`), `aws_cognito_user_pool_client` (Client Credentials), `aws_cognito_user_pool_domain`.
- Inputs: `pool_name`, `domain_prefix`, `aws_region`, `tags`, `lambda_authorizer_role_arn`.
- Outputs: `user_pool_id`, `user_pool_arn`, `client_id`, `client_secret` (sensitive), `issuer`, `jwks_uri`, `token_url`.
- Files: [cognito/main.tf](cognito/main.tf), [cognito/output.tf](cognito/output.tf).

### lambda-authorizer
- Role: Custom authorizer (Lambda) to validate tokens/scopes for API Gateway.
- Resources: `aws_lambda_function`, `aws_lambda_layer_version` (Python JOSE + cryptography layer).
- Inputs: `cognito_user_pool_id`, `cognito_client_id`, `tags`.
- Outputs: `function_name`, `invoke_arn`.
- Files: [lambda-authorizer/lambda-auth.tf](lambda-authorizer/lambda-auth.tf), [lambda-authorizer/index.py](lambda-authorizer/index.py), [lambda-authorizer/variables.tf](lambda-authorizer/variables.tf), [lambda-authorizer/outputs.tf](lambda-authorizer/outputs.tf).
- Integration: API Gateway grants permission and references the authorizer's invoke ARN in OpenAPI.

### lambda_layers
- Role: Shared Python dependencies (e.g., `python-jose`, `cryptography`, `rsa`, `ecdsa`).
- Resources: Layer contents (Terraform layer is defined in `lambda-authorizer`).
- Files: [lambda_layers/python](lambda_layers/python).

### secret-manager
- Role: Secure configuration storage for the Orders app.
- Resources: `aws_secretsmanager_secret`, `aws_secretsmanager_secret_version` with JSON payload.
- Inputs: `name`, `description`, `kms_key_id` (optional), `tags`.
- Outputs: `secret_arn`, `secret_id`, `secret_name`, `secret_version_id`.
- Files: [secret-manager/main.tf](secret-manager/main.tf), [secret-manager/outputs.tf](secret-manager/outputs.tf).

## Module Orchestration

- Composition: See [main.tf](main.tf) for module wiring and variable passing.
- Key dependencies:
	- API Gateway uses ALB DNS (`alb_dns_name`), Lambda Authorizer (`invoke_arn`, `function_name`), and Cognito (`user_pool_arn`, `user_pool_id`).
	- Lambda Authorizer receives Cognito `user_pool_id` and `client_id` for JWT validation.
	- Orders app (ECS service, defined outside this infra) integrates with ECR (images), ALB (traffic), Secrets Manager (config), and DynamoDB (data).

## Primary Flows

- Authenticated requests: Client with Bearer token (Client Credentials) → API Gateway → Lambda Authorizer validates Cognito scopes `orders/read` or `orders/write` → Proxy to ALB → ECS Orders service → DynamoDB.
- Webhook (no auth): API Gateway → Proxy to ALB `POST /orders/webhooks` → ECS Orders service.
- Image delivery: CI build → push to ECR → ECS service updates to new image tag.

## Design Decisions

- API Gateway proxy to ALB centralizes public exposure and authorization while keeping ALB as HTTP backend.
- Custom Lambda Authorizer enables flexible claim/scope enforcement against Cognito.
- DynamoDB GSI supports efficient queries by order `status` and chronology (`createdAt`).
- ECS capacity providers (`FARGATE`, `FARGATE_SPOT`) balance cost and availability.
- Secrets Manager keeps sensitive configuration encrypted and versioned.

## Operations

- State backend: S3 configured in [provider.tf](provider.tf) (`baiters-burger-infra-orders-app`).
- Region: `us-east-1` (see [provider.tf](provider.tf)).
- Typical commands:

```bash
terraform init
terraform plan
terraform apply
```

## Notes

- ECS service/task definition, networking (subnets/VPC selection), and container environment wiring are expected in the application stack and are not fully covered in this infra repository.
