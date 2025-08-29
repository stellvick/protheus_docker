#!/bin/bash

# Script de inicialização do AppServer
set -e

echo "Iniciando AppServer..."

# Verifica se o arquivo de configuração existe
if [ ! -f "/opt/totvs/appserver/appserver.ini" ]; then
    echo "ERRO: Arquivo appserver.ini não encontrado!"
    exit 1
fi

echo "Arquivo de configuração encontrado:"
echo "$(head -n 3 /opt/totvs/appserver/appserver.ini)"

echo "Iniciando AppServer com configuração..."
exec /opt/totvs/appserver/appserver -console -config=/opt/totvs/appserver/appserver.ini
