#!/bin/bash

# Healthcheck para container
# Verifica se a aplicação está respondendo

PORT=${PORT:-3000}
TIMEOUT=${TIMEOUT:-10}
RETRIES=${RETRIES:-3}

# Função para fazer healthcheck
healthcheck() {
    if command -v curl &> /dev/null; then
        curl -sf "http://localhost:${PORT}/" > /dev/null 2>&1
        return $?
    elif command -v wget &> /dev/null; then
        wget --quiet --tries=1 --spider "http://localhost:${PORT}/" > /dev/null 2>&1
        return $?
    else
        # Fallback: verificar se porta está aberta
        timeout 1 bash -c "cat < /dev/null > /dev/tcp/127.0.0.1/${PORT}" 2>/dev/null
        return $?
    fi
}

# Tentar healthcheck
for i in $(seq 1 $RETRIES); do
    if healthcheck; then
        echo "✓ Application is healthy (attempt $i/$RETRIES)"
        exit 0
    else
        if [ $i -lt $RETRIES ]; then
            echo "✗ Application not ready (attempt $i/$RETRIES), retrying..."
            sleep 2
        fi
    fi
done

echo "✗ Application failed healthcheck after $RETRIES attempts"
exit 1
