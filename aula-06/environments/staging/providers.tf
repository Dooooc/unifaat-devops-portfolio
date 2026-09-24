terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "TechNova"
      Environment = "staging"
      ManagedBy   = "Terraform"
      Owner       = "6325238"
      Aluno       = "Yuri Batista Sanches"
      Disciplina  = "DevOps - UniFAAT 2026-2"
      Aula        = "06"
    }
  }
}