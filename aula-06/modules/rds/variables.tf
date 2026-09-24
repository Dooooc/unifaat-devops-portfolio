variable "db_name" {
  description = "Nome do banco de dados inicial"
  type        = string
}

variable "db_username" {
  description = "Usuario master do RDS"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Senha master do RDS (minimo 8 caracteres)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8
    error_message = "A senha do RDS deve ter no minimo 8 caracteres."
  }
}

variable "subnet_ids" {
  description = "Lista de IDs das subnets privadas para o DB Subnet Group"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Lista de IDs dos Security Groups para o RDS"
  type        = list(string)
}

variable "instance_class" {
  description = "Classe da instancia RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "engine_version" {
  description = "Versao do engine PostgreSQL"
  type        = string
  default     = "15"
}

variable "allocated_storage" {
  description = "Armazenamento alocado em GB"
  type        = number
  default     = 20
}

variable "environment" {
  description = "Ambiente (dev, staging, production)"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto (usado no naming e nas tags)"
  type        = string
}