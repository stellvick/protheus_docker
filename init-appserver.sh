#!/bin/bash

# Script de inicialização do AppServer
set -e

echo "=== INICIANDO DEBUG DO APPSERVER ==="

# Verifica se o arquivo de configuração existe
if [ ! -f "/opt/totvs/appserver/appserver.ini" ]; then
    echo "ERRO: Arquivo appserver.ini não encontrado!"
    exit 1
fi

echo "✓ Arquivo de configuração encontrado:"
echo "$(head -n 5 /opt/totvs/appserver/appserver.ini)"

# Lista estrutura de diretórios importantes
echo "=== ESTRUTURA DE DIRETÓRIOS ==="
echo "Conteúdo de /opt/totvs/:"
ls -la /opt/totvs/ 2>/dev/null || echo "❌ Diretório /opt/totvs/ não existe"

echo "Conteúdo de /opt/totvs/appserver/:"
ls -la /opt/totvs/appserver/ 2>/dev/null || echo "❌ Diretório /opt/totvs/appserver/ não existe"

# Procura pelo executável do AppServer
echo "=== PROCURANDO EXECUTÁVEL ==="
APPSERVER_EXEC=""
POSSIBLE_PATHS=(
    "/opt/totvs/appserver/appserver"
    "/opt/totvs/bin/appserver"
    "/usr/local/bin/appserver"
    "/opt/totvs/appserver/bin/appserver"
    "/totvs/appserver/appserver"
    "/opt/totvs/12/bin/appserver/appserver"
)

for path in "${POSSIBLE_PATHS[@]}"; do
    if [ -x "$path" ]; then
        APPSERVER_EXEC="$path"
        echo "✓ Executável encontrado: $APPSERVER_EXEC"
        break
    else
        echo "❌ Não encontrado: $path"
    fi
done

# Se não encontrou, faz busca ampla
if [ -z "$APPSERVER_EXEC" ]; then
    echo "⚠️  Executável não encontrado nos caminhos padrão!"
    echo "Fazendo busca ampla por executáveis appserver:"
    find /opt -name "*appserver*" -type f -executable 2>/dev/null | head -10
    find /usr -name "*appserver*" -type f -executable 2>/dev/null | head -10
    
    # Verifica se existe algum executável na imagem base
    echo "Verificando ENTRYPOINT/CMD da imagem:"
    cat /proc/1/cmdline 2>/dev/null | tr '\0' ' ' || echo "Não foi possível verificar"
    
    exit 1
fi

echo "=== TESTANDO CONECTIVIDADE ==="
# Testa conectividade com dependências usando timeout e /dev/tcp
echo "Testando conexão com dbaccess-postgres:7890..."
timeout 5 bash -c "</dev/tcp/dbaccess-postgres/7890" 2>/dev/null && echo "✓ DBAccess acessível" || echo "❌ DBAccess inacessível"

echo "Testando conexão com license:5555..."
timeout 5 bash -c "</dev/tcp/license/5555" 2>/dev/null && echo "✓ License Server acessível" || echo "❌ License Server inacessível"

echo "=== INICIANDO APPSERVER ==="
echo "Comando: $APPSERVER_EXEC -console -config=/opt/totvs/appserver/appserver.ini"

# Executa o AppServer com logs detalhados
exec "$APPSERVER_EXEC" -console -config=/opt/totvs/appserver/appserver.ini
