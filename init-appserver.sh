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

echo "=== TESTANDO CONECTIVIDADE ==="
timeout 5 bash -c "</dev/tcp/dbaccess-postgres/7890" 2>/dev/null && echo "✓ DBAccess acessível" || echo "❌ DBAccess inacessível"
timeout 5 bash -c "</dev/tcp/license/5555" 2>/dev/null && echo "✓ License Server acessível" || echo "❌ License Server inacessível"

echo "=== VERIFICANDO ARQUIVOS NECESSÁRIOS ==="
echo "Verificando RPO:"
ls -la /opt/totvs/protheus/apo/tttm120.rpo || echo "❌ RPO não encontrado"

echo "Verificando dicionários:"
ls -la /opt/totvs/protheus/protheus_data/systemload/sx2.unq || echo "❌ sx2.unq não encontrado"
ls -la /opt/totvs/protheus/protheus_data/systemload/sxsbra.txt || echo "❌ sxsbra.txt não encontrado"

echo "=== INICIANDO APPSERVER ==="
echo "Mudando para diretório do AppServer..."
cd /opt/totvs/appserver

echo "Limpando logs anteriores..."
rm -f console.log console_error.log console_output.log

echo "Iniciando AppServer:"
"$APPSERVER_EXEC" > console_output.log 2>&1 &
APPSERVER_PID=$!

echo "AppServer iniciado com PID: $APPSERVER_PID"

echo "Aguardando inicialização..."
sleep 15

if ps -p $APPSERVER_PID > /dev/null; then
    echo "✓ AppServer ainda está rodando"
    
    echo "=== TESTANDO PORTAS ==="
    echo "Testando porta 8080 (WebApp):"
    timeout 3 bash -c "</dev/tcp/localhost/8080" 2>/dev/null && echo "✓ Porta 8080 ativa" || echo "❌ Porta 8080 inativa"
    
    echo "Testando porta 8081 (REST):"
    timeout 3 bash -c "</dev/tcp/localhost/8081" 2>/dev/null && echo "✓ Porta 8081 ativa" || echo "❌ Porta 8081 inativa"
    
    echo "Testando porta 9090 (SmartClient Web):"
    timeout 3 bash -c "</dev/tcp/localhost/9090" 2>/dev/null && echo "✓ Porta 9090 ativa" || echo "❌ Porta 9090 inativa"
    
    echo "Últimas linhas do log:"
    tail -20 console_output.log 2>/dev/null || echo "Nenhum log encontrado"
    
    echo "AppServer inicializado com sucesso! Mantendo em execução..."
    tail -f console_output.log &
    wait $APPSERVER_PID
else
    echo "❌ AppServer parou. Logs:"
    cat console_output.log 2>/dev/null || echo "Nenhum log encontrado"
    
    echo "Verificando logs de erro:"
    cat console.log 2>/dev/null || echo "Nenhum console.log"
    cat console_error.log 2>/dev/null || echo "Nenhum console_error.log"
    
    exit 1
fi
