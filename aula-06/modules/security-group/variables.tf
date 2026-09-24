variable "name" {
  description = "Nome do Security Group"
  type        = string
}

variable "description" {
  description = "Descricao do Security Group"
  type        = string
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  description = "ID da VPC onde o SG sera criado"
  type        = string
}

variable "ingress_rules" {
  description = "Lista de regras de entrada"
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string), [])
    security_groups = optional(list(string), [])
  }))
  default = []
}

variable "environment" {
  description = "Ambiente (dev, staging, production)"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto (usado nas tags)"
  type        = string
}