# Protheus Docker

Ambiente Protheus containerizado para desenvolvimento usando Docker e Docker Compose.

## 📋 Pré-requisitos

- Docker
- Docker Compose
- Arquivos do Protheus:
  - `tttm120.rpo` (Repositório Protheus)
  - `sx2.unq` (Dicionário de dados)
  - `sxsbra.txt` (Dicionário de dados)

## 🚀 Configuração

### Estrutura do Projeto

```
protheus_docker/
├── docker-compose.yml      # Orquestração dos serviços
├── Dockerfile             # Imagem personalizada do AppServer
├── appserver.ini          # Configuração do servidor de aplicação
├── dbaccess.ini          # Configuração de acesso ao banco
├── tttm120.rpo           # Repositório Protheus
├── sx2.unq               # Dicionário de dados
├── sxsbra.txt            # Dicionário de dados
└── README.md             # Este arquivo
```

### Serviços Inclusos

- **License Server**: Servidor de licenças TOTVS
- **PostgreSQL**: Banco de dados
- **DBAccess**: Middleware de acesso ao banco
- **AppServer**: Servidor de aplicação Protheus

## 🐳 Como usar

### Usando Docker Compose

```bash
# Iniciar todos os serviços
docker-compose up -d

# Verificar status dos containers
docker-compose ps

# Visualizar logs
docker-compose logs -f appserver

# Parar os serviços
docker-compose down
```

### Usando Coolify

1. Importe este repositório no Coolify
2. Configure o deployment usando o `docker-compose.yml`
3. Os arquivos de configuração serão automaticamente montados nos containers

## 🔧 Configuração

### Portas Expostas

- **1234**: Porta principal do AppServer (TCP)
- **8080**: Porta do WebApp
- **8081**: Porta REST

### Banco de Dados

- **Host**: postgres-iniciado
- **Porta**: 5432
- **Database**: protheus
- **Usuário**: postgres
- **Senha**: postgres

### Configurações Personalizáveis

#### appserver.ini
- Configurações do servidor de aplicação
- Paths dos arquivos RPO e dicionários
- Configurações de memória e performance

#### dbaccess.ini
- String de conexão com PostgreSQL
- Configurações do servidor de licenças
- Parâmetros de conectividade

## 📝 Notas Importantes

⚠️ **Aviso**: As imagens são para uso estritamente de desenvolvimento e não são homologadas para ambientes de produção.

### Para hosts Debian/Ubuntu

Ajustar a seguinte variável de kernel:

```bash
# Backup do valor atual (será perdido na próxima inicialização)
sudo echo 32767 > /proc/sys/fs/file-max
```

## 🔍 Troubleshooting

### Verificar logs dos containers

```bash
# Logs do AppServer
docker-compose logs appserver

# Logs do PostgreSQL
docker-compose logs postgres-iniciado

# Logs do DBAccess
docker-compose logs dbaccess-postgres
```

### Reiniciar serviços específicos

```bash
# Reiniciar apenas o AppServer
docker-compose restart appserver

# Reiniciar todos os serviços
docker-compose restart
```

## 📚 Documentação Oficial

- [Tutorial Protheus Docker](https://docker-protheus.engpro.totvs.com.br/00-tutorial-protheus-docker/)
- [Documentação TOTVS](https://tdn.totvs.com/)

## 🤝 Contribuição

1. Fork o projeto
2. Crie sua feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença especificada no arquivo `LICENSE`.