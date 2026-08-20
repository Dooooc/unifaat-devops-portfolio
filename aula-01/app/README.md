gi# Aula 01 — Fundamentos de Git e Docker

## O que aprendi

 1. **Repositório:** local onde o Git armazena e controla as versões dos arquivos de um projeto.
2. **Commit:** registra as alterações feitas no projeto, permitindo acompanhar o histórico.
3. **Branch:** permite criar ramificações para desenvolver funcionalidades sem alterar diretamente a versão principal.
4. **Push e Pull:** `push` envia alterações para o GitHub, enquanto `pull` baixa alterações do repositório remoto.

1. **Container:** ambiente isolado que executa uma aplicação e suas dependências.
2. **Imagem:** modelo usado para criar containers, contendo a aplicação e tudo o que ela precisa para funcionar.
3. **Dockerfile:** arquivo com instruções para criar uma imagem Docker personalizada.
4. **Docker Compose:** ferramenta que permite configurar e executar vários containers juntos, como uma aplicação e seu banco de dados.


## Comandos Git praticados

git init, git add . , git commit -m""

## Comandos Docker praticados

docker build
docker run

## Como executar este container

```bash
cd aula-01/app
docker build -t portfolio-aula01:1.0 .
docker run -d -p 3000:3000 portfolio-aula01:1.0
curl http://localhost:3000