#!/bin/bash
#
# Script de inicialização dos arquivos de configuração Protheus
# Cria/atualiza os arquivos .ini necessários para cada serviço
#

# Não parar em erros (permitir que continue)
set +e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}[INFO]${NC} Configurando arquivos .ini dos serviços Protheus..."

# Diretórios
APPBROKER_DIR="/totvs/protheus/bin/protheus_broker"
APPSEC01_DIR="/totvs/protheus/bin/protheus_sec01"
APPSEC02_DIR="/totvs/protheus/bin/protheus_sec02"
DBACCESS_DIR="/totvs/protheus/bin/dbaccess/multi"
LICENSESERVER_DIR="/totvs/licenseserver/bin/appserver"
ADVPL_CONFIG_DIR="/app/advpl_config"

# Criar diretórios se não existirem (com logs)
echo -e "${BLUE}[INFO]${NC} Criando diretórios necessários..."
for dir in "$APPBROKER_DIR" "$APPSEC01_DIR" "$APPSEC02_DIR" "$DBACCESS_DIR" "$LICENSESERVER_DIR"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[SUCCESS]${NC} Diretório criado: $dir"
        else
            echo -e "${YELLOW}[WARNING]${NC} Falha ao criar diretório: $dir"
        fi
    else
        echo -e "${BLUE}[INFO]${NC} Diretório existe: $dir"
    fi
done

# Funções para criar configurações padrão

create_appserver_ini() {
    local dir=$1
    local name=$2
    local port=$3
    local ini_file="$dir/appserver.ini"
    
    # Validar se diretório existe e é gravável
    if [ ! -d "$dir" ]; then
        echo -e "${YELLOW}[WARNING]${NC} Diretório não existe: $dir"
        return 1
    fi
    
    if [ ! -w "$dir" ]; then
        echo -e "${YELLOW}[WARNING]${NC} Diretório não é gravável: $dir"
        return 1
    fi
    
    # Não sobrescrever se arquivo já existe
    if [ -f "$ini_file" ]; then
        echo -e "${BLUE}[INFO]${NC} Arquivo já existe: $ini_file"
        return 0
    fi
    
    echo -e "${BLUE}[INFO]${NC} Criando $ini_file..."
    cat > "$ini_file" << EOF
[General]
Application=SIGAFAT
Server=SIGAMAT
Startup=
StartupAccess=
Repository=${dir}/../../../rpo/tttp120.rpo
SecurityPolicy=0
MaxUsers=10
MaxStaticInstances=10
LocalFiles=.\
LogLevel=2
ConsoleFile=/app/logs/protheus/${name}.log

[Environment]
Path=${dir}
Library=${dir}
System=/app/totvs/protheus_data/system/
Systemload=/app/totvs/protheus_data/systemload/

[TCP]
PortNumber=$port
MaxConnections=100

[RPC]
Active=1
Port=$((port + 1000))

[WebServices]
Active=0

EOF
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS]${NC} Arquivo criado: $ini_file"
        return 0
    else
        echo -e "${YELLOW}[WARNING]${NC} Falha ao criar arquivo: $ini_file"
        return 1
    fi
}

create_broker_ini() {
    local dir=$1
    local ini_file="$dir/appsrvlinux_broker.ini"
    
    # Validar se diretório existe e é gravável
    if [ ! -d "$dir" ]; then
        echo -e "${YELLOW}[WARNING]${NC} Diretório não existe: $dir"
        return 1
    fi
    
    if [ ! -w "$dir" ]; then
        echo -e "${YELLOW}[WARNING]${NC} Diretório não é gravável: $dir"
        return 1
    fi
    
    # Não sobrescrever se arquivo já existe
    if [ -f "$ini_file" ]; then
        echo -e "${BLUE}[INFO]${NC} Arquivo já existe: $ini_file"
        return 0
    fi
    
    echo -e "${BLUE}[INFO]${NC} Criando $ini_file..."
    cat > "$ini_file" << EOF
[General]
Application=SIGAFAT
Server=SIGAMAT
Repository=${dir}/../../../rpo/tttp120.rpo
MaxUsers=50
LogLevel=2
ConsoleFile=/app/logs/protheus/broker.log

[Environment]
Path=${dir}
Library=${dir}
System=/app/totvs/protheus_data/system/
Systemload=/app/totvs/protheus_data/systemload/

[Broker]
PortNumber=9000
MaxConnections=100
BalanceType=balance_smart_client_desktop

[TCP]
PortNumber=9000

EOF
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS]${NC} Arquivo criado: $ini_file"
        return 0
    else
        echo -e "${YELLOW}[WARNING]${NC} Falha ao criar arquivo: $ini_file"
        return 1
    fi
}

