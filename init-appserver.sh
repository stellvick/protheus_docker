#!/bin/bash

set -e

echo "=== INICIANDO DEBUG DO APPSERVER ==="

if [ ! -f "/opt/totvs/appserver/appserver.ini" ]; then
    echo "ERRO: Arquivo appserver.ini não encontrado!"
    exit 1
fi

echo "✓ Arquivo de configuração encontrado"

APPSERVER_EXEC="/opt/totvs/appserver/appsrvlinux"

if [ ! -x "$APPSERVER_EXEC" ]; then
    echo "❌ Executável appsrvlinux não encontrado"
    exit 1
fi

echo "✓ Executável encontrado: $APPSERVER_EXEC"

echo "=== VERIFICANDO PARÂMETROS DISPONÍVEIS ==="
"$APPSERVER_EXEC" -help 2>&1 || echo "Help executado"

echo "=== TESTANDO CONECTIVIDADE ==="
timeout 5 bash -c "</dev/tcp/dbaccess-postgres/7890" 2>/dev/null && echo "✓ DBAccess acessível" || echo "❌ DBAccess inacessível"
timeout 5 bash -c "</dev/tcp/license/5555" 2>/dev/null && echo "✓ License Server acessível" || echo "❌ License Server inacessível"

echo "=== INICIANDO APPSERVER ==="
echo "Mudando para diretório do AppServer..."
cd /opt/totvs/appserver

echo "Iniciando AppServer (sem parâmetros, deve usar appserver.ini local):"
exec "$APPSERVER_EXEC"
