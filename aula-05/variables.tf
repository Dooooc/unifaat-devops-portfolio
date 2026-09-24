# ============================================================
# VARIÁVEIS — Infraestrutura Completa TechNova Aula 05
# ============================================================

# ── GERAIS ───────────────────────────────────────────────────

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
  description = "Número de matrícula (RA) do aluno — usado nas tags Owner e no nome do bucket"
  type        = string
  default     = "6325238"
}

variable "student_name" {
  description = "Nome do aluno — usado nas tags Aluno"
  type        = string
  default     = "Yuri"
}

# ── REDE (VPC) ───────────────────────────────────────────────

variable "vpc_cidr" {
  description = "Bloco CIDR principal da VPC TechNova"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs das subnets públicas (EC2) — 1 subnet por AZ"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs das subnets privadas (RDS) — mínimo 2 AZs para DB Subnet Group"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability Zones utilizadas (índice 0 = pública, 0+1 = privadas)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ── EC2 ──────────────────────────────────────────────────────

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t2.micro"
}

variable "api_port" {
  description = "Porta em que a API Node.js escuta"
  type        = number
  default     = 3000
}

variable "ssh_allowed_cidr" {
  description = "CIDR permitido para SSH (use seu IP/32 em produção)"
  type        = string
  default     = "0.0.0.0/0"
}

# ── RDS ──────────────────────────────────────────────────────

variable "db_instance_class" {
  description = "Classe da instância RDS PostgreSQL"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Armazenamento alocado para o RDS em GB"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "Versão do engine PostgreSQL"
  type        = string
  default     = "15"
}

variable "db_name" {
  description = "Nome do banco de dados inicial criado no RDS"
  type        = string
  default     = "technovadb"
}

variable "db_username" {
  description = "Usuário administrador do banco de dados RDS"
  type        = string
  default     = "technova_admin"
  sensitive   = true
}

variable "db_password" {
  description = "Senha do usuário administrador do RDS (mínimo 8 caracteres)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8
    error_message = "A senha do banco de dados deve ter no mínimo 8 caracteres."
  }
}

variable "db_port" {
  description = "Porta de conexão do PostgreSQL"
  type        = number
  default     = 5432
}

# ── REMOTE STATE ─────────────────────────────────────────────

variable "state_bucket_name" {
  description = "Nome do bucket S3 para armazenar o Terraform state (deve ser globalmente único)"
  type        = string
  default     = "technova-tfstate-6325238"
}

variable "state_dynamodb_table" {
  description = "Nome da tabela DynamoDB usada para locking do state"
  type        = string
  default     = "technova-tfstate-lock"
}
