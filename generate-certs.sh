#!/bin/bash

# Script para gerar certificados SSL/TLS
# Uso: ./generate-certs.sh

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SSL_DIR="$SCRIPT_DIR/ssl"
CERTS_DIR="$SSL_DIR/certs"
PRIVATE_DIR="$SSL_DIR/private"

echo "🔐 Gerando certificados SSL/TLS..."

# Criar diretórios
mkdir -p "$CERTS_DIR"
mkdir -p "$PRIVATE_DIR"

# Definir permissões
chmod 700 "$PRIVATE_DIR"

# Configurações padrão
COUNTRY="${COUNTRY:-BR}"
STATE="${STATE:-Sao Paulo}"
CITY="${CITY:-Sao Paulo}"
ORG="${ORG:-MyOrganization}"
CN="${CN:-localhost}"
DAYS="${DAYS:-365}"

echo "📋 Configurações:"
echo "  País: $COUNTRY"
echo "  Estado: $STATE"
echo "  Cidade: $CITY"
echo "  Organização: $ORG"
echo "  Common Name: $CN"
echo "  Validade: $DAYS dias"
echo ""

# Verificar se já existem certificados
if [ -f "$PRIVATE_DIR/key.pem" ] && [ -f "$CERTS_DIR/cert.pem" ]; then
    echo "⚠️  Certificados já existem!"
    echo "   Deseja sobrescrever? (s/n)"
    read -r response
    if [ "$response" != "s" ]; then
        echo "❌ Operação cancelada"
        exit 1
    fi
fi

# Gerar chave privada
echo "🔑 Gerando chave privada..."
openssl genrsa -out "$PRIVATE_DIR/key.pem" 2048

# Gerar CSR (Certificate Signing Request)
echo "📝 Gerando CSR..."
openssl req -new \
  -key "$PRIVATE_DIR/key.pem" \
  -out "$PRIVATE_DIR/csr.pem" \
  -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/CN=$CN"

# Gerar certificado auto-assinado
echo "✍️  Gerando certificado auto-assinado..."
openssl x509 -req \
  -in "$PRIVATE_DIR/csr.pem" \
  -signkey "$PRIVATE_DIR/key.pem" \
  -out "$CERTS_DIR/cert.pem" \
  -days "$DAYS" \
  -extfile <(printf "subjectAltName=DNS:localhost,DNS:127.0.0.1,IP:127.0.0.1")

# Limpar CSR temporário
rm "$PRIVATE_DIR/csr.pem"

# Definir permissões apropriadas
chmod 600 "$PRIVATE_DIR/key.pem"
chmod 644 "$CERTS_DIR/cert.pem"

echo ""
echo "✅ Certificados gerados com sucesso!"
echo ""
echo "📁 Localização:"
echo "   Certificado: $CERTS_DIR/cert.pem"
echo "   Chave privada: $PRIVATE_DIR/key.pem"
echo ""
echo "ℹ️  Informações do certificado:"
openssl x509 -in "$CERTS_DIR/cert.pem" -text -noout | grep -A1 "Subject:\|Issuer:\|Not Before\|Not After"
echo ""
echo "⚠️  Lembrete: Este é um certificado auto-assinado!"
echo "    Para produção, use certificados de uma CA confiável."
