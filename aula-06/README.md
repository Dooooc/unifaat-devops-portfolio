# Aula 06 - Biblioteca de Modulos Terraform TechNova

**Disciplina:** DevOps - UniFAAT 2026-2
**Aluno:** Yuri Batista Sanches - RA 6325238
**Objetivo:** Criar uma biblioteca de modulos reutilizaveis para provisionar ambientes completos (dev + staging) com os mesmos modulos e variaveis diferentes.

---

## Visao Geral

Esta biblioteca fornece quatro modulos independentes e compostos:

| Modulo | Descricao |
|---|---|
| `modules/vpc` | VPC com subnets dinamicas via `for_each`, IGW e route tables |
| `modules/security-group` | Security Group generico que aceita regras como lista de objetos |
| `modules/ec2` | Instancia EC2 configuravel com AMI, SG, subnet e user_data opcionais |
| `modules/rds` | DB Subnet Group + instancia RDS PostgreSQL 15 em subnets privadas |

---

## Arquitetura

```
environments/
  dev/main.tf
  staging/main.tf
      |
      |-- module "vpc"          --> VPC + subnets + IGW + route tables
      |       |
      |       +--> vpc_id       --> module "api_sg" (vpc_id)
      |       +--> vpc_id       --> module "rds_sg" (vpc_id)
      |       +--> public_subnet_ids[0]  --> module "api_server" (subnet_id)
      |       +--> private_subnet_ids    --> module "database" (subnet_ids)
      |
      |-- module "api_sg"       --> SG da EC2 (SSH + 3000)
      |       |
      |       +--> sg_id        --> module "api_server" (security_group_ids)
      |       +--> sg_id        --> module "rds_sg" ingress_rules
      |
      |-- module "rds_sg"       --> SG do RDS (5432 apenas do api_sg)
      |       |
      |       +--> sg_id        --> module "database" (security_group_ids)
      |
      |-- module "api_server"   --> EC2 t2.micro na subnet publica
      |
      +-- module "database"     --> RDS PostgreSQL nas subnets privadas
```

---

## Modulos Disponiveis

### Modulo VPC (`modules/vpc`)

**Descricao:** Cria VPC completa com subnets dinamicas (`for_each`), IGW e route tables publica/privada.

**Inputs:**

| Nome | Tipo | Obrigatorio | Descricao |
|---|---|---|---|
| `vpc_cidr` | string | Sim | CIDR block da VPC |
| `project_name` | string | Sim | Nome do projeto |
| `environment` | string | Sim | Ambiente (dev, staging) |
| `subnets` | map(object) | Sim | Mapa de subnets com `cidr`, `az` e `type` |

**Outputs:**

| Nome | Descricao |
|---|---|
| `vpc_id` | ID da VPC criada |
| `vpc_cidr` | CIDR block da VPC |
| `public_subnet_ids` | Lista de IDs das subnets publicas |
| `private_subnet_ids` | Lista de IDs das subnets privadas |
| `internet_gateway_id` | ID do Internet Gateway |

**Exemplo de uso:**
```hcl
module "vpc" {
  source       = "../../modules/vpc"
  vpc_cidr     = "10.0.0.0/16"
  project_name = "technova"
  environment  = "dev"
  subnets = {
    "public-1"  = { cidr = "10.0.1.0/24", az = "us-east-1a", type = "public" }
    "private-1" = { cidr = "10.0.3.0/24", az = "us-east-1a", type = "private" }
    "private-2" = { cidr = "10.0.4.0/24", az = "us-east-1b", type = "private" }
  }
}
```

---

### Modulo Security Group (`modules/security-group`)

**Descricao:** Security Group generico. Aceita qualquer lista de regras de ingress como objetos.

**Inputs:**

| Nome | Tipo | Obrigatorio | Descricao |
|---|---|---|---|
| `name` | string | Sim | Nome do Security Group |
| `description` | string | Nao | Descricao (default: "Managed by Terraform") |
| `vpc_id` | string | Sim | ID da VPC |
| `ingress_rules` | list(object) | Nao | Regras de entrada |
| `environment` | string | Sim | Ambiente |
| `project_name` | string | Sim | Nome do projeto |

**Outputs:**

| Nome | Descricao |
|---|---|
| `sg_id` | ID do Security Group criado |
| `sg_name` | Nome do Security Group criado |

**Exemplo de uso:**
```hcl
module "api_sg" {
  source       = "../../modules/security-group"
  name         = "technova-dev-sg-api"
  vpc_id       = module.vpc.vpc_id
  project_name = "technova"
  environment  = "dev"
  ingress_rules = [
    {
      description     = "SSH administrativo"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
    }
  ]
}
```

---

### Modulo EC2 (`modules/ec2`)

**Descricao:** Instancia EC2 configuravel. AMI, subnet, SGs e user_data via variaveis.

**Inputs:**

