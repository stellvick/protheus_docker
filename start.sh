#!/bin/bash

# Script que roda um servidor HTTP simples para health checks
# Usado como CMD padrão do container

echo "Starting openSUSE Leap 15.4 container..."
echo "=========================================="
cat /etc/os-release
echo ""
echo "System Information:"
echo "  Hostname: $(hostname)"
echo "  Timezone: $(cat /etc/timezone)"
echo "  Date: $(date)"
echo ""
echo "Directories:"
echo "  /app: $(ls -la /app | wc -l) items"
echo "  /app/data: $(ls -la /app/data 2>/dev/null | wc -l) items"
echo "  /app/logs: $(ls -la /app/logs 2>/dev/null | wc -l) items"
echo ""

# Criar um servidor HTTP simples em Python
echo "Starting HTTP server on port 3000..."
python3 -m http.server 3000 --directory /app --bind 0.0.0.0 2>&1 | while IFS= read -r line; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $line" | tee -a /app/logs/server.log
done