create_dbaccess_ini() {
    local dir=$1
    local ini_file="$dir/dbaccess.ini"
    
    # Validar se diretório existe e é gravável
    if [ ! -d "$dir" ]; then
        echo -e "${YELLOW}[WARNING]${NC} Diretório não existe: $dir"
        return 1
    fi
    
    if [ ! -w "$dir" ]; then
        echo -e "${YELLOW}[WARNING]${NC} Diretório não é gravável: $dir"
        return 1
    fi
    
    # Não sobrescrever se arquivo já existe
    if [ -f "$ini_file" ]; then
        echo -e "${BLUE}[INFO]${NC} Arquivo já existe: $ini_file"
        return 0
    fi
    
    echo -e "${BLUE}[INFO]${NC} Criando $ini_file..."
    cat > "$ini_file" << EOF
[General]
Application=SIGAFAT
Server=SIGAMAT
MaxUsers=10
LogLevel=2
ConsoleFile=/app/logs/protheus/dbaccess.log

[Environment]
Path=${dir}
Library=${dir}
System=/app/totvs/protheus_data/system/
Systemload=/app/totvs/protheus_data/systemload/

[TCP]
PortNumber=7000
MaxConnections=100

[Database]
Type=TopConnect
ConnectionTimeout=30

EOF
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS]${NC} Arquivo criado: $ini_file"
        return 0
    else
        echo -e "${YELLOW}[WARNING]${NC} Falha ao criar arquivo: $ini_file"
        return 1
    fi
}

create_licensesrv_ini() {
    local dir=$1
    local ini_file="$dir/appserver.ini"
    
    # Validar se diretório existe e é gravável
    if [ ! -d "$dir" ]; then
        echo -e "${YELLOW}[WARNING]${NC} Diretório não existe: $dir"
        return 1
    fi
    
    if [ ! -w "$dir" ]; then
        echo -e "${YELLOW}[WARNING]${NC} Diretório não é gravável: $dir"
        return 1
    fi
    
    # Não sobrescrever se arquivo já existe
    if [ -f "$ini_file" ]; then
        echo -e "${BLUE}[INFO]${NC} Arquivo já existe: $ini_file"
        return 0
    fi
    
    echo -e "${BLUE}[INFO]${NC} Criando $ini_file..."
    cat > "$ini_file" << EOF
[General]
Application=License
MaxUsers=999
LogLevel=2
ConsoleFile=/app/logs/protheus/licensesrv.log

[Environment]
Path=${dir}
Library=${dir}

[TCP]
PortNumber=6000
MaxConnections=100

EOF
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS]${NC} Arquivo criado: $ini_file"
        return 0
    else
        echo -e "${YELLOW}[WARNING]${NC} Falha ao criar arquivo: $ini_file"
        return 1
    fi
}

# Criar as configurações
echo ""

