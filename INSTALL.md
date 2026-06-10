# 📦 Guia de Instalação

## Pré-requisitos

- **macOS 10.15+** ou **Linux** ou **Windows com WSL2**
- **Docker Desktop** ou **Docker Engine** (v20.10+)
- **Docker Compose** (v1.29+)
- **Git** (v2.0+)
- **OpenSSL** (para certificados)

### Verificar instalação

```bash
# Docker
docker --version
# Docker version 20.10.0 or higher

# Docker Compose
docker-compose --version
# Docker Compose version 1.29.0 or higher

# OpenSSL
openssl version
# OpenSSL 1.1.1 or higher
```

## 1️⃣ Instalação Inicial

### Passo 1: Clonar o repositório

```bash
git clone <seu-repositorio>
cd protheus_docker
```

### Passo 2: Estrutura de diretórios

Os diretórios já vêm criados, mas você pode recriar se necessário:

```bash
mkdir -p ssl/certs ssl/private data logs
chmod 700 ssl/private
```

### Passo 3: Configurar variáveis de ambiente

```bash
# Copiar arquivo de exemplo
cp .env.example .env

# Editar conforme necessário
nano .env  # ou use seu editor favorito
```

### Passo 4: Gerar certificados SSL/TLS

#### Opção A: Script automático

```bash
chmod +x generate-certs.sh
./generate-certs.sh
```

#### Opção B: Comandos manuais

```bash
# Gerar chave privada
openssl genrsa -out ssl/private/key.pem 2048

# Gerar certificado auto-assinado (365 dias)
openssl req -new -x509 -key ssl/private/key.pem \
  -out ssl/certs/cert.pem -days 365 \
  -subj "/C=BR/ST=SP/L=Sao Paulo/O=MyOrg/CN=localhost"

# Ajustar permissões
chmod 600 ssl/private/key.pem
chmod 644 ssl/certs/cert.pem
```

### Passo 5: Build da imagem

```bash
# Build padrão
docker-compose build

# Ou usando Make
make build
```

## 2️⃣ Inicialização

### Iniciar em background

```bash
docker-compose up -d

# Ou
make up
```

### Iniciar em foreground (para ver logs)

```bash
docker-compose up
```

### Verificar status

```bash
docker-compose ps
# Deve mostrar todos os containers como "Up"
```

## 3️⃣ Verificações de Saúde

### Health check

```bash
# Verificar saúde geral
make test

# Ou manualmente
curl -I https://localhost/ || echo "App starting..."
```

### Logs

```bash
# Todos os containers
docker-compose logs -f

# Apenas aplicação
docker-compose logs -f app

# Apenas nginx
docker-compose logs -f nginx-ssl
```

### Entrar no container

```bash
docker-compose exec app /bin/bash

# Verificar openSUSE Leap
cat /etc/os-release

# Verificar pacotes instalados
rpm -qa | head -20
```

## 4️⃣ Desenvolvimento

### Ambiente de desenvolvimento

```bash
docker-compose -f docker-compose.dev.yml up -d

# Ou
make dev
```

### Instalar pacotes adicionais

```bash
# Dentro do container
docker-compose exec app zypper install <pacote>

# Ou adicionar ao Dockerfile e rebuild
```

### Editar arquivos

Os volumes estão configurados para:
- `./data` → `/app/data` (dados persistentes)
- `./logs` → `/app/logs` (logs)
- `./ssl` → `/app/ssl` (certificados)

### Parar desenvolvimento

```bash
make dev-down
```

## 5️⃣ Integração com Coolify

### Preparação

1. Faça commit e push do código:
   ```bash
   git add .
   git commit -m "Initial Docker setup"
   git push origin main
   ```

2. No Coolify:
   - Crie uma nova aplicação
   - Tipo: **Docker Compose**
   - Repository: `<seu-repositorio>`
   - Branch: `main`
   - Compose file: `docker-compose.yml`

### Configuração no Coolify

