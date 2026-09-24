variable "aws_region" {
  description = "Região AWS utilizada pela TechNova"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente da infraestrutura"
  type        = string
  default     = "dev"
}