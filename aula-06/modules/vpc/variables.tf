variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto (usado no naming e nas tags)"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, production)"
  type        = string
}

variable "subnets" {
  description = "Mapa de subnets a criar. Cada entrada define cidr, az e type (public|private)."
  type = map(object({
    cidr = string
    az   = string
    type = string # "public" ou "private"
  }))
}