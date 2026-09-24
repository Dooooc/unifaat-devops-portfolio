# ============================================================
# SECURITY GROUPS -- Aula 05 TechNova
# Principio do menor privilegio: apenas portas necessarias
# ============================================================

# -- SG da EC2 (publica) ------------------------------------

resource "aws_security_group" "ec2" {
  name        = "${local.name_prefix}-sg-ec2"
  description = "SG da EC2 TechNova - SSH (22) e API (3000)"
  vpc_id      = aws_vpc.technova.id

  # SSH -- acesso administrativo
  ingress {
    description = "SSH administrativo"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  # API Node.js
  ingress {
    description = "API Node.js porta 3000"
    from_port   = var.api_port
    to_port     = var.api_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Saida: todo o trafego permitido (npm install, yum update, RDS)
  egress {
    description = "Todo o trafego de saida permitido"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${local.name_prefix}-sg-ec2"
    Tier    = "public"
    Project = "TechNova"
    Aula    = "05"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# -- SG do RDS (privado) ------------------------------------
# Aceita PostgreSQL SOMENTE do Security Group da EC2
# (nao expoe para toda a VPC -- seguranca por SG reference)

resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-sg-rds"
  description = "SG do RDS PostgreSQL - porta 5432 apenas do SG da EC2"
  vpc_id      = aws_vpc.technova.id

  # PostgreSQL -- apenas do Security Group da EC2
  ingress {
    description     = "PostgreSQL apenas da EC2 TechNova"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  # Saida: todo o trafego permitido
  egress {
    description = "Todo o trafego de saida permitido"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${local.name_prefix}-sg-rds"
    Tier    = "private"
    Project = "TechNova"
    Aula    = "05"
  }

  lifecycle {
    create_before_destroy = true
  }
}