- **Port mapping**: 443 → 443 (HTTPS)
- **Environment variables**: Carregar de `.env`
- **SSL/TLS**: Coolify gerencia automaticamente
- **Auto-deploy**: Habilitar webhook no Git

## 6️⃣ Gerenciamento

### Reiniciar

```bash
make restart
# Ou
docker-compose restart
```

### Parar

```bash
make down
# Ou
docker-compose down
```

### Remover tudo (incluindo volumes)

```bash
docker-compose down -v
```

### Limpar sistema Docker

```bash
make prune
docker system prune -f
```

## 7️⃣ Troubleshooting

### Porta em uso

```bash
# Encontrar processo usando porta 443
lsof -i :443

# Liberar porta
# kill -9 <PID>
```

### Certificado inválido

```bash
# Limpar e regenerar
rm -rf ssl/certs ssl/private
mkdir -p ssl/certs ssl/private
./generate-certs.sh
docker-compose restart
```

### Container não inicia

```bash
# Ver logs detalhados
docker-compose logs app

# Tentar rebuild
docker-compose down
docker-compose build --no-cache
docker-compose up
```

### Permissões de arquivo

```bash
# Ajustar permissões
chmod 755 generate-certs.sh entrypoint.sh
chmod 700 ssl/private
chmod 644 ssl/certs/*
```

### Limpeza completa

```bash
docker-compose down -v
docker system prune -a -f
docker-compose build --no-cache
docker-compose up -d
```

## 📊 Recursos

### Limites padrão

No `docker-compose.yml`:
- CPU: 2 cores (limite) / 1 core (reservado)
- Memória: 2GB (limite) / 1GB (reservado)

Para modificar, edite a seção `deploy.resources`.

### Espaço em disco

```bash
# Ver uso
docker system df

# Limpar
docker system prune
```

## 🔐 Segurança

### Boas práticas

- ✅ Gerar novos certificados para produção
- ✅ Usar certificados Let's Encrypt com Coolify
- ✅ Manter `.env` protegido
- ✅ Não commitar `ssl/private/*`
- ✅ Usar secrets do Coolify para senhas
- ✅ Manter Docker atualizado

### Certificado Let's Encrypt

No Coolify:
1. Vá para configurações do domínio
2. Selecione "Let's Encrypt"
3. Configure webhook para renovação automática

## 📚 Comandos úteis

```bash
# Validar configuração
docker-compose config

# Listar imagens
docker images | grep opensuse

# Histórico de containers
docker ps -a

# Remover imagem
docker rmi opensuse-leap:15.4

# Push para Docker Hub (se desejado)
docker tag opensuse-leap:15.4 <seu-usuario>/opensuse-leap:15.4
docker push <seu-usuario>/opensuse-leap:15.4
```

## 🎯 Próximos passos

1. **Customizar Dockerfile** para sua aplicação
2. **Adicionar dados** aos volumes
3. **Configurar banco de dados** (PostgreSQL/MySQL)
4. **Integrar com Coolify** para auto-deploy
5. **Monitorar** com ferramentas de observabilidade

## ❓ FAQ

### P: Como mudar a porta padrão?

R: Edite `docker-compose.yml`:
```yaml
ports:
  - "8443:443"  # Mudar porta externa
```

### P: Como adicionar mais serviços?

R: Adicione ao `docker-compose.yml`:
```yaml
  meu_servico:
    image: alpine:latest
    ...
```

### P: Como atualizar a imagem base?

R: Edite o `Dockerfile`:
```dockerfile
FROM opensuse/leap:15.5  # Nova versão
```

### P: Como usar variáveis de ambiente?

R: Use `${VARIAVEL}` no docker-compose.yml e defina no `.env`

## 📞 Suporte

Consulte:
- [Docker Documentation](https://docs.docker.com)
- [openSUSE Leap](https://www.opensuse.org)
- [Coolify Documentation](https://coolify.io)

---

**Versão**: 1.0.0  
**Atualizado**: 2024
