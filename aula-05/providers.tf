# ============================================================
# PROVIDERS & BACKEND -- Aula 05 TechNova
# Remote State: S3 + locking nativo (use_lockfile)
# ============================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }

  # ----------------------------------------------------------
  # REMOTE STATE BACKEND
  # Pre-requisito: executar bootstrap do remote-state.tf antes.
  # Ver README.md -- Passo 1.
  # ----------------------------------------------------------
  backend "s3" {
    bucket         = "technova-tfstate-6325238"
    key            = "aula-05/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "technova-tfstate-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "TechNova"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "6325238"
      Aluno       = "Yuri Batista Sanches"
      Disciplina  = "DevOps - UniFAAT 2026-2"
      Aula        = "05"
    }
  }
}