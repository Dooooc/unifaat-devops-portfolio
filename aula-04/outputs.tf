# ============================================================
# OUTPUTS — Infraestrutura TechNova Aula 04
# ============================================================

# ── VPC ─────────────────────────────────────────────────────

output "vpc_id" {
  description = "ID da VPC TechNova"
  value       = aws_vpc.technova.id
}

output "vpc_cidr" {
  description = "Bloco CIDR da VPC TechNova"
  value       = aws_vpc.technova.cidr_block
}

# ── SUBNETS ──────────────────────────────────────────────────

output "public_subnet_ids" {
  description = "Lista de IDs das subnets públicas (Multi-AZ)"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Lista de IDs das subnets privadas (Multi-AZ)"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "CIDRs das subnets públicas"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "CIDRs das subnets privadas"
  value       = aws_subnet.private[*].cidr_block
}

output "availability_zones_used" {
  description = "Availability Zones utilizadas na infraestrutura Multi-AZ"
  value       = aws_subnet.public[*].availability_zone
}

# ── SEGURANÇA ────────────────────────────────────────────────

output "api_security_group_id" {
  description = "ID do Security Group da API TechNova"
  value       = aws_security_group.api.id
}

output "db_security_group_id" {
  description = "ID do Security Group do banco de dados (PostgreSQL)"
  value       = aws_security_group.database.id
}

# ── IAM ──────────────────────────────────────────────────────

output "ec2_iam_role_arn" {
  description = "ARN da IAM Role anexada ao EC2 (LabRole do Academy)"
  value       = data.aws_iam_role.lab_role.arn
}

output "ec2_instance_profile_name" {
  description = "Nome do Instance Profile anexado ao EC2 (LabInstanceProfile do Academy)"
  value       = data.aws_iam_instance_profile.lab_instance_profile.name
}

# ── EC2 ───────────────────────────────────────────────────────

output "ec2_instance_id" {
  description = "ID da instância EC2 da API"
  value       = aws_instance.api.id
}

output "ec2_public_ip" {
  description = "IP público da instância EC2 (usado para curl e SSH)"
  value       = aws_instance.api.public_ip
}

output "ec2_public_dns" {
  description = "DNS público da instância EC2"
  value       = aws_instance.api.public_dns
}

output "ec2_ami_id" {
  description = "ID da AMI Amazon Linux 2023 utilizada"
  value       = data.aws_ami.amazon_linux_2023.id
}

# ── URLS E COMANDOS ÚTEIS ────────────────────────────────────

output "api_url" {
  description = "URL completa para acessar a API TechNova"
  value       = "http://${aws_instance.api.public_ip}:3000"
}

output "api_health_url" {
  description = "URL do endpoint de health check da API"
  value       = "http://${aws_instance.api.public_ip}:3000/health"
}

output "ssh_command" {
  description = "Comando SSH para conectar à instância EC2"
  value       = "ssh -i ${path.module}/technova-key.pem ec2-user@${aws_instance.api.public_ip}"
}

output "curl_command" {
  description = "Comando curl para testar a API após o apply"
  value       = "curl http://${aws_instance.api.public_ip}:3000"
}

# ── SUMÁRIO DA INFRAESTRUTURA ────────────────────────────────

output "infrastructure_summary" {
  description = "Resumo completo da infraestrutura provisionada"
  value = {
    vpc_id          = aws_vpc.technova.id
    public_subnets  = aws_subnet.public[*].id
    private_subnets = aws_subnet.private[*].id
    ec2_public_ip   = aws_instance.api.public_ip
    api_url         = "http://${aws_instance.api.public_ip}:3000"
    environment     = var.environment
    region          = var.aws_region
  }
}
