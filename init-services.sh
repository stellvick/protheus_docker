#!/bin/bash
#
# Script de inicialização de Serviços Protheus
# Inicia todos os serviços necessários do Protheus
#
# Uso: bash init-services.sh [start|stop|status|restart]
#

set -e

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Diretório de logs
LOG_DIR="/app/logs"
mkdir -p "$LOG_DIR"

# Timestamps de log
LOG_FILE="${LOG_DIR}/protheus-services.log"

# Função de log
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# Array com serviços a inicializar
declare -a SERVICES=(
    "totvsappbroker"
    "totvsappsec01"
    "totvsdbaccess"
    "totvslicensesrv"
)

# Função para iniciar serviços
start_services() {
    log_info "=========================================="
    log_info "Iniciando Serviços Protheus"
    log_info "=========================================="
    log_info ""
    
    for service in "${SERVICES[@]}"; do
        if command -v "$service" &> /dev/null; then
            log_info "Iniciando $service..."
            if "$service" start >> "$LOG_FILE" 2>&1; then
                log_success "$service iniciado com sucesso"
                sleep 2
            else
                log_warning "$service falhou ao iniciar"
            fi
        else
            log_warning "Serviço $service não encontrado"
        fi
        log_info ""
    done
    
    log_success "Inicialização de serviços concluída"
}

# Função para parar serviços
stop_services() {
    log_info "=========================================="
    log_info "Parando Serviços Protheus"
    log_info "=========================================="
    log_info ""
    
    for service in "${SERVICES[@]}"; do
        if command -v "$service" &> /dev/null; then
            log_info "Parando $service..."
            if "$service" stop >> "$LOG_FILE" 2>&1; then
                log_success "$service parado com sucesso"
                sleep 2
            else
                log_warning "$service falhou ao parar"
            fi
        fi
        log_info ""
    done
    
    log_success "Parada de serviços concluída"
}

# Função para reiniciar serviços
restart_services() {
    log_info "=========================================="
    log_info "Reiniciando Serviços Protheus"
    log_info "=========================================="
    log_info ""
    stop_services
    log_info ""
    start_services
}

# Função para exibir status
status_services() {
    log_info "=========================================="
    log_info "Status dos Serviços Protheus"
    log_info "=========================================="
    log_info ""
    
    for service in "${SERVICES[@]}"; do
        if command -v "$service" &> /dev/null; then
            log_info "Status de $service:"
            "$service" status >> "$LOG_FILE" 2>&1 || true
            log_info ""
        fi
    done
    
    log_success "Verificação de status concluída"
}

# Main
COMMAND="${1:-start}"

case "$COMMAND" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    status)
        status_services
        ;;
    *)
        echo "Uso: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac

exit 0
