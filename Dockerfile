FROM opensuse/leap:15.4

# Instalar pacotes essenciais
RUN zypper refresh && \
    zypper install -y \
    curl \
    wget \
    git \
    openssh \
    openssh-clients \
    vim \
    nano \
    net-tools \
    iputils \
    timezone \
    ca-certificates \
    ca-certificates-mozilla \
    python3 \
    python3-pip \
    unzip \
    tar \
    gzip \
    bzip2 && \
    zypper clean -a

# Instalar gdown para download do Google Drive (melhor para arquivos grandes)
RUN pip3 install --no-cache-dir gdown

# Configurar timezone
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Criar diretório de trabalho
WORKDIR /app

# Copiar arquivos (se houver) 
COPY . .

# Download Protheus from Google Drive
RUN echo "Baixando Protheus..." && \
    gdown --id 1G6aAGlfbAbLv2u8MicoSzjuCdrYJfvf8 --output protheus.zip && \
    echo "Download completo. Verificando arquivo..." && \
    ls -lh protheus.zip && \
    file protheus.zip

RUN mkdir -p /app/totvs/protheus/bin/appbroker \
mkdir -p /app/totvs/protheus/bin/appsec01 \
mkdir -p /app/totvs/protheus/bin/appsec02 \
mkdir -p /app/totvs/protheus/bin/dbaccess \
mkdir -p /app/totvs/protheus/bin/licenseserver \
mkdir -p /app/totvs/protheus/bin/log \
mkdir -p /app/totvs/protheus/rpo \
mkdir -p /app/totvs/protheus_data \
mkdir -p /app/totvs/protheus_data/system \
mkdir -p /app/totvs/protheus_data/systemload

