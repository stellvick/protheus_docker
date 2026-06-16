#!/bin/bash
set -e

ODBC_INI="/etc/unixODBC/odbc.ini"

DB_HOST="${DB_HOST:-postgres}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-tpprd}"
DB_USER="${DB_USER:-tpprd}"
DB_PASSWORD="${DB_PASSWORD:-123456}"

echo "Configurando ODBC com DB_HOST=${DB_HOST}, DB_PORT=${DB_PORT}, DB_NAME=${DB_NAME}, DB_USER=${DB_USER}"

sed -i "s|PROTHEUS_DB_HOST|${DB_HOST}|g" "${ODBC_INI}"
sed -i "s|PROTHEUS_DB_PORT|${DB_PORT}|g" "${ODBC_INI}"
sed -i "s|PROTHEUS_DB_NAME|${DB_NAME}|g" "${ODBC_INI}"
sed -i "s|PROTHEUS_DB_USER|${DB_USER}|g" "${ODBC_INI}"
sed -i "s|PROTHEUS_DB_PASSWORD|${DB_PASSWORD}|g" "${ODBC_INI}"

echo "ODBC configurado:"
cat "${ODBC_INI}"

echo ""
echo "Testando resolução DNS do host '${DB_HOST}'..."
if getent hosts "${DB_HOST}" > /dev/null 2>&1; then
    RESOLVED_IP=$(getent hosts "${DB_HOST}" | awk '{print $1}')
    echo "OK: ${DB_HOST} resolve para ${RESOLVED_IP}"
else
    echo "AVISO: Não foi possível resolver '${DB_HOST}' via DNS."
    echo "Verificando /etc/hosts..."
    grep "${DB_HOST}" /etc/hosts 2>/dev/null || echo "Hostname não encontrado em /etc/hosts"
    echo "O container pode não conseguir conectar ao banco de dados."
fi
