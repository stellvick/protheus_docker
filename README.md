# openSUSE Leap 15.4 Docker para Coolify

Containerização completa de openSUSE Leap 15.4 com suporte a HTTPS, otimizado para ser usado com **Coolify**.

## 📋 Requisitos

- Docker >= 20.10
- Docker Compose >= 1.29
- Coolify >= 3.0 (opcional)

## 🚀 Quick Start

### 1. Clonar/Preparar o repositório

```bash
cd /Users/igorrabelo/Documents/GIT/protheus_docker
```

### 2. Criar estrutura de diretórios

```bash
mkdir -p ssl/certs ssl/private data logs
```

### 3. Gerar certificados SSL/TLS (auto-assinado)

```bash
# Gerar chave privada
openssl genrsa -out ssl/private/key.pem 2048

# Gerar certificado
openssl req -new -x509 -key ssl/private/key.pem \
  -out ssl/certs/cert.pem -days 365 \
  -subj "/C=BR/ST=SP/L=Sao Paulo/O=MyOrg/CN=localhost"
```

### 4. Build da imagem

```bash
docker-compose build
```

### 5. Iniciar os containers

```bash
# Em foreground (para ver logs)
docker-compose up

# Em background
docker-compose up -d
```

### 6. Verificar status

```bash
docker-compose ps
docker-compose logs -f
```

## 🔐 Configuração HTTPS

### Com Certificados Let's Encrypt (Recomendado)

1. Use o Coolify para gerar certificados automaticamente
2. Ou configure um webhook para renovação automática

### Com Certificados Auto-assinados

Já incluído no quick start acima.

### Com Certificados Customizados

```bash
# Copiar seus certificados para:
cp /caminho/para/cert.pem ssl/certs/
cp /caminho/para/key.pem ssl/private/
```

## 📁 Estrutura de Diretórios

```
protheus_docker/
├── Dockerfile                 # Imagem Docker base
├── docker-compose.yml         # Configuração Docker Compose (desenvolvimento)
├── entrypoint.sh             # Script de inicialização
├── .dockerignore             # Arquivos ignorados no build
├── .env                      # Variáveis de ambiente
├── README.md                 # Este arquivo
├── data/                     # Dados persistentes
├── logs/                     # Logs da aplicação
└── ssl/                      # Certificados SSL/TLS
    ├── certs/               # Certificados públicos
    └── private/             # Chaves privadas
```

## 🔧 Variáveis de Ambiente

Edite o arquivo `.env` para customizar:

```env
TZ=America/Sao_Paulo
NODE_ENV=production
LOG_LEVEL=info
```

## 📊 Portas Expostas

| Porta | Protocolo | Descrição |
|-------|-----------|-----------|
| 80    | HTTP      | Redireciona para HTTPS |
| 443   | HTTPS     | Proxy reverso SSL/TLS |
| 3000  | HTTP      | Aplicação interna |

## 🛑 Parar os containers

```bash
docker-compose down

# Remover volumes também
docker-compose down -v
```

## 📝 Logs

```bash
# Todos os logs
docker-compose logs -f

# Apenas da aplicação
docker-compose logs -f app

# Apenas do nginx
docker-compose logs -f nginx-ssl
```

## 🔄 Reiniciar

```bash
docker-compose restart
```

## 🐛 Troubleshooting

### Verificar saúde do container

```bash
docker-compose ps
```

### Entrar no container

```bash
docker-compose exec app /bin/bash
```

### Rebuild completo

```bash
docker-compose down
docker system prune
docker-compose build --no-cache
docker-compose up -d
```

## 📦 Instalação de Pacotes

Como openSUSE usa `zypper`:

```bash
# Dentro do container
zypper refresh
zypper install <pacote>
```

Ou adicione ao Dockerfile:

```dockerfile
RUN zypper install -y <pacote>
```

## 🔒 Segurança

- ✅ Redução de privilégios (no-new-privileges)
- ✅ Drop de capabilities não essenciais
- ✅ HTTPS obrigatório
- ✅ Health checks automáticos
- ✅ Limites de recursos configuráveis
- ✅ Logging centralizado

## 🎯 Integração com Coolify

1. Faça push do repositório para GitHub/GitLab
2. No Coolify, crie uma nova aplicação
3. Selecione o tipo "Docker Compose"
4. Aponte para este repositório
5. Configure domínio e certificados
6. Deploy automático

## 📚 Referências

- [openSUSE Leap 15.4](https://www.opensuse.org)
- [Docker Documentation](https://docs.docker.com)
- [Coolify Documentation](https://coolify.io)
- [Nginx Documentation](https://nginx.org/en/docs/)

## 📄 Licença

MIT

---

**Criado para**: Protheus + Docker + Coolify
**Versão**: 1.0.0