# Extrair Protheus conforme instruções TOTVS
RUN echo "========== INICIANDO EXTRAÇÃO ==========" && \
    mkdir -p /tmp/protheus && \
    echo "Extraindo protheus.zip (com subdirectório)..." && \
    unzip -q protheus.zip -d /tmp && \
    echo "" && \
    echo "Movendo arquivos de Protheus Arquivo para /tmp/protheus..." && \
    mv "/tmp/Protheus Arquivo"/* /tmp/protheus/ 2>/dev/null || true && \
    rm -rf "/tmp/Protheus Arquivo" "/tmp/__MACOSX" 2>/dev/null || true && \
    echo "" && \
    echo "Conteúdo de /tmp/protheus:" && \
    ls -lha /tmp/protheus && \
    echo "========== FIM EXTRAÇÃO INICIAL =========="

# Descompactar Dicionários de Dados
RUN echo "" && \
    echo "========== DICIONÁRIOS ==========" && \
    if [ -f "/tmp/protheus/dicionario.ZIP" ]; then \
      echo "Arquivo encontrado: /tmp/protheus/dicionario.ZIP" && \
      echo "Descompactando em /app/totvs/protheus_data/systemload/..." && \
      unzip -q "/tmp/protheus/dicionario.ZIP" -d /app/totvs/protheus_data/systemload/ && \
      echo "✓ Dicionários extraídos com sucesso" && \
      ls -lha /app/totvs/protheus_data/systemload/; \
    else \
      echo "✗ ERRO: dicionario.ZIP não encontrado em /tmp/protheus/"; \
    fi && \
    echo "========== FIM DICIONÁRIOS =========="

# Descompactar Arquivos de Help
RUN echo "" && \
    echo "========== ARQUIVOS DE HELP ==========" && \
    if [ -f "/tmp/protheus/help.ZIP" ]; then \
      echo "Arquivo encontrado: /tmp/protheus/help.ZIP" && \
      echo "Descompactando em /app/totvs/protheus_data/systemload/..." && \
      unzip -q "/tmp/protheus/help.ZIP" -d /app/totvs/protheus_data/systemload/ && \
      echo "✓ Helps extraídos com sucesso" && \
      ls -lha /app/totvs/protheus_data/systemload/; \
    else \
      echo "✗ ERRO: help.ZIP não encontrado em /tmp/protheus/"; \
    fi && \
    echo "========== FIM ARQUIVOS DE HELP =========="

# Descompactar Arquivos de Menu
RUN echo "" && \
    echo "========== ARQUIVOS DE MENU ==========" && \
    if [ -f "/tmp/protheus/menu.ZIP" ]; then \
      echo "Arquivo encontrado: /tmp/protheus/menu.ZIP" && \
      echo "Descompactando em /app/totvs/protheus_data/system/..." && \
      unzip -q "/tmp/protheus/menu.ZIP" -d /app/totvs/protheus_data/system/ && \
      echo "✓ Menus extraídos com sucesso" && \
      ls -lha /app/totvs/protheus_data/system/; \
    else \
      echo "✗ ERRO: menu.ZIP não encontrado em /tmp/protheus/"; \
    fi && \
    echo "========== FIM ARQUIVOS DE MENU =========="

# Descompactar DBAccess
RUN echo "" && \
    echo "========== DBACCESS ==========" && \
    if [ -f "/tmp/protheus/dbaccess.TAR.GZ" ]; then \
      echo "Arquivo encontrado: /tmp/protheus/dbaccess.TAR.GZ" && \
      echo "Tamanho: $(ls -lh /tmp/protheus/dbaccess.TAR.GZ | awk '{print $5}')" && \
      echo "Descompactando em /app/totvs/protheus/bin/dbaccess/..." && \
      tar -xf "/tmp/protheus/dbaccess.TAR.GZ" -C /app/totvs/protheus/bin/dbaccess/ && \
      echo "✓ DBAccess extraído com sucesso" && \
      ls -lha /app/totvs/protheus/bin/dbaccess/; \
    else \
      echo "✗ ERRO: dbaccess.TAR.GZ não encontrado em /tmp/protheus/"; \
    fi && \
    echo "========== FIM DBACCESS =========="

# Descompactar AppServer
RUN echo "" && \
    echo "========== APPSERVER ==========" && \
    if [ -f "/tmp/protheus/appserver.TAR.GZ" ]; then \
      echo "Arquivo encontrado: /tmp/protheus/appserver.TAR.GZ" && \
      echo "Tamanho: $(ls -lh /tmp/protheus/appserver.TAR.GZ | awk '{print $5}')" && \
      echo "Descompactando em /app/totvs/protheus/bin/appbroker/..." && \
      tar -xf "/tmp/protheus/appserver.TAR.GZ" -C /app/totvs/protheus/bin/appbroker/ && \
      echo "✓ AppServer extraído com sucesso" && \
      ls -lha /app/totvs/protheus/bin/appbroker/; \
    else \
      echo "✗ ERRO: appserver.TAR.GZ não encontrado!"; \
      echo "Arquivos realmente disponíveis em /tmp/protheus:"; \
      ls -lha /tmp/protheus/; \
    fi && \
    echo "========== FIM APPSERVER =========="

# Configurar Licença (descontinuado após 12.1.2210, mas mantemos estrutura)
# RUN if [ -f "/tmp/protheus/licence.TAR.GZ" ]; then \
#       echo "Processando Licença..." && \
#       tar -xf "/tmp/protheus/licence.TAR.GZ" -C /app/totvs/protheus/bin/licenseserver/; \
#     fi

# Copiar Repositório de Objetos
RUN echo "" && \
    echo "========== REPOSITÓRIO DE OBJETOS ==========" && \
    if [ -f "/tmp/protheus/TTTM120.RPO" ]; then \
      echo "Arquivo encontrado: /tmp/protheus/TTTM120.RPO" && \
      echo "Tamanho: $(ls -lh /tmp/protheus/TTTM120.RPO | awk '{print $5}')" && \
      echo "Copiando para /app/totvs/protheus/rpo/..." && \
      cp "/tmp/protheus/TTTM120.RPO" /app/totvs/protheus/rpo/tttp120.rpo && \
      echo "✓ Repositório copiado com sucesso" && \
      ls -lh /app/totvs/protheus/rpo/; \
    else \
      echo "✗ ERRO: TTTM120.RPO não encontrado em /tmp/protheus/"; \
    fi && \
    echo "========== FIM REPOSITÓRIO =========="

# Copiar serviços de Broker e Secundários
RUN echo "" && \
    echo "========== CONFIGURANDO SERVIÇOS ==========" && \
    if [ -d "/app/totvs/protheus/bin/appbroker" ] && [ "$(ls -A /app/totvs/protheus/bin/appbroker/)" ]; then \
      echo "✓ AppBroker encontrado com conteúdo:" && \
      ls -lha /app/totvs/protheus/bin/appbroker/ && \
      echo "" && \
      if [ -d "/app/totvs/protheus/bin/appsec01" ]; then \
        echo "Copiando para AppSec01..." && \
        cp -rf /app/totvs/protheus/bin/appbroker/* /app/totvs/protheus/bin/appsec01/ && \
        echo "✓ AppSec01 - OK"; \
      fi && \
      if [ -d "/app/totvs/protheus/bin/appsec02" ]; then \
        echo "Copiando para AppSec02..." && \
        cp -rf /app/totvs/protheus/bin/appbroker/* /app/totvs/protheus/bin/appsec02/ && \
        echo "✓ AppSec02 - OK"; \
      fi; \
    else \
      echo "✗ AVISO: AppBroker está vazio em /app/totvs/protheus/bin/appbroker/"; \
      echo "O arquivo appserver.TAR.GZ pode não ter sido extraído corretamente"; \
    fi && \
    echo "========== FIM CONFIGURAÇÃO SERVIÇOS =========="

# Resumo final da estrutura
RUN echo "" && \
    echo "========== RESUMO FINAL ==========" && \
    echo "Estrutura de diretórios criada:" && \
    echo "" && \
    echo "--- Protheus Bin ---" && \
    find /app/totvs/protheus/bin -type d | head -20 && \
    echo "" && \
    echo "--- Protheus Rpo ---" && \
    ls -lha /app/totvs/protheus/rpo/ && \
    echo "" && \
    echo "--- Protheus Data ---" && \
    find /app/totvs/protheus_data -type f | wc -l && echo "arquivos em protheus_data" && \
    echo "" && \
    echo "Limpando arquivos temporários..." && \
    rm -rf /tmp/protheus && \
    rm -f /app/protheus.zip && \
    echo "Limpeza concluída!" && \
    echo "========== FIM RESUMO =========="

# Copiar scripts de serviços e inicialização
COPY advpl_config/ /app/advpl_config/
COPY advpl_scripts/totvs* /usr/local/bin/
COPY setup-permissions.sh /usr/local/bin/setup-permissions.sh
COPY setup-config.sh /usr/local/bin/setup-config.sh
COPY start.sh /usr/local/bin/start.sh
COPY init-services.sh /usr/local/bin/init-services.sh
RUN chmod +x /usr/local/bin/setup-permissions.sh /usr/local/bin/setup-config.sh /usr/local/bin/start.sh /usr/local/bin/init-services.sh /usr/local/bin/totvs*

# Configurar ODBC
RUN zypper install -y unixODBC unixODBC-devel postgresql postgresql-devel postgresql13-odbc && \
    mkdir -p /etc/unixODBC && \
    mkdir -p /tmp/protheus

# Copiar configurações ODBC
COPY advpl_config/odbc.ini /etc/unixODBC/odbc.ini
COPY advpl_config/odbcinst.ini /etc/unixODBC/odbcinst.ini
RUN chmod 644 /etc/unixODBC/odbc.ini && \
    chmod 644 /etc/unixODBC/odbcinst.ini

# Configurar variáveis de ambiente para ODBC
ENV ODBCINI=/etc/unixODBC/odbc.ini
ENV ODBCSYSINI=/etc/unixODBC
ENV LIBPATH=/usr/lib64:$LIBPATH

# Expor porta padrão
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Comando padrão
CMD ["/usr/local/bin/start.sh"]
