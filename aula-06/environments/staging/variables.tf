variable "aws_region" {
  description = "Regiao AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "technova"
}

variable "environment" {
  description = "Ambiente"
  type        = string
  default     = "staging"
}

variable "db_password" {
  description = "Senha do banco de dados (minimo 8 caracteres)"
  type        = string
  sensitive   = true
}