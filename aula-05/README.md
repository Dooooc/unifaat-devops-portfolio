# Aula 05 — Infraestrutura Completa com Data Layer e Remote State

**Disciplina:** DevOps — UniFAAT 2026-2  
**Aluno:** Yuri Batista Sanches — RA 6325238  
**Objetivo:** Provisionar a infraestrutura completa da TechNova com RDS PostgreSQL, EC2 e Remote State em S3 + DynamoDB.

---

## Arquitetura

```
Internet
    │
    ▼
[Internet Gateway]
    │
    ▼
[Subnet Pública 10.0.1.0/24 — us-east-1a]
    │
    └── [EC2 t2.micro] ──── SG: porta 22 (SSH) + 3000 (API)
            │
            │ porta 5432 (SG reference)
            ▼
    [Subnet Privada 10.0.2.0/24 — us-east-1a]
    [Subnet Privada 10.0.4.0/24 — us-east-1b]
            │
            └── [RDS PostgreSQL 15 db.t3.micro]
                    SG: apenas do SG da EC2


Remote State:
  S3 Bucket: technova-tfstate-6325238
    └── aula-05/terraform.tfstate
  DynamoDB: technova-tfstate-lock (LockID)
```

---

## Estrutura de Arquivos

| Arquivo | Responsabilidade |
|---|---|
| `providers.tf` | Provider AWS + backend S3/DynamoDB |
| `variables.tf` | Declaração de todas as variáveis |
| `main.tf` | VPC, subnets, IGW, route tables |
| `security-groups.tf` | SGs da EC2 e do RDS (encadeados por SG reference) |
| `rds.tf` | DB Subnet Group + instância RDS PostgreSQL 15 |
| `ec2.tf` | Key pair, EC2 com user_data via templatefile |
| `user_data.tpl` | Script de bootstrap: instala psql + Node.js + API |
| `remote-state.tf` | Bucket S3 + tabela DynamoDB para remote state |
| `iam.tf` | Data sources: LabRole + LabInstanceProfile |
| `outputs.tf` | Outputs: RDS endpoint, EC2 IP, connection string |
| `terraform.tfvars.example` | Modelo de variáveis (seguro para commitar) |
| `terraform.tfvars` | ⚠️ **Não commitado** — contém senha do banco |

---

## Pré-requisitos

- Terraform >= 1.5.0
- AWS CLI configurado (ou `source aws-creds.sh`)
- Credenciais do AWS Academy Learner Lab ativas

---

## Como Executar

### Passo 1 — Bootstrap do Remote State

O bucket S3 e a tabela DynamoDB precisam existir **antes** de ativar o backend.

```bash
# 1.1 — Comente o bloco backend "s3" em providers.tf
# 1.2 — Inicialize sem backend remoto
terraform init

# 1.3 — Crie apenas os recursos de remote state
terraform apply -target=aws_s3_bucket.tfstate \
                -target=aws_s3_bucket_versioning.tfstate \
                -target=aws_s3_bucket_server_side_encryption_configuration.tfstate \
                -target=aws_s3_bucket_public_access_block.tfstate \
                -target=aws_s3_bucket_policy.tfstate \
                -target=aws_dynamodb_table.tfstate_lock
```

### Passo 2 — Migrar State para S3

```bash
# 2.1 — Descomente o bloco backend "s3" em providers.tf
# 2.2 — Migre o state local para o S3
terraform init -migrate-state
```

### Passo 3 — Provisionar a Infraestrutura Completa

```bash
# 3.1 — Crie o terraform.tfvars a partir do exemplo
cp terraform.tfvars.example terraform.tfvars
# Edite terraform.tfvars e substitua db_password por uma senha segura

# 3.2 — Valide a configuração
terraform validate
terraform plan

# 3.3 — Aplique
terraform apply
```

### Passo 4 — Verificar o Remote State no S3

```bash
# Confirma que o state foi salvo no bucket
aws s3 ls s3://technova-tfstate-6325238/aula-05/ --recursive

# Ou use o output direto:
terraform output verify_state_command
```

### Passo 5 — Testar Conectividade EC2 → RDS

```bash
# Obter dados de conexão
EC2_IP=$(terraform output -raw ec2_public_ip)
RDS_HOST=$(terraform output -raw rds_address)

# SSH na EC2
ssh -i technova-aula05-key.pem ec2-user@$EC2_IP

# Dentro da EC2 — conectar ao RDS via psql
psql -h $RDS_HOST -p 5432 -U technova_admin -d technovadb

# Testar pela API (endpoint /db-health)
curl http://$EC2_IP:3000/db-health
```

---

## Outputs Importantes

Após o `terraform apply`:

| Output | Descrição |
|---|---|
| `ec2_public_ip` | IP público da EC2 |
| `rds_endpoint` | `host:porta` do RDS |
| `rds_address` | Hostname do RDS (para psql) |
| `psql_connection_string` | Comando psql pronto para uso |
| `api_url` | URL da API Node.js |
| `api_db_health_url` | Endpoint que valida conexão com RDS |
| `ssh_command` | Comando SSH completo |
| `state_bucket_name` | Bucket S3 do remote state |
| `verify_state_command` | Comando `aws s3 ls` para evidência |

---

## Destruir a Infraestrutura

```bash
terraform destroy
```

> O `skip_final_snapshot = true` e `deletion_protection = false` permitem destruir o RDS sem intervenção manual — configuração adequada para laboratório.

---

## Segurança Implementada

- **RDS não público:** `publicly_accessible = false`
- **RDS criptografado:** `storage_encrypted = true`
- **SG do RDS restrito:** aceita conexões apenas do SG da EC2 (não da VPC inteira)
- **S3 Block Public Access:** todos os 4 blocos habilitados
- **S3 com versionamento:** permite auditoria e rollback do state
- **S3 com SSE:** criptografia AES256 em repouso
- **S3 policy SSL:** nega requests sem HTTPS
- **Variáveis sensíveis:** `db_password` e `db_username` com `sensitive = true`
- **terraform.tfvars não commitado:** `.gitignore` configurado

---

## ⚠️ O que NÃO está no repositório

- `terraform.tfvars` — contém senha do banco
- `*.tfstate` / `*.tfstate.backup` — state no S3
- `.terraform/` — providers baixados localmente
- `*.pem` — chave privada SSH
- `aws-creds.sh` — credenciais temporárias AWS Academy
