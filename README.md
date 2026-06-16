# Protheus Docker (openSUSE Leap 15.4)

Container mínimo openSUSE Leap 15.4 com ODBC PostgreSQL, otimizado para Coolify.

## Estrutura

```
├── Dockerfile
├── docker-compose.yml
├── .env.example
├── .dockerignore
├── advpl_config/
│   ├── odbc.ini
│   └── odbcinst.ini
├── scripts/
│   └── setup-config.sh
└── README.md
```

## Quick Start

```bash
cp .env.example .env
docker compose up -d
```

## Variáveis de Ambiente

| Variável | Default | Descrição |
|----------|---------|-----------|
| `DB_HOST` | postgres | Hostname do PostgreSQL |
| `DB_PORT` | 5432 | Porta do PostgreSQL |
| `DB_NAME` | tpprd | Nome do banco |
| `DB_USER` | tpprd | Usuário do banco |
| `DB_PASSWORD` | 123456 | Senha do banco |
| `TZ` | America/Sao_Paulo | Timezone |

## Deploy no Coolify

1. Novo recurso **Docker Compose**
2. Apontar para o repositório Git
3. Configurar variáveis de ambiente no painel
4. Deploy
