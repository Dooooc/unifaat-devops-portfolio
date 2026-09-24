# ============================================================
# LOCALS
# ============================================================

locals {
  # Tags específicas por recurso (complementam as default_tags do provider)
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
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

# ============================================================
# SUBNETS PÚBLICAS — 2 AZs
# ============================================================

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.technova.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-subnet-public-${count.index + 1}"
    Tier = "public"
    AZ   = var.availability_zones[count.index]
  }
}

# ============================================================
# SUBNETS PRIVADAS — 2 AZs
# ============================================================

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id                  = aws_vpc.technova.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.name_prefix}-subnet-private-${count.index + 1}"
    Tier = "private"
    AZ   = var.availability_zones[count.index]
  }
}

# ============================================================
# INTERNET GATEWAY
# ============================================================

resource "aws_internet_gateway" "technova" {
  vpc_id = aws_vpc.technova.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

# ============================================================
# ROUTE TABLE PÚBLICA
# ============================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.technova.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.technova.id
  }

  tags = {
    Name = "${local.name_prefix}-rtb-public"
    Tier = "public"
  }
}

# Associar a route table pública às duas subnets públicas
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ============================================================
# ROUTE TABLE PRIVADA (usa a default — sem rota para internet)
# As subnets privadas ficam associadas à route table default da VPC,
# que não possui rota 0.0.0.0/0, garantindo isolamento.
# ============================================================
