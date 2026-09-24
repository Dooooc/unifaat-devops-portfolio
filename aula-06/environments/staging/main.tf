# ============================================================
# Ambiente STAGING — composicao dos modulos TechNova
# Mesmos modulos que dev, CIDRs e nomes diferentes
# ============================================================

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# ── Modulo VPC ───────────────────────────────────────────────
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr     = "10.1.0.0/16"
  project_name = var.project_name
  environment  = var.environment

  subnets = {
    "public-1"  = { cidr = "10.1.1.0/24", az = "us-east-1a", type = "public" }
    "public-2"  = { cidr = "10.1.2.0/24", az = "us-east-1b", type = "public" }
    "private-1" = { cidr = "10.1.3.0/24", az = "us-east-1a", type = "private" }
    "private-2" = { cidr = "10.1.4.0/24", az = "us-east-1b", type = "private" }
  }
}

# ── Modulo Security Group — EC2/API ─────────────────────────
module "api_sg" {
  source = "../../modules/security-group"

  name         = "${var.project_name}-${var.environment}-sg-api"
  description  = "SG da API TechNova Staging - SSH e porta 3000"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  environment  = var.environment

  ingress_rules = [
    {
      description     = "SSH administrativo"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    },
    {
      description     = "API Node.js porta 3000"
      from_port       = 3000
      to_port         = 3000
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
}

# ── Modulo Security Group — RDS ──────────────────────────────
module "rds_sg" {
  source = "../../modules/security-group"

  name         = "${var.project_name}-${var.environment}-sg-rds"
  description  = "SG do RDS TechNova Staging - PostgreSQL apenas da EC2"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  environment  = var.environment

  ingress_rules = [
    {
      description     = "PostgreSQL apenas da EC2"
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      cidr_blocks     = []
      security_groups = [module.api_sg.sg_id]
    }
  ]
}

# ── Modulo EC2 ───────────────────────────────────────────────
module "api_server" {
  source = "../../modules/ec2"

  instance_name      = "${var.project_name}-${var.environment}-api"
  instance_type      = "t2.micro"
  ami_id             = data.aws_ami.amazon_linux_2023.id
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.api_sg.sg_id]
  key_name           = "vockey"
  project_name       = var.project_name
  environment        = var.environment

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    dnf install -y postgresql15
    curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
    yum install -y nodejs git
    echo "TechNova Staging setup concluido" >> /var/log/setup.log
  EOF
}

# ── Modulo RDS ───────────────────────────────────────────────
module "database" {
  source = "../../modules/rds"

  db_name            = "technova_staging"
  db_username        = "technova_admin"
  db_password        = var.db_password
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.rds_sg.sg_id]
  instance_class     = "db.t3.micro"
  project_name       = var.project_name
  environment        = var.environment
}