# Protheus Docker (openSUSE Leap 15.4)

Infraestrutura Docker para Protheus TOTVS rodando em openSUSE Leap 15.4 com PostgreSQL 15, otimizado para deploy via Coolify.

## Estrutura

```
├── Dockerfile              # Imagem base opensuse/leap:15.4 + Protheus
├── docker-compose.yml      # Orquestração app + PostgreSQL
├── .env.example            # Template de variáveis de ambiente
├── .dockerignore
├── advpl_config/
│   ├── odbc.ini            # Configuração ODBC (template com placeholders)
│   └── odbcinst.ini        # Driver ODBC PostgreSQL
├── scripts/
│   ├── start.sh            # Entrypoint principal
│   ├── setup-config.sh     # Configura ODBC com variáveis de ambiente
│   ├── setup-permissions.sh # Ajusta permissões dos diretórios
│   └── init-services.sh    # Inicia serviços Protheus
└── README.md
```

## Quick Start

```bash
cp .env.example .env

# Editar .env com suas credenciais

docker compose up -d
```

## Portas

| Porta | Serviço |
|-------|---------|
| 3000 | Protheus (dev) |
| 6000 | License Server |
| 7000 | DBAccess |
| 8000-8010 | AppServers |
| 9000 | AppBroker |
| 5432 | PostgreSQL |

## Variáveis de Ambiente

| Variável | Default | Descrição |
|----------|---------|-----------|
| `DB_HOST` | postgres | Hostname do PostgreSQL |
| `DB_PORT` | 5432 | Porta do PostgreSQL |
| `DB_NAME` | tpprd | Nome do banco de dados |
| `DB_USER` | tpprd | Usuário do banco |
| `DB_PASSWORD` | 123456 | Senha do banco |
| `TZ` | America/Sao_Paulo | Timezone |
| `PROTHEUS_GDRIVE_ID` | 1G6aAGlfbAbLv2u8MicoSzjuCdrYJfvf8 | ID do arquivo no Google Drive |

## Deploy no Coolify

1. Criar novo recurso do tipo **Docker Compose**
2. Apontar para o repositório Git
3. Configurar as variáveis de ambiente no painel do Coolify
4. Deploy

O `setup-config.sh` resolve automaticamente os placeholders do ODBC com as variáveis de ambiente em runtime, garantindo compatibilidade com o DNS interno do Coolify.