# Primeiro: Copiar configurações customizadas do /app/advpl_config se existirem
if [ -d "$ADVPL_CONFIG_DIR" ]; then
    echo -e "${BLUE}[INFO]${NC} Aplicando configurações customizadas de $ADVPL_CONFIG_DIR..."
    echo ""
    
    # Copiar appserver.ini para SEC01 e SEC02
    if [ -f "$ADVPL_CONFIG_DIR/appserver.ini" ]; then
        echo -e "${BLUE}[INFO]${NC} Copiando appserver.ini para SEC01..."
        if cp "$ADVPL_CONFIG_DIR/appserver.ini" "$APPSEC01_DIR/appserver.ini" 2>/dev/null; then
            echo -e "${GREEN}[SUCCESS]${NC} Arquivo copiado: $APPSEC01_DIR/appserver.ini"
        else
            echo -e "${YELLOW}[WARNING]${NC} Falha ao copiar para $APPSEC01_DIR/appserver.ini"
        fi
        
        echo -e "${BLUE}[INFO]${NC} Copiando appserver.ini para SEC02..."
        if cp "$ADVPL_CONFIG_DIR/appserver.ini" "$APPSEC02_DIR/appserver.ini" 2>/dev/null; then
            echo -e "${GREEN}[SUCCESS]${NC} Arquivo copiado: $APPSEC02_DIR/appserver.ini"
        else
            echo -e "${YELLOW}[WARNING]${NC} Falha ao copiar para $APPSEC02_DIR/appserver.ini"
        fi
    fi
    
    # Copiar broker.ini para Broker
    if [ -f "$ADVPL_CONFIG_DIR/broker.ini" ]; then
        echo -e "${BLUE}[INFO]${NC} Copiando broker.ini para Broker..."
        if cp "$ADVPL_CONFIG_DIR/broker.ini" "$APPBROKER_DIR/appsrvlinux_broker.ini" 2>/dev/null; then
            echo -e "${GREEN}[SUCCESS]${NC} Arquivo copiado: $APPBROKER_DIR/appsrvlinux_broker.ini"
        else
            echo -e "${YELLOW}[WARNING]${NC} Falha ao copiar para $APPBROKER_DIR/appsrvlinux_broker.ini"
        fi
    fi
    
    # Copiar dbaccess.ini para DBAccess
    if [ -f "$ADVPL_CONFIG_DIR/dbaccess.ini" ]; then
        echo -e "${BLUE}[INFO]${NC} Copiando dbaccess.ini para DBAccess..."
        if cp "$ADVPL_CONFIG_DIR/dbaccess.ini" "$DBACCESS_DIR/dbaccess.ini" 2>/dev/null; then
            echo -e "${GREEN}[SUCCESS]${NC} Arquivo copiado: $DBACCESS_DIR/dbaccess.ini"
        else
            echo -e "${YELLOW}[WARNING]${NC} Falha ao copiar para $DBACCESS_DIR/dbaccess.ini"
        fi
    fi
    
    echo ""
fi

# Segundo: Criar configurações padrão para arquivos que ainda não existem
create_appserver_ini "$APPBROKER_DIR" "appbroker" "9000"
create_appserver_ini "$APPSEC01_DIR" "appsec01" "8001"
create_appserver_ini "$APPSEC02_DIR" "appsec02" "8002"
create_broker_ini "$APPBROKER_DIR"
create_dbaccess_ini "$DBACCESS_DIR"
create_licensesrv_ini "$LICENSESERVER_DIR"

configure_odbc_ini() {
    local ini_file="/etc/unixODBC/odbc.ini"
    local db_host="${DB_HOST:-postgres}"
    local db_port="${DB_PORT:-5432}"
    local db_name="${DB_NAME:-tpprd}"
    local db_user="${DB_USER:-tpprd}"
    local db_pass="${DB_PASSWORD:-123456}"
    
    mkdir -p /etc/unixODBC
    cat > "$ini_file" << EOF
[tpprd]
Description=Protheus TPPRD Database Connection
Driver=PostgreSQL
Trace=Yes
TraceFile=/tmp/protheus/odbc_trace.log
ServerName=$db_host
Database=$db_name
Port=$db_port
UserName=$db_user
Password=$db_pass

[protheus]
Description=Protheus Database Connection
Driver=PostgreSQL
Trace=Yes
TraceFile=/tmp/protheus/odbc_trace.log
ServerName=$db_host
Database=$db_name
Port=$db_port
UserName=$db_user
Password=$db_pass
EOF
    chmod 644 "$ini_file"
}

configure_odbc_ini

echo ""
echo -e "${GREEN}[SUCCESS]${NC} Configuração dos arquivos .ini concluída!"
echo ""

exit 0
