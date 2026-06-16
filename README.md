# Protheus Docker - Coolify

Ambiente Docker Compose do Protheus para deploy no Coolify.

**As imagens são para uso estritamente de desenvolvimento e não são homologadas para ambientes de produção.**

## Pré-requisitos

Baixar os seguintes arquivos do **Portal do Cliente TOTVS** e colocar na pasta `resources/`:

| Arquivo | Destino |
|---------|---------|
| `tttm120.rpo` | `resources/tttm120.rpo` |
| `sxsbra.txt` | `resources/sxsbra.txt` |
| `sx2.unq` | `resources/sx2.unq` |


advpl.stellvick.fun, advpl.stellvick.com {
    reverse_proxy https://appserver-cpok1pkpo9juiriu2oikg1i0-171815504360:9988 {
        header_up Host {host}
        header_up X-Real-IP {remote}
    }
}

## Estrutura

```
.
├── docker-compose.yml
├── README.md
└── resources/
    ├── appserver.ini
    ├── dbaccess.ini
    ├── tttm120.rpo      (baixar do Portal)
    ├── sxsbra.txt       (baixar do Portal)
    └── sx2.unq          (baixar do Portal)
```

## Serviços

| Serviço | Imagem | Porta |
|---------|--------|-------|
| license | totvsengpro/license-dev | - |
| postgres-iniciado | totvsengpro/postgres-dev:12.1.2210_bra | - |
| dbaccess-postgres | totvsengpro/dbaccess-postgres-dev | - |
| appserver | totvsengpro/appserver-dev | 1234, 8080, 8081 |

## Deploy no Coolify

1. Criar um novo recurso do tipo **Docker Compose** no Coolify
2. Apontar para o repositório Git deste projeto
3. Garantir que os arquivos RPO e dicionários estejam na pasta `resources/`
4. Fazer deploy

## Portas

- **1234**: AppServer TCP (conexão SmartClient)
- **8080**: WebApp (acesso web)
- **8081**: REST API

## Host Debian/Ubuntu

Caso o host utilize distribuição baseada em Debian/Ubuntu, alterar a variável de kernel:

```bash
sudo echo 32767 > /proc/sys/fs/file-max
```
