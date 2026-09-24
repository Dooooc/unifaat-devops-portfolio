variable "instance_name" {
  description = "Nome da instancia EC2"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instancia EC2"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "ID da AMI a usar"
  type        = string
}

variable "subnet_id" {
  description = "ID da subnet onde a instancia sera criada"
  type        = string
}

variable "security_group_ids" {
  description = "Lista de IDs dos Security Groups"
  type        = list(string)
}

variable "key_name" {
  description = "Nome do key pair para acesso SSH"
  type        = string
}

variable "iam_instance_profile" {
  description = "Nome do IAM Instance Profile (LabInstanceProfile no Academy)"
  type        = string
  default     = "LabInstanceProfile"
}

variable "user_data" {
  description = "Script de inicializacao da instancia (opcional)"
  type        = string
  default     = ""
}

variable "root_volume_size" {
  description = "Tamanho do volume raiz em GB"
  type        = number
  default     = 30
}

variable "environment" {
  description = "Ambiente (dev, staging, production)"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto (usado nas tags)"
  type        = string
}