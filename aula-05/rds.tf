# ============================================================
# RDS — PostgreSQL 15 nas subnets privadas
# ============================================================

# ── DB Subnet Group ──────────────────────────────────────────
# Requer mínimo 2 subnets em AZs diferentes

resource "aws_db_subnet_group" "technova" {
  name        = "${local.name_prefix}-db-subnet-group"
  description = "Subnet Group do RDS TechNova - subnets privadas em 2 AZs"
  subnet_ids  = aws_subnet.private[*].id

  tags = {
    Name    = "${local.name_prefix}-db-subnet-group"
    Project = "TechNova"
    Aula    = "05"
  }
}

# ── Instância RDS PostgreSQL 15 ──────────────────────────────

resource "aws_db_instance" "technova" {
  identifier = "${local.name_prefix}-postgres"

  # Engine
  engine         = "postgres"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  # Armazenamento
  allocated_storage = var.db_allocated_storage
  storage_type      = "gp2"
  storage_encrypted = true

  # Credenciais - sensiveis, providas via terraform.tfvars (nao commitado)
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  # Rede
  db_subnet_group_name   = aws_db_subnet_group.technova.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  multi_az               = false

  # Manutencao
  backup_retention_period = 0       # desabilitado para lab (economiza custo)
  skip_final_snapshot     = true    # obrigatorio para terraform destroy funcionar no lab
  deletion_protection     = false   # lab: permite destruir sem confirmacao manual

  # Performance Insights desabilitado para db.t3.micro (nao suportado free tier)
  performance_insights_enabled = false

  tags = {
    Name    = "${local.name_prefix}-rds-postgres"
    Tier    = "private"
    Project = "TechNova"
    Aula    = "05"
  }

  # O SG e o subnet group devem existir antes do RDS
  depends_on = [
    aws_db_subnet_group.technova,
    aws_security_group.rds,
  ]
}
