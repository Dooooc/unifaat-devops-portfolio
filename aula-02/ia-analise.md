# Análise do Uso de IA — Aula 02 TF

## Prompt Utilizado

"Crie um docker-compose.yml para uma aplicação Node.js 20 com Express que usa PostgreSQL 15 como banco de dados e Redis 7 como cache. A API roda na porta 3000. O PostgreSQL precisa de volume nomeado para persistência. Todos os serviços devem estar na mesma rede bridge customizada. Use variáveis de ambiente com interpolação de arquivo .env. Adicione healthchecks, depends_on com condition, e restart policy unless-stopped."

## Output Original do Kiro

version: '3.9'

services:
  api:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_USER=postgres
      - DB_PASSWORD=postgres
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_started
    restart: unless-stopped
    networks:
      - app-net

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=technova
    volumes:
      - db-data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped
    networks:
      - app-net

  redis:
    image: redis:7
    ports:
      - "6379:6379"
    restart: unless-stopped
    networks:
      - app-net

volumes:
  db-data:

networks:
  app-net:
    driver: bridge

## Alterações que Fiz Manualmente

|| O que mudei                                                                 | Por quê                                                                                                       |                                 |                                                                                       |
| --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- | ------------------------------- | ------------------------------------------------------------------------------------- |
| Corrigi o healthcheck da API, trocando `CMD` por `CMD-SHELL`                | Para permitir a execução correta do comando com shell e garantir o código de saída do healthcheck.            |                                 |                                                                                       |
| Corrigi o healthcheck do Redis, trocando `CMD` por `CMD-SHELL`              | Para que a variável de senha pudesse ser expandida corretamente dentro do container.                          |                                 |                                                                                       |
| Alterei `${REDIS_PASSWORD}` para `$$REDIS_PASSWORD` no healthcheck do Redis | Para evitar que o Docker Compose tente interpretar a variável antes da execução do container.                 |                                 |                                                                                       |
| Adicionei `grep -q PONG                                                     |                                                                                                               | exit 1` ao healthcheck do Redis | Para confirmar que o Redis realmente respondeu `PONG` e retornar erro caso contrário. |
| Removi o volume `redis_data`                                                | O requisito solicitava volume nomeado apenas para o PostgreSQL, portanto o volume do Redis era desnecessário. |                                 |                                                                                       |


## O que o Kiro Acertou

Criou os três serviços necessários: API, PostgreSQL e Redis.
Utilizou Node.js 20, PostgreSQL 15 e Redis 7.
Configurou a API para utilizar a porta 3000.
Criou um volume nomeado para persistência do PostgreSQL.
Criou uma rede bridge customizada para os serviços.
Utilizou variáveis de ambiente através do .env.
Configurou depends_on com condition: service_healthy.
Adicionou healthchecks aos serviços.
Configurou restart: unless-stopped.

## O que o Kiro Errou ou Omitiu

O healthcheck da API utilizava ${PORT:-3000} em formato CMD, o que poderia causar problemas na execução.
O healthcheck do Redis utilizava ${REDIS_PASSWORD} em formato CMD, podendo causar problemas de interpolação pelo Docker Compose.
Criou um volume redis_data que não era solicitado pela atividade.
O healthcheck do Redis precisava validar explicitamente se a resposta era PONG.

## Minha Avaliação

- **Tempo economizado usando IA:** 1h30
- **Tempo gasto validando/corrigindo:** 1h10
- **Nota para o output da IA (1-10):** 8
- **Usaria novamente para este tipo de tarefa?** sim, ainda fico meio perdido com a ia por falta de conhecimento