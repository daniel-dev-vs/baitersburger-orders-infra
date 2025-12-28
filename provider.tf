terraform {
  backend "s3" {
    bucket = "baiters-burger-infra-orders-app"
    key    = "terraform/infra/state.tfstate"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}