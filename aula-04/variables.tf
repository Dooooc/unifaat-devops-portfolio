# ============================================================
# VARIÁVEIS GERAIS
# ============================================================

variable "aws_region" {
  description = "Região AWS onde a infraestrutura TechNova será provisionada"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente da infraestrutura (development, staging, production)"
  type        = string
  default     = "development"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "O ambiente deve ser: development, staging ou production."
  }
}

variable "student_ra" {
  description = "Número de matrícula (RA) do aluno — usado nas tags Owner"
  type        = string
  default     = "6325238"
}

variable "student_name" {
  description = "Nome do aluno — usado nas tags Aluno"
  type        = string
  default     = "Yuri"
}

# ============================================================
# VARIÁVEIS DE REDE
# ============================================================

variable "vpc_cidr" {
  description = "Bloco CIDR principal da VPC TechNova"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs das subnets públicas (uma por AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs das subnets privadas (uma por AZ)"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability Zones utilizadas para distribuição Multi-AZ"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ============================================================
# VARIÁVEIS EC2
# ============================================================

variable "instance_type" {
  description = "Tipo da instância EC2 (t2.micro = Free Tier)"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "Nome do par de chaves SSH criado pelo Terraform"
  type        = string
  default     = "technova-key"
}

variable "api_port" {
  description = "Porta em que a API Node.js escuta"
  type        = number
  default     = 3000
}

variable "ssh_allowed_cidr" {
  description = "CIDR permitido para acesso SSH (use seu IP/32 em produção)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "app_repo_url" {
  description = "URL do repositório Git da API TechNova"
  type        = string
  default     = "https://github.com/Dooooc/technova-api.git"
}
