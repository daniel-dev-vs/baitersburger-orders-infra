data "aws_vpc" "aws_vpc_default" {
  default = true
}

data "aws_subnets" "aws_subnets_default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.aws_vpc_default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}
