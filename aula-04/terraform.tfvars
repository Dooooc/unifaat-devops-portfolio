# ============================================================
# VALORES DAS VARIÁVEIS — Aula 04 TechNova
# Ajuste aws_region e ssh_allowed_cidr antes de executar
# ============================================================

# Região AWS (AWS Academy Learner Lab usa us-east-1)
aws_region = "us-east-1"

# Ambiente
environment = "development"

# Identificação do aluno
student_ra   = "6325238"
student_name = "Yuri"

# ── Rede ────────────────────────────────────────────────────
vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs  = ["10.0.1.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.2.0/24", "10.0.4.0/24"]

availability_zones = ["us-east-1a", "us-east-1b"]

# ── EC2 ─────────────────────────────────────────────────────
instance_type = "t2.micro"
key_pair_name = "technova-key"
api_port      = 3000

# ATENÇÃO: em produção, substitua por seu IP específico (ex: "203.0.113.10/32")
# Use "0.0.0.0/0" apenas para fins de laboratório
ssh_allowed_cidr = "0.0.0.0/0"

# URL do repositório da API — ajuste para o seu fork se necessário
app_repo_url = "https://github.com/Dooooc/technova-api.git"
