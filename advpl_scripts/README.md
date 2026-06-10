# Protheus Services Scripts

Documentação dos scripts de gerenciamento de serviços Protheus em Linux.

## Referência

- [Protheus em Linux - Serviços (TOTVS)](https://tdn.totvs.com/pages/viewpage.action?pageId=515676283)

## Estrutura

```
advpl_scripts/
├── totvsappbroker          # Gerenciar Protheus Broker
├── totvsappsec01           # Gerenciar Protheus AppServer SEC01
├── totvsappsec02           # Gerenciar Protheus AppServer SEC02
├── totvsdbaccess           # Gerenciar DBAccess
└── totvslicensesrv         # Gerenciar License Server
```

## Instalação

### Método 1: Usando o script de instalação (Recomendado)

```bash
# Dar permissão de execução
chmod +x install-scripts.sh

# Executar com sudo
sudo ./install-scripts.sh
```

Este script:
- Copia os scripts para `/usr/local/bin/`
- Define permissões de execução (755)
- Cria backup dos scripts existentes
- Valida a instalação

### Método 2: Instalação manual

```bash
# Copiar scripts para /usr/local/bin/
sudo cp advpl_scripts/totvs* /usr/local/bin/

# Definir permissões
sudo chmod 755 /usr/local/bin/totvs*

# Verificar permissões
ls -la /usr/local/bin/totvs*
```

## Uso

### Comandos básicos

Todos os scripts suportam os seguintes comandos:

```bash
# Iniciar serviço
sudo totvsappbroker start

# Parar serviço
sudo totvsappbroker stop

# Reiniciar serviço
sudo totvsappbroker restart

# Verificar status
sudo totvsappbroker status

# Matar processo (força)
sudo totvsappbroker kill

# Exibir informações detalhadas
sudo totvsappbroker describe

# Monitorar log em tempo real
sudo totvsappbroker log

# Exportar configurações e logs (para suporte)
sudo totvsappbroker export
```

### Exemplos de uso

#### Protheus Broker

```bash
# Iniciar broker com balance para Smart Client Desktop
sudo totvsappbroker start

# Verificar status
sudo totvsappbroker status

# Ver informações detalhadas
sudo totvsappbroker describe

# Monitorar log
sudo totvsappbroker log
```

#### AppServer SEC01

```bash
# Iniciar appserver
sudo totvsappsec01 start

# Parar gracefully
sudo totvsappsec01 stop

# Reiniciar
sudo totvsappsec01 restart

# Status
sudo totvsappsec01 status
```

#### DBAccess

```bash
# Iniciar DBAccess
sudo totvsdbaccess start

# Parar
sudo totvsdbaccess stop

# Status
sudo totvsdbaccess status

# Exportar configuração e logs para suporte
sudo totvsdbaccess export
```

#### License Server

```bash
# Iniciar License Server
sudo totvslicensesrv start

# Verificar status
sudo totvslicensesrv status

# Logs
sudo totvslicensesrv log
```

## Configuração

Cada script possui uma seção de configuração no início:

```bash
#########################################
#   CONFIGURACAO DO SERVICO     #
#########################################

# Nome do executável
prog="appsrvlinux"

# Caminho do diretório do executável
pathbin="/totvs/protheus/bin/protheus_sec01"

# Arquivo de configuração
config_filename=appserver.ini

# Arquivo de log
log_filename=console.log
```

### Configurações de ULIMIT

Cada script define limites do sistema:

```bash
#open files - (-n)
openFiles=65536

#stack size - (kbytes, -s)
stackSize=1024

#core file size - (blocks, -c)
coreFileSize=unlimited

#file size - (blocks, -f)
fileSize=unlimited

#cpu time - (seconds, -t)
cpuTime=unlimited

#virtual memory - (-v)
virtualMemory=unlimited
```

## Arquivos de Saída

Ao usar o comando `export`, os scripts geram um arquivo `.zip` contendo:

- `describe.txt` - Informações detalhadas do processo
- `console.log` - Log do serviço
- `${config_filename}` - Arquivo de configuração (appserver.ini, dbaccess.ini, etc.)
- `library.txt` - Dependências de bibliotecas (ldd)

Arquivo gerado: `/tmp/[script_name]_export.zip`

## Requisitos do Sistema

- Linux (openSUSE, CentOS, Red Hat, Debian, Ubuntu, etc.)
- Bash shell
- Privilégios de root/sudo
- Comandos disponíveis: ps, pidof, lsof, kill, grep, awk, cut, tr, bc, zip

## Troubleshooting

### Script não encontrado

```bash
# Verificar se está instalado
which totvsappbroker

# Se não encontrado, reinstalar
sudo ./install-scripts.sh
```

### Permissão negada

```bash
# Verificar permissões
ls -la /usr/local/bin/totvs*

# Corrigir permissões
sudo chmod 755 /usr/local/bin/totvs*
```

### Serviço não inicia

```bash
# Verificar detalhes
sudo totvsappbroker describe

# Verificar logs
sudo totvsappbroker log

# Exportar informações para suporte
sudo totvsappbroker export
```

### Processo não finaliza

```bash
# Tentar parar normalmente primeiro
sudo totvsappbroker stop

# Se não funcionar, usar kill
sudo totvsappbroker kill
```

## Variáveis de Configuração

### Broker (totvsappbroker)

```bash
# Tipos de balance disponíveis:
broker_type="balance_smart_client_desktop"  # Smart Client Desktop
broker_type="balance_http"                  # HTTP
broker_type="balance_telnet"                # Telnet
broker_type="balance_web_services"          # Web Services
```

### DBAccess (totvsdbaccess)

```bash
# Ambiente com Oracle
envOracle=0  # 0=desabilitado, 1=habilitado

oracle_sid="orcl"
oracle_home="/usr/lib/oracle/19.10/client64"
tns_admin="/usr/lib/oracle/19.10/client64/lib/network/admin/"
```

## Log de Alterações

### Versão 1.0

- ✓ Padronização dos scripts conforme TOTVS
- ✓ Melhor descrição nos comentários iniciais
- ✓ Criação de script de instalação automática
- ✓ Documentação completa

## Suporte

Para problemas ou dúvidas:

1. Consulte a documentação TOTVS: https://tdn.totvs.com/pages/viewpage.action?pageId=515676283
2. Verifique os logs usando: `sudo [script] log`
3. Exporte informações para suporte: `sudo [script] export`
4. Verifique configurações: `sudo [script] describe`

## Licença

Estes scripts seguem a documentação oficial TOTVS para Protheus em Linux.
