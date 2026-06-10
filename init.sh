#!/bin/bash

# Script para inicializar o projeto completamente
# Uso: ./init.sh

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "🚀 Inicializando projeto Docker..."
echo ""

# 1. Criar estrutura de diretórios
echo "📁 Criando estrutura de diretórios..."
mkdir -p "$SCRIPT_DIR/ssl/certs"
mkdir -p "$SCRIPT_DIR/ssl/private"
mkdir -p "$SCRIPT_DIR/data"
mkdir -p "$SCRIPT_DIR/logs"

chmod 700 "$SCRIPT_DIR/ssl/private"
chmod 755 "$SCRIPT_DIR/ssl/certs"
chmod 755 "$SCRIPT_DIR/data"
chmod 755 "$SCRIPT_DIR/logs"

echo "✓ Diretórios criados"

# 2. Verificar .env
echo ""
echo "🔧 Verificando arquivo de configuração..."
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "⚠️  .env não encontrado, criando a partir de .env.example"
    cp "$SCRIPT_DIR/.env.example" "$SCRIPT_DIR/.env"
    echo "✓ .env criado (edite conforme necessário)"
else
    echo "✓ .env já existe"
fi

# 3. Verificar certificados
echo ""
echo "🔐 Verificando certificados SSL/TLS..."
if [ ! -f "$SCRIPT_DIR/ssl/private/key.pem" ] || [ ! -f "$SCRIPT_DIR/ssl/certs/cert.pem" ]; then
    echo "⚠️  Certificados não encontrados"
    echo "Deseja gerar certificados auto-assinados? (s/n)"
    read -r response
    if [ "$response" = "s" ]; then
        chmod +x "$SCRIPT_DIR/generate-certs.sh"
        "$SCRIPT_DIR/generate-certs.sh"
    else
        echo "⚠️  Você precisará gerar certificados para iniciar"
    fi
else
    echo "✓ Certificados já existem"
    echo ""
    echo "ℹ️  Informações do certificado:"
    openssl x509 -in "$SCRIPT_DIR/ssl/certs/cert.pem" -text -noout | grep -A1 "Subject:\|Issuer:\|Not Before\|Not After"
fi

# 4. Verificar permissões de scripts
echo ""
echo "📝 Ajustando permissões de scripts..."
chmod +x "$SCRIPT_DIR/generate-certs.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/entrypoint.sh" 2>/dev/null || true
echo "✓ Permissões ajustadas"

# 5. Validar Docker Compose
echo ""
echo "✅ Validando docker-compose.yml..."
docker-compose config > /dev/null && echo "✓ docker-compose.yml é válido" || echo "✗ Erro em docker-compose.yml"

# 6. Resumo
echo ""
echo "════════════════════════════════════════════"
echo "✨ Projeto inicializado com sucesso!"
echo "════════════════════════════════════════════"
echo ""
echo "📋 Próximos passos:"
echo "   1. (Opcional) Editar .env"
echo "   2. make build    (ou: docker-compose build)"
echo "   3. make up       (ou: docker-compose up -d)"
echo "   4. make logs     (ou: docker-compose logs -f)"
echo ""
echo "📚 Documentação:"
echo "   - README.md  : Visão geral do projeto"
echo "   - INSTALL.md : Guia detalhado de instalação"
echo ""
echo "🔗 URLs:"
echo "   HTTP  → http://localhost"
echo "   HTTPS → https://localhost"
echo ""
echo "ℹ️  Use 'make help' para ver todos os comandos disponíveis"
echo ""
