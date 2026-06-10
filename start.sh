#!/bin/bash

# Script principal de inicialização do container
# Inicia os serviços Protheus e mantém o container rodando

set +e  # Não parar em erros (permitir limpeza)

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Diretório de logs
LOG_DIR="/app/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/container-startup.log"

{
    echo "=========================================="
    echo "Starting openSUSE Leap 15.4 container"
    echo "=========================================="
    echo ""
    date
    echo ""
    echo "System Information:"
    cat /etc/os-release
    echo ""
    echo "  Hostname: $(hostname)"
    echo "  Timezone: $(cat /etc/timezone)"
    echo "  Date: $(date)"
    echo ""
    echo "Directories:"
    echo "  /app: $(ls -la /app | wc -l) items"
    echo "  /app/data: $(ls -la /app/data 2>/dev/null | wc -l) items"
    echo "  /app/logs: $(ls -la /app/logs 2>/dev/null | wc -l) items"
    echo "  /totvs: $(test -d /totvs && echo "$(find /totvs -type d | wc -l) directories" || echo "not found")"
    echo ""
    
    # Função de cleanup ao sair
    cleanup() {
        echo ""
        echo "=========================================="
        echo "Stopping Protheus Services"
        echo "=========================================="
        if [ -x "/usr/local/bin/init-services.sh" ]; then
            /usr/local/bin/init-services.sh stop 2>&1 | tee -a "$LOG_FILE"
        fi
        echo "Container stopped at $(date)"
        exit 0
    }
    
    # Configurar trap para sinais
    trap cleanup SIGTERM SIGINT
    
    # Garantir que configurações estão atualizadas
    if [ -x "/usr/local/bin/setup-config.sh" ]; then
        echo "=========================================="
        echo "Ensuring Protheus Configuration"
        echo "=========================================="
        echo ""
        /usr/local/bin/setup-config.sh 2>&1 | tee -a "$LOG_FILE"
        echo ""
    fi
    
    # Iniciar serviços Protheus
    echo "=========================================="
    echo "Initializing Protheus Services"
    echo "=========================================="
    echo ""
    
    if [ -x "/usr/local/bin/init-services.sh" ]; then
        /usr/local/bin/init-services.sh start 2>&1 | tee -a "$LOG_FILE"
        echo ""
    else
        echo "Warning: init-services.sh not found"
        echo ""
    fi
    
    # Aguardar inicialização dos serviços
    sleep 5
    
    # Exibir status dos serviços
    echo "=========================================="
    echo "Protheus Services Status"
    echo "=========================================="
    echo ""
    if [ -x "/usr/local/bin/init-services.sh" ]; then
        /usr/local/bin/init-services.sh status 2>&1 | tee -a "$LOG_FILE"
    fi
    echo ""
    
    # Iniciar servidor HTTP
    echo "=========================================="
    echo "Starting HTTP Server"
    echo "=========================================="
    echo ""
    echo "HTTP Server on port 3000"
    echo "Access at http://localhost:3000"
    echo "Press Ctrl+C to stop"
    echo ""
    
    # Servidor HTTP simples em background
    cd /app && python3 -m http.server 3000 2>&1 | while IFS= read -r line; do
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $line" | tee -a "$LOG_FILE"
    done &
    
    HTTP_PID=$!
    
    # Aguardar indefinidamente (trap cuidará do cleanup)
    wait $HTTP_PID
    
} | tee -a "$LOG_FILE"

