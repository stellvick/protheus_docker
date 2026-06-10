#!/bin/bash

# Script para validar e listar a estrutura completa do projeto

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "════════════════════════════════════════════════════════════"
echo "  🐳 Docker openSUSE Leap 15.4 - Validação de Estrutura"
echo "════════════════════════════════════════════════════════════"
echo ""

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Contadores
TOTAL=0
OK=0
MISSING=0

# Função para validar arquivo
check_file() {
    local file=$1
    local description=$2
    
    TOTAL=$((TOTAL + 1))
    
    if [ -f "$SCRIPT_DIR/$file" ]; then
        echo -e "${GREEN}✓${NC} $file"
        echo "  └─ $description"
        OK=$((OK + 1))
    else
        echo -e "${RED}✗${NC} $file"
        echo "  └─ $description (FALTANDO)"
        MISSING=$((MISSING + 1))
    fi
}

# Função para validar diretório
check_dir() {
    local dir=$1
    local description=$2
    
    TOTAL=$((TOTAL + 1))
    
    if [ -d "$SCRIPT_DIR/$dir" ]; then
        local files=$(find "$SCRIPT_DIR/$dir" -type f -not -path '*/\.*' 2>/dev/null | wc -l)
        echo -e "${GREEN}✓${NC} $dir/ ($files arquivos)"
        echo "  └─ $description"
        OK=$((OK + 1))
    else
        echo -e "${RED}✗${NC} $dir/"
        echo "  └─ $description (FALTANDO)"
        MISSING=$((MISSING + 1))
    fi
}

echo "📄 ARQUIVOS PRINCIPAIS"
echo "─────────────────────────────────────────────────────────"
check_file "Dockerfile" "Imagem Docker base (openSUSE Leap 15.4)"
check_file "docker-compose.yml" "Configuração Docker Compose padrão"
check_file "docker-compose.dev.yml" "Configuração para desenvolvimento"
check_file "docker-compose.prod.yml" "Configuração para produção"
check_file "nginx.conf" "Proxy reverso HTTPS"
echo ""

echo "📝 SCRIPTS"
echo "─────────────────────────────────────────────────────────"
check_file "entrypoint.sh" "Script de inicialização do container"
check_file "generate-certs.sh" "Gerar certificados SSL/TLS"
check_file "init.sh" "Inicializar projeto"
check_file "healthcheck.sh" "Verificação de saúde"
echo ""

echo "⚙️  CONFIGURAÇÃO"
echo "─────────────────────────────────────────────────────────"
check_file ".dockerignore" "Arquivos ignorados no build Docker"
check_file ".gitignore" "Arquivos ignorados pelo Git"
check_file ".env" "Variáveis de ambiente (local)"
check_file ".env.example" "Exemplo de variáveis de ambiente"
check_file "Makefile" "Automação de tarefas"
check_file "package.json" "Metadados do projeto"
echo ""

echo "📚 DOCUMENTAÇÃO"
echo "─────────────────────────────────────────────────────────"
check_file "README.md" "Documentação geral"
check_file "INSTALL.md" "Guia de instalação detalhado"
check_file "COOLIFY.md" "Integração com Coolify"
check_file "STRUCTURE.md" "Estrutura do projeto"
check_file "QUICKSTART.md" "Quick start (5 minutos)"
echo ""

echo "📂 DIRETÓRIOS"
echo "─────────────────────────────────────────────────────────"
check_dir "data" "Dados persistentes da aplicação"
check_dir "logs" "Logs da aplicação"
check_dir "ssl/certs" "Certificados públicos SSL/TLS"
check_dir "ssl/private" "Chaves privadas SSL/TLS"
check_dir ".git" "Repositório Git"
echo ""

echo "════════════════════════════════════════════════════════════"
echo "📊 RESUMO"
echo "════════════════════════════════════════════════════════════"
echo "Total de itens: $TOTAL"
echo -e "${GREEN}OK: $OK${NC}"
[ $MISSING -gt 0 ] && echo -e "${RED}Faltando: $MISSING${NC}" || echo -e "${GREEN}Faltando: 0${NC}"

if [ $MISSING -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Estrutura do projeto está completa!${NC}"
    
    echo ""
    echo "🚀 Próximos passos:"
    echo "   1. chmod +x init.sh"
    echo "   2. ./init.sh"
    echo "   3. make build"
    echo "   4. make up"
    echo "   5. make logs"
    exit 0
else
    echo ""
    echo -e "${RED}✗ Alguns arquivos faltam!${NC}"
    echo "Use 'make init' ou './init.sh' para completar a estrutura."
    exit 1
fi
