#!/bin/bash
set -e

echo "========== INICIANDO PROTHEUS =========="

echo "[1/4] Configurando ODBC e variáveis de ambiente..."
/usr/local/bin/setup-config.sh

echo "[2/4] Ajustando permissões..."
/usr/local/bin/setup-permissions.sh

echo "[3/4] Iniciando serviços Protheus..."
/usr/local/bin/init-services.sh

echo "[4/4] Protheus iniciado com sucesso!"
echo "========== PROTHEUS PRONTO =========="

exec tail -f /app/totvs/protheus/bin/log/*.log 2>/dev/null || exec tail -f /dev/null
