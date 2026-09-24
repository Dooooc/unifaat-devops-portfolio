# ============================================================
# Modulo RDS — PostgreSQL em subnets privadas
# ============================================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# DB Subnet Group — requer minimo 2 subnets em AZs diferentes
resource "aws_db_subnet_group" "this" {
  name        = "${local.name_prefix}-db-subnet-group"
  description = "DB Subnet Group ${local.name_prefix} - subnets privadas"
  subnet_ids  = var.subnet_ids

  tags = {
    Name        = "${local.name_prefix}-db-subnet-group"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Instancia RDS PostgreSQL
resource "aws_db_instance" "this" {
  identifier = "${local.name_prefix}-postgres"

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.security_group_ids
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period      = 0
  skip_final_snapshot          = true
  deletion_protection          = false
  performance_insights_enabled = false

  tags = {
    Name        = "${local.name_prefix}-rds-postgres"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [aws_db_subnet_group.this]
}