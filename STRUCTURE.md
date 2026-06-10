# 📂 Estrutura do Projeto

Documentação completa da estrutura de arquivos e diretórios do projeto.

## 📋 Visão Geral

```
protheus_docker/
├── 📄 Dockerfile                  # Imagem Docker base (openSUSE Leap 15.4)
├── 📄 docker-compose.yml          # Configuração Docker Compose (padrão)
├── 📄 docker-compose.dev.yml      # Configuração para desenvolvimento
├── 📄 docker-compose.prod.yml     # Configuração otimizada para produção
├── 📄 nginx.conf                  # Configuração do proxy reverso HTTPS
├── 📄 entrypoint.sh               # Script de inicialização do container
├── 📄 generate-certs.sh           # Script para gerar certificados SSL/TLS
├── 📄 init.sh                     # Script de inicialização do projeto
├── 📄 healthcheck.sh              # Script de verificação de saúde
├── 📄 .dockerignore               # Arquivos ignorados no build Docker
├── 📄 .gitignore                  # Arquivos ignorados pelo Git
├── 📄 .env                        # Variáveis de ambiente (local)
├── 📄 .env.example                # Exemplo de variáveis de ambiente
├── 📄 package.json                # Metadados do projeto e scripts npm
├── 📄 Makefile                    # Automação de tarefas comuns
├── 📄 README.md                   # Documentação geral do projeto
├── 📄 INSTALL.md                  # Guia de instalação detalhado
├── 📄 COOLIFY.md                  # Guia de integração com Coolify
├── 📄 STRUCTURE.md                # Este arquivo (estrutura)
├── 📂 data/                       # Dados persistentes da aplicação
│   └── .gitkeep                   # Manter diretório no repositório
├── 📂 logs/                       # Logs da aplicação
│   └── .gitkeep                   # Manter diretório no repositório
├── 📂 ssl/                        # Certificados SSL/TLS
│   ├── 📂 certs/                  # Certificados públicos
│   │   └── .gitkeep               # Manter diretório no repositório
│   └── 📂 private/                # Chaves privadas (NÃO commitar)
│       └── .gitkeep               # Manter diretório no repositório
└── 📂 .git/                       # Repositório Git
```

## 📄 Descrição dos Arquivos

### Dockerfile
**Propósito**: Define a imagem Docker base com openSUSE Leap 15.4

**Conteúdo**:
- Imagem base: `opensuse/leap:15.4`
- Pacotes essenciais: curl, wget, git, openssh, vim, nano, net-tools, etc.
- Timezone: America/Sao_Paulo
- WORKDIR: `/app`
- Health check configurado
- CMD: `/bin/bash`

**Uso**:
```bash
docker build -t opensuse-leap:15.4 .
```

### docker-compose.yml
**Propósito**: Configuração principal para desenvolvimento e produção

**Serviços**:
- `app`: Container openSUSE com aplicação
- `nginx-ssl`: Proxy reverso com suporte a HTTPS

**Volumes**:
- ./data → /app/data
- ./logs → /app/logs
- ./ssl → /app/ssl

**Portas**:
- 80 (HTTP) → Redireciona para HTTPS
- 443 (HTTPS) → Proxy reverso
- 3000 (App) → Aplicação interna

### docker-compose.dev.yml
**Propósito**: Ambiente de desenvolvimento com hot-reload

**Diferenças**:
- Volume montado inteiro: `.:/app`
- PostgreSQL incluído
- Redis incluído
- NODE_ENV=development
- TTY habilitado para interação

**Uso**:
```bash
docker-compose -f docker-compose.dev.yml up
```

### docker-compose.prod.yml
**Propósito**: Configuração otimizada para produção

**Otimizações**:
- Imagem alpine para nginx (menor)
- Limites de CPU e memória
- Healtchecks mais rigorosos
- Logging rotacionado
- Capacidades DROP de segurança

**Uso**:
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### nginx.conf
**Propósito**: Configuração do proxy reverso HTTPS

**Funcionalidades**:
- Redireciona HTTP → HTTPS
- TLS 1.2 e 1.3
- Headers de segurança (HSTS, CSP, etc.)
- Suporta WebSocket (Upgrade header)
- Logging estruturado

**Certificados**:
- ssl_certificate: `/etc/nginx/certs/cert.pem`
- ssl_certificate_key: `/etc/nginx/private/key.pem`

