# ============================================================
# SECURITY GROUP — API (EC2 público)
# Princípio do menor privilégio: apenas as portas necessárias
# ============================================================

resource "aws_security_group" "api" {
  name        = "${local.name_prefix}-sg-api"
  description = "Security Group da API TechNova - SSH e porta Node.js"
  vpc_id      = aws_vpc.technova.id

  # SSH — acesso administrativo
  ingress {
    description = "SSH administrativo"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  # API Node.js
  ingress {
    description = "API Node.js porta ${var.api_port}"
    from_port   = var.api_port
    to_port     = var.api_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: todo o trafego permitido (atualizações, npm install, etc.)
  egress {
    description = "Todo o trafego de saida permitido"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-sg-api"
    Tier = "public"
  }

  # Garante que o SG antigo seja destruído antes de criar o novo
  # ao renomear — evita conflitos de nome
  lifecycle {
    create_before_destroy = true
  }
}

# ============================================================
# SECURITY GROUP — Banco de Dados (futuro, subnets privadas)
# Aceita PostgreSQL apenas de dentro da VPC
# ============================================================

resource "aws_security_group" "database" {
  name        = "${local.name_prefix}-sg-db"
  description = "Security Group do banco PostgreSQL - acesso restrito a VPC"
  vpc_id      = aws_vpc.technova.id

  # PostgreSQL — somente de dentro da VPC (10.0.0.0/16)
  ingress {
    description = "PostgreSQL apenas da VPC interna"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Egress: todo o trafego permitido
  egress {
    description = "Todo o trafego de saida permitido"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-sg-db"
    Tier = "private"
  }

  lifecycle {
    create_before_destroy = true
  }
}
