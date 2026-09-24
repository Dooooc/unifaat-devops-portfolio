#!/bin/bash
set -e
exec > /var/log/technova-setup.log 2>&1

echo "=== TechNova Aula 05 - Setup iniciado: $(date) ==="

# -- Atualizar sistema
yum update -y

# -- Instalar PostgreSQL 15 client (psql)
dnf install -y postgresql15

# -- Instalar Node.js 18 via NodeSource
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs git

# -- Criar aplicação mínima TechNova
mkdir -p /opt/technova/app

cat > /opt/technova/app/package.json <<'PKG'
{
  "name": "technova-api",
  "version": "1.0.0",
  "description": "TechNova API - Aula 05 DevOps UniFAAT",
  "main": "index.js",
  "scripts": { "start": "node index.js" },
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.11.0"
  }
}
PKG

cat > /opt/technova/app/index.js <<'APP'
const express = require('express');
const { Pool } = require('pg');
const app = express();
const PORT = process.env.PORT || 3000;

const pool = new Pool({
  host:     process.env.DB_HOST,
  port:     parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME,
  user:     process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl:      { rejectUnauthorized: false }
});

app.get('/', (req, res) => {
  res.json({
    message: 'TechNova API - Aula 05 funcionando!',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', uptime: process.uptime(), timestamp: new Date().toISOString() });
});

app.get('/db-health', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW() as current_time, version() as pg_version');
    res.json({ status: 'connected', db: result.rows[0] });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log('TechNova API rodando na porta ' + PORT);
});
APP

cd /opt/technova/app
npm install --production

# -- Criar usuario dedicado
useradd -r -s /bin/false technova || true
chown -R technova:technova /opt/technova

# -- Servico systemd
cat > /etc/systemd/system/technova-api.service <<SERVICE
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
Environment=DB_HOST=${rds_endpoint}
Environment=DB_PORT=${db_port}
Environment=DB_NAME=${db_name}
Environment=DB_USER=${db_user}
Environment=DB_PASSWORD=${db_password}

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable technova-api
systemctl start technova-api

echo "=== Setup concluido com sucesso: $(date) ==="
