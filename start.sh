#!/bin/bash

# Script que roda um servidor HTTP simples para health checks
# Compatível com Python 3.6+ (openSUSE Leap 15.4)

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

# Criar um servidor HTTP simples em Python (compatível com Python 3.6+)
echo "Starting HTTP server on port 3000..."
echo "Access at http://localhost:3000"
echo "Press Ctrl+C to stop"
echo ""

# Mudar para diretório da app e rodar servidor HTTP
cd /app && python3 -m http.server 3000 2>&1 | while IFS= read -r line; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $line" | tee -a /app/logs/server.log
done
