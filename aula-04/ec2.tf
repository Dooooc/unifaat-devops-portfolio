# ============================================================
# TLS PRIVATE KEY — gerada pelo Terraform, salva localmente
# ============================================================

resource "tls_private_key" "technova" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# ============================================================
# KEY PAIR AWS — importa a chave pública gerada acima
# ============================================================

resource "aws_key_pair" "technova" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.technova.public_key_openssh

  tags = {
    Name = "${local.name_prefix}-key-pair"
  }
}

# ============================================================
# SALVAR CHAVE PRIVADA LOCALMENTE (.pem)
# ATENÇÃO: o arquivo .pem é ignorado pelo .gitignore
# ============================================================

resource "local_sensitive_file" "private_key_pem" {
  content         = tls_private_key.technova.private_key_pem
  filename        = "${path.module}/technova-key.pem"
  file_permission = "0400" # Somente leitura pelo owner (exigido pelo SSH)
}

# ============================================================
# USER DATA — script de inicialização da instância EC2
# Executado como root na primeira inicialização
# ============================================================

locals {
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # ── Atualizar sistema ────────────────────────────────────
    yum update -y

    # ── Instalar Node.js 18 via NodeSource ───────────────────
    curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
    yum install -y nodejs

    # ── Instalar Git ─────────────────────────────────────────
    yum install -y git

    # ── Criar diretório da aplicação ─────────────────────────
    mkdir -p /opt/technova
    cd /opt/technova

    # ── Clonar repositório da API TechNova ───────────────────
    git clone ${var.app_repo_url} app || {
      # Fallback: criar API mínima caso o repositório não exista
      mkdir -p app
      cd app
      cat > package.json <<'PKG'
    {
      "name": "technova-api",
      "version": "1.0.0",
      "description": "TechNova API - Aula 04 DevOps UniFAAT",
      "main": "index.js",
      "scripts": { "start": "node index.js" },
      "dependencies": { "express": "^4.18.2" }
    }
    PKG
      cat > index.js <<'APP'
    const express = require('express');
    const app = express();
    const PORT = process.env.PORT || 3000;

    app.get('/', (req, res) => {
      res.json({
        message: 'TechNova API - Aula 04 funcionando!',
        version: '1.0.0',
        environment: process.env.NODE_ENV || 'development',
        timestamp: new Date().toISOString()
      });
    });

    app.get('/health', (req, res) => {
      res.json({
        status: 'healthy',
        uptime: process.uptime(),
        timestamp: new Date().toISOString()
      });
    });

    app.listen(PORT, '0.0.0.0', () => {
      console.log('TechNova API rodando na porta ' + PORT);
    });
    APP
      cd /opt/technova
    }

    # ── Instalar dependências ────────────────────────────────
    cd /opt/technova/app
    npm install --production

    # ── Criar usuário dedicado para a aplicação ──────────────
    useradd -r -s /bin/false technova || true
    chown -R technova:technova /opt/technova

    # ── Criar serviço systemd para inicialização automática ──
    cat > /etc/systemd/system/technova-api.service <<'SERVICE'
    [Unit]
    Description=TechNova API Service
    After=network.target

    [Service]
    Type=simple
    User=technova
    WorkingDirectory=/opt/technova/app
    ExecStart=/usr/bin/node index.js
    Restart=on-failure
    RestartSec=10
    StandardOutput=journal
    StandardError=journal
    SyslogIdentifier=technova-api
    Environment=NODE_ENV=production
    Environment=PORT=3000

    [Install]
    WantedBy=multi-user.target
    SERVICE

    # ── Habilitar e iniciar o serviço ────────────────────────
    systemctl daemon-reload
    systemctl enable technova-api
    systemctl start technova-api

    echo "=== TechNova API inicializada com sucesso ===" >> /var/log/technova-setup.log
    date >> /var/log/technova-setup.log
  EOF
}

# ============================================================
# INSTÂNCIA EC2
# ============================================================

resource "aws_instance" "api" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id # subnet pública na AZ-1
  vpc_security_group_ids = [aws_security_group.api.id]
  key_name               = aws_key_pair.technova.key_name
  iam_instance_profile   = data.aws_iam_instance_profile.lab_instance_profile.name

  user_data_base64            = base64encode(local.user_data)
  user_data_replace_on_change = true # força recreate se o user_data mudar

  # Volume raiz — gp3 é mais performático e mais barato que gp2
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name = "${local.name_prefix}-ec2-api-root-volume"
    }
  }

  tags = {
    Name = "${local.name_prefix}-ec2-api"
    Tier = "public"
    Role = "api-server"
  }

  # Dependência explícita: garante que o IGW existe antes do EC2
  # (sem isso, o EC2 pode subir sem conectividade de saída)
  depends_on = [aws_internet_gateway.technova]
}
