#!/bin/bash
set -e

echo "Iniciando openSUSE Leap 15.4 container..."

# Criar diretórios necessários
mkdir -p /app/data
mkdir -p /app/logs
mkdir -p /app/ssl

# Definir permissões
chmod 755 /app/data
chmod 755 /app/logs
chmod 700 /app/ssl

# Exibir informações do sistema
echo "=== System Information ==="
cat /etc/os-release
echo ""
echo "=== Timezone ==="
date
echo ""

# Executar comando passado
exec "$@"
