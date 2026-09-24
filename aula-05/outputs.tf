# ============================================================
# OUTPUTS — Infraestrutura TechNova Aula 05
# ============================================================

# ── VPC ──────────────────────────────────────────────────────

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
  description = "IDs das subnets públicas (EC2)"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas (RDS)"
  value       = aws_subnet.private[*].id
}

output "availability_zones_used" {
  description = "Availability Zones utilizadas"
  value       = distinct(concat(aws_subnet.public[*].availability_zone, aws_subnet.private[*].availability_zone))
}

# ── SEGURANÇA ─────────────────────────────────────────────────

output "ec2_security_group_id" {
  description = "ID do Security Group da EC2"
  value       = aws_security_group.ec2.id
}

output "rds_security_group_id" {
  description = "ID do Security Group do RDS"
  value       = aws_security_group.rds.id
}

# ── EC2 ───────────────────────────────────────────────────────

output "ec2_instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.api.id
}

output "ec2_public_ip" {
  description = "IP público da EC2 (acesso SSH e API)"
  value       = aws_instance.api.public_ip
}

output "ec2_public_dns" {
  description = "DNS público da EC2"
  value       = aws_instance.api.public_dns
}

output "api_url" {
  description = "URL da API TechNova"
  value       = "http://${aws_instance.api.public_ip}:${var.api_port}"
}

output "api_health_url" {
  description = "URL do endpoint de health check da API"
  value       = "http://${aws_instance.api.public_ip}:${var.api_port}/health"
}

output "api_db_health_url" {
  description = "URL do endpoint que testa conexão com o RDS"
  value       = "http://${aws_instance.api.public_ip}:${var.api_port}/db-health"
}

output "ssh_command" {
  description = "Comando SSH para conectar à EC2"
  value       = "ssh -i labsuser.pem ec2-user@${aws_instance.api.public_ip}"
}

# ── RDS ───────────────────────────────────────────────────────

output "rds_endpoint" {
  description = "Endpoint completo do RDS PostgreSQL (host:porta)"
  value       = "${aws_db_instance.technova.address}:${aws_db_instance.technova.port}"
}

output "rds_address" {
  description = "Hostname do RDS PostgreSQL (sem porta)"
  value       = aws_db_instance.technova.address
}

output "rds_port" {
  description = "Porta do RDS PostgreSQL"
  value       = aws_db_instance.technova.port
}

output "rds_db_name" {
  description = "Nome do banco de dados criado no RDS"
  value       = aws_db_instance.technova.db_name
}

output "rds_instance_id" {
  description = "Identificador da instância RDS"
  value       = aws_db_instance.technova.identifier
}

output "psql_connection_string" {
  description = "Comando psql para conectar ao RDS a partir da EC2 (senha passada interativamente)"
  # sensitive=true obrigatório pois db_username tem sensitive=true na variável
  value     = "psql -h ${aws_db_instance.technova.address} -p ${aws_db_instance.technova.port} -U ${var.db_username} -d ${var.db_name}"
  sensitive = true
}

output "db_connection_url" {
  description = "Connection URL completa do PostgreSQL (contém senha — sensitive)"
  value       = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.technova.address}:${aws_db_instance.technova.port}/${var.db_name}"
  sensitive   = true
}

# ── REMOTE STATE ─────────────────────────────────────────────

output "state_bucket_name" {
  description = "Nome do bucket S3 que armazena o Terraform state"
  value       = var.state_bucket_name
}

output "state_bucket_arn" {
  description = "ARN do bucket S3 do remote state"
  value       = "arn:aws:s3:::${var.state_bucket_name}"
}

output "state_dynamodb_table" {
  description = "Nome da tabela DynamoDB para locking do state"
  value       = aws_dynamodb_table.tfstate_lock.name
}

output "verify_state_command" {
  description = "Comando para verificar o state armazenado no S3"
  value       = "aws s3 ls s3://${var.state_bucket_name}/aula-05/ --recursive"
}

# ── SUMÁRIO DA INFRAESTRUTURA ─────────────────────────────────

output "infrastructure_summary" {
  description = "Resumo completo da infraestrutura provisionada"
  value = {
    vpc_id           = aws_vpc.technova.id
    public_subnets   = aws_subnet.public[*].id
    private_subnets  = aws_subnet.private[*].id
    ec2_public_ip    = aws_instance.api.public_ip
    rds_endpoint     = aws_db_instance.technova.address
    api_url          = "http://${aws_instance.api.public_ip}:${var.api_port}"
    state_bucket     = var.state_bucket_name
    dynamodb_table   = aws_dynamodb_table.tfstate_lock.name
    environment      = var.environment
    region           = var.aws_region
  }
}
