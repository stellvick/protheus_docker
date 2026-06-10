# ⚡ Quick Start (5 minutos)

Comece em menos de 5 minutos!

## Pré-requisitos

- ✅ Docker & Docker Compose instalados
- ✅ Git instalado
- ✅ OpenSSL instalado (macOS/Linux)

## 🚀 Iniciar Agora

### 1. Clonar Repositório (30s)
```bash
cd /Users/igorrabelo/Documents/GIT/protheus_docker
```

### 2. Inicializar Projeto (30s)
```bash
chmod +x init.sh
./init.sh
```

Este script vai:
- ✅ Criar estrutura de diretórios
- ✅ Gerar certificados SSL/TLS
- ✅ Preparar arquivo .env

### 3. Build (2min)
```bash
make build
# ou: docker-compose build
```

### 4. Iniciar (1min)
```bash
make up
# ou: docker-compose up -d
```

### 5. Acessar (30s)

```bash
# Ver status
make ps

# Ver logs
make logs

# Testar HTTPS
curl -k https://localhost/

# Entrar no container
make shell
```

## 📝 Comandos Úteis

```bash
# Ver todos os comandos
make help

# Desenvolver (com hot-reload)
make dev

# Parar
make down

# Limpar tudo
make clean

# Certificados
make certs

# Logs
make logs
make logs-app
make logs-nginx

# Health check
make test
```

## 🔗 Acessar Aplicação

| Protocolo | URL | Notas |
|-----------|-----|-------|
| HTTP | http://localhost | Redireciona para HTTPS |
| HTTPS | https://localhost | Certificado auto-assinado |
| App | http://localhost:3000 | Porta interna |

## ⚠️ Certificado Auto-assinado

No navegador:
- Click em "Advanced" ou similar
- Accept risk / Proceed anyway
- OK

## 🐛 Problemas?

### Porta em uso
```bash
lsof -i :443
kill -9 <PID>
```

### Recomeçar
```bash
make clean
make init
make build
make up
```

### Ver mais detalhes
Consulte `INSTALL.md` para troubleshooting completo

## 📚 Próximos Passos

1. Editar `.env` conforme necessário
2. Ler `README.md` para overview
3. Ler `COOLIFY.md` para integração
4. Ler `INSTALL.md` para tudo

## 🎯 Coolify?

Se usar Coolify:

1. Push para GitHub/GitLab
2. Leia `COOLIFY.md` (guia completo)
3. No Coolify: New App → Docker Compose → Selecione repo
4. Pronto!

---

**Duvidas?** Consulte `INSTALL.md` ou `README.md`
