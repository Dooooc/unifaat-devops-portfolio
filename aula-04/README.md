# Infraestrutura TechNova — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** Yuri Batista Sanches
**RA:** 6325238
**Disciplina:** DevOps — UniFAAT 2026-2

---

## Diagrama da Arquitetura

```
                              INTERNET
                                 │
                    ┌────────────┴────────────┐
                    │    Internet Gateway      │
                    │      technova-igw        │
                    └────────────┬────────────┘
                                 │
          ┌──────────────────────▼──────────────────────────┐
          │              technova-vpc  (10.0.0.0/16)         │
          │                                                   │
          │   ┌─────────────────────────────────────────┐    │
          │   │        Route Table Pública               │    │
          │   │     0.0.0.0/0  →  technova-igw          │    │
          │   └──────────┬───────────────────┬──────────┘    │
          │              │                   │               │
          │   ┌──────────▼──────┐ ┌──────────▼──────┐       │
          │   │  subnet-public-1│ │  subnet-public-2│       │
          │   │  10.0.1.0/24   │ │  10.0.3.0/24   │       │
          │   │  us-east-1a    │ │  us-east-1b    │       │
          │   │                │ │                │       │
          │   │ ┌────────────┐ │ │  (future ALB   │       │
          │   │ │EC2 t2.micro│ │ │   ou EC2)      │       │
          │   │ │technova-api│ │ │                │       │
          │   │ │  :22 :3000 │ │ │                │       │
          │   │ │  sg-api    │ │ │                │       │
          │   │ │  IAM Role  │ │ │                │       │
          │   │ └────────────┘ │ │                │       │
          │   └────────────────┘ └────────────────┘       │
          │                                                   │
          │   ┌────────────────┐ ┌────────────────┐          │
          │   │subnet-private-1│ │subnet-private-2│          │
          │   │  10.0.2.0/24  │ │  10.0.4.0/24  │          │
          │   │  us-east-1a   │ │  us-east-1b   │          │
          │   │               │ │               │          │
          │   │  (future DB / │ │  (future DB   │          │
          │   │   RDS)  :5432 │ │   replica)    │          │
          │   │   sg-db       │ │               │          │
          │   └───────────────┘ └───────────────┘          │
          │                                                   │
          │         Route Table Privada (default)             │
          │         sem rota para internet                    │
          └───────────────────────────────────────────────────┘
```

---

## Recursos Criados

| Recurso | Nome | Função |
|---|---|---|
| VPC | technova-vpc | Rede isolada 10.0.0.0/16 com DNS habilitado |
| Subnet pública ×2 | technova-subnet-public-1/2 | Subnets em us-east-1a e us-east-1b com IP público automático |
| Subnet privada ×2 | technova-subnet-private-1/2 | Subnets isoladas para banco de dados futuro |
| Internet Gateway | technova-igw | Saída para a internet |
| Route Table | technova-rtb-public | Rota 0.0.0.0/0 → IGW associada às subnets públicas |
| Security Group | technova-sg-api | Libera SSH (22) e API Node.js (3000) |
| Security Group | technova-sg-db | Libera PostgreSQL (5432) só de dentro da VPC |
| IAM Role | technova-ec2-role | Permite que o EC2 acesse o S3 (ReadOnly) |
| Instance Profile | technova-ec2-instance-profile | Vincula a Role à instância EC2 |
| Key Pair | technova-key | Par de chaves SSH gerado pelo Terraform |
| EC2 | technova-ec2-api | Instância t2.micro rodando a API Node.js na porta 3000 |

---

## Como Usar

### Pré-requisitos
- Terraform >= 1.5.0
- AWS CLI com credenciais do AWS Academy Learner Lab ativas

### Executar

```bash
# 1. Inicializar
terraform init

# 2. Planejar e salvar evidência
terraform plan > evidencia-plan.txt

# 3. Aplicar
terraform apply
```

### Testar a API

Aguarde ~60 segundos após o apply para o user data terminar.

```bash
curl http://<ec2_public_ip>:3000
curl http://<ec2_public_ip>:3000/health
```

### Conectar via SSH

```bash
ssh -i technova-key.pem ec2-user@<ec2_public_ip>
```

### Destruir após evidências

```bash
terraform destroy
```

> ⚠️ Execute o destroy imediatamente após capturar as evidências para evitar custos.
