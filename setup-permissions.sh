#!/bin/bash
#
# Script de configuração de permissões para serviços Protheus
# Prepara o ambiente para execução dos serviços
#

set -e

echo "Configurando permissões para serviços Protheus..."

# Criar diretórios necessários
mkdir -p /var/run/protheus
mkdir -p /var/lock/subsys
mkdir -p /app/logs/protheus
mkdir -p /totvs/protheus/bin/log

# Definir permissões
chmod 755 /var/run/protheus
chmod 755 /var/lock/subsys
chmod 755 /app/logs/protheus
chmod 755 /totvs/protheus/bin/log

# Permitir escrita em diretórios de logs
chmod 777 /app/logs
chmod 777 /totvs/protheus/bin/log

echo "✓ Permissões configuradas"
echo "  - /var/run/protheus"
echo "  - /var/lock/subsys"
echo "  - /app/logs/protheus"
echo "  - /totvs/protheus/bin/log"

exit 0
