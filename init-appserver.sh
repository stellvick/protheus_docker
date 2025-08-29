#!/bin/bash

# Script de inicialização do AppServer
# Garante que o appserver.ini seja um arquivo e não um diretório

set -e

echo "Iniciando configuração do AppServer..."

# Remove o diretório appserver.ini se existir
if [ -d "/opt/totvs/appserver/appserver.ini" ]; then
    echo "Removendo diretório incorreto appserver.ini..."
    rm -rf /opt/totvs/appserver/appserver.ini
fi

# Copia o arquivo de configuração
if [ -f "/opt/totvs/appserver/config/appserver.ini" ]; then
    echo "Copiando arquivo de configuração..."
    cp /opt/totvs/appserver/config/appserver.ini /opt/totvs/appserver/appserver.ini
    echo "Arquivo appserver.ini configurado com sucesso!"
else
    echo "ERRO: Arquivo de configuração não encontrado!"
    exit 1
fi

# Verifica se o arquivo foi criado corretamente
if [ -f "/opt/totvs/appserver/appserver.ini" ]; then
    echo "Verificação: appserver.ini é um arquivo válido"
    echo "Primeiras linhas do arquivo:"
    head -n 5 /opt/totvs/appserver/appserver.ini
else
    echo "ERRO: appserver.ini não foi criado corretamente!"
    exit 1
fi

echo "Iniciando AppServer..."
exec /opt/totvs/appserver/appserver -console -config=/opt/totvs/appserver/appserver.ini
