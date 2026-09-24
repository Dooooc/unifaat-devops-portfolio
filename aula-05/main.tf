# ============================================================
# LOCALS
# ============================================================

locals {
  name_prefix = "technova"
}

# ============================================================
# DATA SOURCES
# ============================================================

# AMI mais recente do Amazon Linux 2023
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

# ============================================================
# VPC
# ============================================================

resource "aws_vpc" "technova" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true # obrigatório para o RDS endpoint resolver

  tags = {
    Name    = "${local.name_prefix}-vpc"
    Project = "TechNova"
    Aula    = "05"
  }
}

# ============================================================
# SUBNET PÚBLICA — EC2 (1 AZ)
# ============================================================

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.technova.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name    = "${local.name_prefix}-subnet-public-${count.index + 1}"
    Tier    = "public"
    AZ      = var.availability_zones[count.index]
    Project = "TechNova"
    Aula    = "05"
  }
}

# ============================================================
# SUBNETS PRIVADAS — RDS (2 AZs obrigatórias para DB Subnet Group)
# ============================================================

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id                  = aws_vpc.technova.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name    = "${local.name_prefix}-subnet-private-${count.index + 1}"
    Tier    = "private"
    AZ      = var.availability_zones[count.index]
    Project = "TechNova"
    Aula    = "05"
  }
}

# ============================================================
# INTERNET GATEWAY
# ============================================================

resource "aws_internet_gateway" "technova" {
  vpc_id = aws_vpc.technova.id

  tags = {
    Name    = "${local.name_prefix}-igw"
    Project = "TechNova"
    Aula    = "05"
  }
}

# ============================================================
# ROUTE TABLE PÚBLICA — rota padrão via IGW
# ============================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.technova.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.technova.id
  }

  tags = {
    Name    = "${local.name_prefix}-rtb-public"
    Tier    = "public"
    Project = "TechNova"
    Aula    = "05"
  }
}

# Associar a route table pública à subnet pública
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ============================================================
# ROUTE TABLE PRIVADA — subnets do RDS ficam sem rota para internet
# (isolamento de segurança — o RDS nunca fica exposto)
# ============================================================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.technova.id

  tags = {
    Name    = "${local.name_prefix}-rtb-private"
    Tier    = "private"
    Project = "TechNova"
    Aula    = "05"
  }
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