| Nome | Tipo | Obrigatorio | Descricao |
|---|---|---|---|
| `instance_name` | string | Sim | Nome da instancia |
| `instance_type` | string | Nao | Tipo (default: t2.micro) |
| `ami_id` | string | Sim | ID da AMI |
| `subnet_id` | string | Sim | Subnet onde criar a instancia |
| `security_group_ids` | list(string) | Sim | Lista de SG IDs |
| `key_name` | string | Sim | Nome do key pair SSH |
| `iam_instance_profile` | string | Nao | Instance profile (default: LabInstanceProfile) |
| `user_data` | string | Nao | Script de inicializacao |
| `root_volume_size` | number | Nao | Tamanho do volume raiz em GB (default: 30) |
| `environment` | string | Sim | Ambiente |
| `project_name` | string | Sim | Nome do projeto |

**Outputs:**

| Nome | Descricao |
|---|---|
| `instance_id` | ID da instancia EC2 |
| `public_ip` | IP publico |
| `private_ip` | IP privado |
| `public_dns` | DNS publico |


**Exemplo de uso:**
```hcl
module "api_server" {
  source             = "../../modules/ec2"
  instance_name      = "technova-dev-api"
  instance_type      = "t2.micro"
  ami_id             = data.aws_ami.amazon_linux_2023.id
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.api_sg.sg_id]
  key_name           = "vockey"
  project_name       = "technova"
  environment        = "dev"
}
```

---
### Modulo RDS (`modules/rds`)

**Descricao:** DB Subnet Group + instancia RDS PostgreSQL 15 em subnets privadas.

**Inputs:**

| Nome | Tipo | Obrigatorio | Descricao |
|---|---|---|---|
| `db_name` | string | Sim | Nome do banco de dados |
| `db_username` | string | Sim | Usuario master (sensitive) |
| `db_password` | string | Sim | Senha master, minimo 8 chars (sensitive) |
| `subnet_ids` | list(string) | Sim | Subnets privadas para DB Subnet Group |
| `security_group_ids` | list(string) | Sim | SGs para o RDS |
| `instance_class` | string | Nao | Classe da instancia (default: db.t3.micro) |
| `engine_version` | string | Nao | Versao do PostgreSQL (default: "15") |
| `allocated_storage` | number | Nao | Armazenamento em GB (default: 20) |
| `environment` | string | Sim | Ambiente |
| `project_name` | string | Sim | Nome do projeto |

**Outputs:**

| Nome | Descricao |
|---|---|
| `db_endpoint` | Endpoint completo (host:porta) |
| `db_address` | Hostname do RDS |
| `db_name` | Nome do banco de dados |
| `db_port` | Porta do PostgreSQL |
| `db_instance_id` | Identificador da instancia RDS |


**Exemplo de uso:**
```hcl
module "database" {
  source             = "../../modules/rds"
  db_name            = "technova_dev"
  db_username        = "technova_admin"
  db_password        = var.db_password
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.rds_sg.sg_id]
  instance_class     = "db.t3.micro"
  project_name       = "technova"
  environment        = "dev"
}
```

---
## Comparativo dos Ambientes

| Aspecto | Dev | Staging |
|---|---|---|
| VPC CIDR | 10.0.0.0/16 | 10.1.0.0/16 |
| Subnets Publicas | 10.0.1.0/24, 10.0.2.0/24 | 10.1.1.0/24, 10.1.2.0/24 |
| Subnets Privadas | 10.0.3.0/24, 10.0.4.0/24 | 10.1.3.0/24, 10.1.4.0/24 |
| EC2 | t2.micro | t2.micro |
| RDS | db.t3.micro | db.t3.micro |
| DB Name | technova_dev | technova_staging |
| Naming | technova-dev-* | technova-staging-* |

---

## Pre-requisitos

- Terraform >= 1.5.0
- AWS CLI configurado (ou `source aws-creds.sh`)
- Credenciais do AWS Academy Learner Lab ativas
- Key pair `vockey` disponivel na conta (baixe `labsuser.pem` em AWS Details)

---

## Como Usar

### Subir ambiente dev

```bash
cd environments/dev

# Editar terraform.tfvars e definir db_password
cp terraform.tfvars terraform.tfvars.bak
# Edite terraform.tfvars com sua senha

terraform init
terraform plan
terraform apply
```

### Subir ambiente staging

```bash
cd environments/staging

# Editar terraform.tfvars e definir db_password
terraform init
terraform plan
terraform apply
```

### Verificar outputs apos apply

```bash
terraform output ec2_public_ip
terraform output rds_endpoint
terraform output ssh_command
```

---

## Criar um Novo Ambiente

Para criar um terceiro ambiente (ex: production), basta:

1. Copiar a pasta `environments/dev/` para `environments/production/`
2. Ajustar os CIDRs em `main.tf` (ex: `10.2.0.0/16`)
3. Ajustar `db_name` para `technova_production`
4. Atualizar `terraform.tfvars` com `environment = "production"`
5. Rodar `terraform init && terraform apply`

Os modulos nao precisam ser alterados.

---

## O que NAO commitar

- `terraform.tfvars` - contem senha do banco
- `*.tfstate` / `.terraform/` - gerenciados localmente ou por remote state
- `*.pem` / `aws-creds.sh` - credenciais