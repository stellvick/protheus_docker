#!/bin/bash
set -e

LOG_DIR="/app/totvs/protheus/bin/log"
mkdir -p "${LOG_DIR}"

start_service() {
    local name="$1"
    local binary="$2"
    local ini="$3"
    local log_file="${LOG_DIR}/${name}.log"

    if [ ! -f "${binary}" ]; then
        echo "AVISO: Binário não encontrado: ${binary} - pulando ${name}"
        return 0
    fi

    echo "Iniciando ${name}..."
    cd "$(dirname "${binary}")"
    nohup "${binary}" -ini="${ini}" > "${log_file}" 2>&1 &
    local pid=$!
    echo "  ${name} iniciado (PID: ${pid})"
    sleep 2

    if kill -0 "${pid}" 2>/dev/null; then
        echo "  ${name} rodando OK"
    else
        echo "  ERRO: ${name} parou inesperadamente. Verifique ${log_file}"
    fi
}

echo "========== Iniciando serviços Protheus =========="

start_service "dbaccess" \
    "/app/totvs/protheus/bin/dbaccess/dbaccess" \
    "/app/totvs/protheus/bin/dbaccess/dbaccess.ini"

sleep 3

start_service "licenseserver" \
    "/app/totvs/protheus/bin/licenseserver/appserver" \
    "/app/totvs/protheus/bin/licenseserver/appserver.ini"

sleep 3

start_service "appbroker" \
    "/app/totvs/protheus/bin/appbroker/appserver" \
    "/app/totvs/protheus/bin/appbroker/appserver.ini"

sleep 2

start_service "appsec01" \
    "/app/totvs/protheus/bin/appsec01/appserver" \
    "/app/totvs/protheus/bin/appsec01/appserver.ini"

sleep 2

start_service "appsec02" \
    "/app/totvs/protheus/bin/appsec02/appserver" \
    "/app/totvs/protheus/bin/appsec02/appserver.ini"

echo "========== Serviços Protheus iniciados =========="
echo ""
echo "Processos rodando:"
ps aux | grep -E "(appserver|dbaccess)" | grep -v grep || echo "Nenhum processo encontrado"