### entrypoint.sh
**Propósito**: Script de inicialização do container

**Responsabilidades**:
- Criar diretórios necessários
- Ajustar permissões
- Exibir informações do sistema
- Executar comando passado

### generate-certs.sh
**Propósito**: Gerar certificados SSL/TLS auto-assinados

**Funcionalidades**:
- Gerar chave privada (2048 bits)
- Gerar certificado (auto-assinado, 365 dias)
- Configurável via variáveis de ambiente
- Validar existência antes de sobrescrever
- Exibir informações do certificado

**Variáveis de Ambiente**:
```bash
COUNTRY=BR                    # País (padrão: BR)
STATE="Sao Paulo"            # Estado (padrão: Sao Paulo)
CITY="Sao Paulo"             # Cidade (padrão: Sao Paulo)
ORG="MyOrganization"         # Organização (padrão: MyOrganization)
CN="localhost"               # Common Name (padrão: localhost)
DAYS=365                     # Dias de validade (padrão: 365)
```

**Uso**:
```bash
./generate-certs.sh
# Ou com variáveis customizadas:
CN="myapp.example.com" ./generate-certs.sh
```

### init.sh
**Propósito**: Script de inicialização completa do projeto

**Etapas**:
1. Criar estrutura de diretórios
2. Copiar .env se não existir
3. Gerar certificados (com confirmação)
4. Ajustar permissões de scripts
5. Validar docker-compose.yml
6. Exibir resumo e próximos passos

**Uso**:
```bash
chmod +x init.sh
./init.sh
```

### healthcheck.sh
**Propósito**: Verificar saúde da aplicação

**Funcionalidades**:
- Suporta curl ou wget
- Fallback: teste de porta TCP
- Retentativas configuráveis
- Logs de diagnóstico

**Variáveis de Ambiente**:
```bash
PORT=3000              # Porta da aplicação
TIMEOUT=10             # Timeout em segundos
RETRIES=3              # Número de tentativas
```

### .dockerignore
**Propósito**: Arquivo ignorado ao fazer build Docker

**Conteúdo**:
- .git
- node_modules
- dist, build
- logs
- .DS_Store
- .vscode, .idea

### .gitignore
**Propósito**: Arquivo ignorado pelo Git

