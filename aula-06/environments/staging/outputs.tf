output "vpc_id" {
  description = "ID da VPC staging"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs das subnets publicas staging"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas staging"
  value       = module.vpc.private_subnet_ids
}

output "api_sg_id" {
  description = "ID do SG da API staging"
  value       = module.api_sg.sg_id
}

output "rds_sg_id" {
  description = "ID do SG do RDS staging"
  value       = module.rds_sg.sg_id
}

output "ec2_instance_id" {
  description = "ID da instancia EC2 staging"
  value       = module.api_server.instance_id
}

output "ec2_public_ip" {
  description = "IP publico da EC2 staging"
  value       = module.api_server.public_ip
}

output "rds_endpoint" {
  description = "Endpoint do RDS staging"
  value       = module.database.db_endpoint
}

output "rds_db_name" {
  description = "Nome do banco de dados staging"
  value       = module.database.db_name
}

output "ssh_command" {
  description = "Comando SSH para a EC2 staging"
  value       = "ssh -i labsuser.pem ec2-user@${module.api_server.public_ip}"
}

output "psql_command" {
  description = "Comando psql para conectar ao RDS staging (a partir da EC2)"
  value       = "psql -h ${module.database.db_address} -p ${module.database.db_port} -U technova_admin -d technova_staging"
  sensitive   = true
}