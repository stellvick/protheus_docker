#!/bin/bash
#
# Script de Instalação - Protheus Services Scripts
# Copia os scripts de gerenciamento de serviços para os locais corretos do sistema
# Segue o padrão da documentação TOTVS: Protheus em Linux - Serviços
#
# Uso: sudo bash install-scripts.sh
#

set -e

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Diretório de origem
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_SOURCE_DIR="${SCRIPT_DIR}/advpl_scripts"

# Diretório de destino (padrão TOTVS)
SCRIPTS_DEST_DIR="/usr/local/bin"

# Array com os scripts a serem instalados
declare -a SCRIPTS=(
    "totvsappbroker"
    "totvsappsec01"
    "totvsappsec02"
    "totvsdbaccess"
    "totvslicensesrv"
)

# Função de log
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Verificar se está rodando como root/sudo
if [[ $EUID -ne 0 ]]; then
    log_error "Este script deve ser executado com sudo/privilégios de root"
    echo "Use: sudo bash $0"
    exit 1
fi

# Verificar se o diretório de origem existe
if [[ ! -d "$SCRIPTS_SOURCE_DIR" ]]; then
    log_error "Diretório de origem não encontrado: $SCRIPTS_SOURCE_DIR"
    exit 1
fi

log_info "=========================================="
log_info "Instalação de Scripts Protheus Services"
log_info "=========================================="
log_info "Origem: $SCRIPTS_SOURCE_DIR"
log_info "Destino: $SCRIPTS_DEST_DIR"
log_info ""

# Criar backup dos scripts existentes
if [[ -d "$SCRIPTS_DEST_DIR" ]]; then
    BACKUP_DIR="${SCRIPTS_DEST_DIR}/protheus_scripts_backup_$(date +%Y%m%d_%H%M%S)"
    log_info "Criando backup dos scripts existentes..."
    
    for script in "${SCRIPTS[@]}"; do
        if [[ -f "${SCRIPTS_DEST_DIR}/${script}" ]]; then
            mkdir -p "$BACKUP_DIR"
            cp "${SCRIPTS_DEST_DIR}/${script}" "${BACKUP_DIR}/"
            log_info "  ✓ Backup: ${script}"
        fi
    done
    
    if [[ -d "$BACKUP_DIR" ]]; then
        log_success "Backups criados em: $BACKUP_DIR"
    fi
fi

log_info ""
log_info "Instalando scripts..."
log_info ""

# Copiar scripts
INSTALLED_COUNT=0
for script in "${SCRIPTS[@]}"; do
    SOURCE_FILE="${SCRIPTS_SOURCE_DIR}/${script}"
    DEST_FILE="${SCRIPTS_DEST_DIR}/${script}"
    
    if [[ ! -f "$SOURCE_FILE" ]]; then
        log_warning "Script não encontrado: $SOURCE_FILE"
        continue
    fi
    
    # Copiar arquivo
    cp "$SOURCE_FILE" "$DEST_FILE"
    
    # Definir permissões de execução
    chmod 755 "$DEST_FILE"
    
    # Definir ownership (opcional - descomente se necessário)
    # chown root:root "$DEST_FILE"
    
    log_success "Instalado: ${script}"
    ((INSTALLED_COUNT++))
done

log_info ""
log_info "=========================================="
log_info "Resumo da Instalação"
log_info "=========================================="
log_info "Scripts instalados: $INSTALLED_COUNT/${#SCRIPTS[@]}"
log_info "Localização: $SCRIPTS_DEST_DIR"
log_info ""

# Verificar instalação
log_info "Verificando instalação..."
for script in "${SCRIPTS[@]}"; do
    if [[ -x "${SCRIPTS_DEST_DIR}/${script}" ]]; then
        log_success "✓ ${script} - OK (executável)"
    else
        log_warning "✗ ${script} - Não encontrado ou sem permissão de execução"
    fi
done

log_info ""
log_success "=========================================="
log_success "Instalação concluída com sucesso!"
log_success "=========================================="
log_info ""
log_info "Próximos passos:"
log_info "1. Verificar e ajustar as configurações em cada script"
log_info "2. Executar: ${script} status"
log_info "3. Para iniciar um serviço: sudo ${script} start"
log_info ""
log_info "Exemplos de uso:"
log_info "  sudo totvsappbroker status"
log_info "  sudo totvsappbroker start"
log_info "  sudo totvsappbroker stop"
log_info "  sudo totvsappbroker restart"
log_info "  sudo totvsappbroker describe"
log_info "  sudo totvsappbroker log"
log_info ""

exit 0
