output "secret_arn" {
  description = "ARN of the secret"
  value       = aws_secretsmanager_secret.ecs_task_secret.arn
}

output "secret_id" {
  description = "ID of the secret"
  value       = aws_secretsmanager_secret.ecs_task_secret.id
}

output "secret_name" {
  description = "Name of the secret"
  value       = aws_secretsmanager_secret.ecs_task_secret.name
}

output "secret_version_id" {
  description = "Version ID of the current secret value (if created)"
  value       = aws_secretsmanager_secret_version.current.version_id
}