**Conteúdo**:
- .env (variáveis locais)
- node_modules, dist, build
- logs, cache
- ssl/private/* (não commitar chaves)
- .DS_Store, .vscode, .idea

### .env
**Propósito**: Variáveis de ambiente locais (não commitar)

**Variáveis**:
```env
TZ=America/Sao_Paulo
NODE_ENV=production
LOG_LEVEL=info
PORT=3000
SSL_CERT_PATH=/app/ssl/certs/cert.pem
SSL_KEY_PATH=/app/ssl/private/key.pem
```

### .env.example
**Propósito**: Exemplo de variáveis de ambiente (commitar)

**Uso**:
```bash
cp .env.example .env
# Editar conforme necessário
```

### package.json
**Propósito**: Metadados do projeto e scripts npm

**Scripts disponíveis**:
- `npm start`: Iniciar em background
- `npm run dev`: Ambiente de desenvolvimento
- `npm run prod`: Ambiente de produção
- `npm run build`: Build da imagem
- `npm run down`: Parar containers
- `npm run logs`: Ver logs em tempo real
- `npm run certs`: Gerar certificados
- `npm run init`: Inicializar projeto

### Makefile
**Propósito**: Automação de tarefas comuns

**Targets principais**:
```bash
make help       # Ver todos os comandos
make certs      # Gerar certificados
make build      # Build da imagem
make up         # Iniciar containers
make down       # Parar containers
make logs       # Ver logs
make shell      # Entrar no container
make dev        # Ambiente de desenvolvimento
```

### README.md
**Propósito**: Documentação geral do projeto

**Seções**:
- Overview
- Quick Start
- Configuração HTTPS
- Estrutura de diretórios
- Portas expostas
- Variáveis de ambiente
- Monitoramento
- Troubleshooting
- Integração com Coolify

### INSTALL.md
**Propósito**: Guia detalhado de instalação

**Conteúdo**:
- Pré-requisitos
- Instalação inicial (7 passos)
- Desenvolvimento
- Integração com Coolify
- Gerenciamento
- Troubleshooting
- FAQ

### COOLIFY.md
**Propósito**: Guia de integração com Coolify

**Seções**:
- O que é Coolify
- Pré-requisitos
- Configuração no Coolify (8 passos)
- Deploy
- Monitoramento
- Webhooks Git
- Troubleshooting
- Escalabilidade

## 📂 Diretórios

### data/
**Propósito**: Armazenar dados persistentes da aplicação

**Persistência**: Sim (montado como volume)
**Git**: Ignorado (apenas .gitkeep)

### logs/
**Propósito**: Armazenar logs da aplicação

**Persistência**: Sim (montado como volume)
**Limpeza**: Configurada em docker-compose.yml (max-file: 3, max-size: 10m)

### ssl/certs/
**Propósito**: Armazenar certificados públicos SSL/TLS

**Arquivo**: `cert.pem`
**Permissões**: 644 (legível)
**Git**: Ignorado (não commitar certificados)

### ssl/private/
**Propósito**: Armazenar chaves privadas SSL/TLS

**Arquivo**: `key.pem`
**Permissões**: 600 (somente owner)
**Git**: Ignorado (CRÍTICO: nunca commitar)

## 🔐 Permissões de Arquivo

| Arquivo | Permissão | Motivo |
|---------|-----------|--------|
| generate-certs.sh | 755 | Executável |
| entrypoint.sh | 755 | Executável |
| init.sh | 755 | Executável |
| healthcheck.sh | 755 | Executável |
| ssl/private/ | 700 | Apenas owner |
| ssl/private/key.pem | 600 | Apenas owner |
| ssl/certs/cert.pem | 644 | Legível publicamente |
| data/ | 755 | Executável |
| logs/ | 755 | Executável |

## 🔄 Fluxo de Dados

```
Git Repository
    ↓
.git/
    ↓
Dockerfile → docker-compose.yml
    ↓
docker-compose build
    ↓
Docker Image (opensuse-leap:15.4)
    ↓
docker-compose up
    ↓
Container (app + nginx-ssl)
    ↓
Volumes:
- data/     → /app/data
- logs/     → /app/logs
- ssl/      → /app/ssl
```

## 📊 Composição do Projeto

### Por Tipo de Arquivo

| Tipo | Quantidade | Exemplos |
|------|-----------|----------|
| Documentação | 4 | README.md, INSTALL.md, COOLIFY.md, STRUCTURE.md |
| Docker | 4 | Dockerfile, docker-compose.yml, .dockerignore |
| Scripts | 4 | entrypoint.sh, generate-certs.sh, init.sh, healthcheck.sh |
| Configuração | 5 | .env, .env.example, nginx.conf, Makefile, package.json |
| Git | 1 | .gitignore |
| Diretórios | 5 | data/, logs/, ssl/certs/, ssl/private/, .git/ |

### Por Propósito

| Propósito | Arquivos |
|-----------|----------|
| Docker | Dockerfile, docker-compose.yml, .dockerignore |
| Produção | docker-compose.prod.yml |
| Desenvolvimento | docker-compose.dev.yml |
| HTTPS | nginx.conf, generate-certs.sh, ssl/ |
| Inicialização | entrypoint.sh, init.sh |
| Automação | Makefile, package.json |
| Documentação | README.md, INSTALL.md, COOLIFY.md |

## 🚀 Maturidade do Projeto

| Aspecto | Status | Detalhes |
|---------|--------|----------|
| Docker | ✅ Completo | Imagem otimizada, multi-stage pronto |
| Compose | ✅ Completo | Dev, Prod, e padrão configurados |
| HTTPS | ✅ Completo | Nginx + gerador de certs |
| Documentação | ✅ Completo | README, INSTALL, COOLIFY, STRUCTURE |
| Scripts | ✅ Completo | Init, certs, healthcheck, entrypoint |
| Segurança | ✅ Bom | Capacidades dropped, no-new-privileges |
| Monitoramento | ✅ Básico | Healthcheck, logs rotacionados |
| Escalabilidade | ⚠️ Preparado | Limites de recursos configuráveis |

---

**Versão**: 1.0.0  
**Atualizado**: 2024

## 📞 Referências Rápidas

- [Dockerfile Docs](https://docs.docker.com/engine/reference/builder/)
- [Docker Compose Docs](https://docs.docker.com/compose/compose-file/)
- [Nginx Docs](https://nginx.org/en/docs/)
- [openSUSE Leap](https://www.opensuse.org)
