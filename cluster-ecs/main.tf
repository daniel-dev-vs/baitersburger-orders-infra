resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name
  tags = var.tags
}


resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = var.capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = length(var.default_capacity_provider_strategy) > 0 ? var.default_capacity_provider_strategy : []
    content {
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
      weight           = default_capacity_provider_strategy.value.weight
      base             = lookup(default_capacity_provider_strategy.value, "base", null)
    }
  }
}