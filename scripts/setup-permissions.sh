#!/bin/bash
set -e

echo "Ajustando permissões dos diretórios Protheus..."

PROTHEUS_DIRS=(
    "/app/totvs/protheus/bin"
    "/app/totvs/protheus/rpo"
    "/app/totvs/protheus_data"
    "/tmp/protheus"
)

for dir in "${PROTHEUS_DIRS[@]}"; do
    if [ -d "${dir}" ]; then
        chmod -R 755 "${dir}"
        echo "  OK: ${dir}"
    else
        mkdir -p "${dir}"
        chmod -R 755 "${dir}"
        echo "  CRIADO: ${dir}"
    fi
done

EXECUTABLES=(
    "/app/totvs/protheus/bin/appbroker/appserver"
    "/app/totvs/protheus/bin/appsec01/appserver"
    "/app/totvs/protheus/bin/appsec02/appserver"
    "/app/totvs/protheus/bin/dbaccess/dbaccess"
    "/app/totvs/protheus/bin/licenseserver/appserver"
)

for exe in "${EXECUTABLES[@]}"; do
    if [ -f "${exe}" ]; then
        chmod +x "${exe}"
        echo "  +x: ${exe}"
    fi
done

echo "Permissões ajustadas."
