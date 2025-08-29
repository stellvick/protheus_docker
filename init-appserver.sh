#!/bin/bash

set -e

echo "=== INICIANDO DEBUG DO APPSERVER ==="

if [ ! -f "/opt/totvs/appserver/appserver.ini" ]; then
    echo "ERRO: Arquivo appserver.ini não encontrado!"
    exit 1
fi

echo "✓ Arquivo de configuração encontrado:"
echo "$(head -n 5 /opt/totvs/appserver/appserver.ini)"

echo "=== ESTRUTURA DE DIRETÓRIOS ==="
echo "Conteúdo de /opt/totvs/:"
ls -la /opt/totvs/ 2>/dev/null || echo "❌ Diretório /opt/totvs/ não existe"

echo "Conteúdo de /opt/totvs/appserver/:"
ls -la /opt/totvs/appserver/ 2>/dev/null || echo "❌ Diretório /opt/totvs/appserver/ não existe"

echo "=== PROCURANDO EXECUTÁVEL ==="
APPSERVER_EXEC="/opt/totvs/appserver/appsrvlinux"

if [ -x "$APPSERVER_EXEC" ]; then
    echo "✓ Executável encontrado: $APPSERVER_EXEC"
else
    echo "❌ Executável appsrvlinux não encontrado ou não executável"
    echo "Verificando permissões:"
    ls -la /opt/totvs/appserver/appsrvlinux 2>/dev/null || echo "Arquivo não existe"
    exit 1
fi

echo "=== TESTANDO CONECTIVIDADE ==="
echo "Testando conexão com dbaccess-postgres:7890..."
timeout 5 bash -c "</dev/tcp/dbaccess-postgres/7890" 2>/dev/null && echo "✓ DBAccess acessível" || echo "❌ DBAccess inacessível"

echo "Testando conexão com license:5555..."
timeout 5 bash -c "</dev/tcp/license/5555" 2>/dev/null && echo "✓ License Server acessível" || echo "❌ License Server inacessível"

echo "=== INICIANDO APPSERVER ==="
echo "Comando: $APPSERVER_EXEC -config=/opt/totvs/appserver/appserver.ini"

exec "$APPSERVER_EXEC" -config=/opt/totvs/appserver/appserver.ini
