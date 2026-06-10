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

RUN mkdir -p /totvs/protheus/bin/appbroker \
mkdir -p /totvs/protheus/bin/appsec01 \
mkdir -p /totvs/protheus/bin/appsec02 \
mkdir -p /totvs/protheus/bin/dbaccess \
mkdir -p /totvs/protheus/bin/licenseserver \
mkdir -p /totvs/protheus/bin/log \
mkdir -p /totvs/protheus/rpo \
mkdir -p /totvs/protheus_data \
mkdir -p /totvs/protheus_data/system \
mkdir -p /totvs/protheus_data/systemload

# Extrair Protheus conforme instruções TOTVS
RUN echo "Iniciando extração..." && \
    mkdir -p /tmp/protheus && \
    unzip -q protheus.zip -d /tmp/protheus && \
    echo "Arquivo extraído em /tmp/protheus" && \
    ls -lh /tmp/protheus

# Descompactar Dicionários de Dados
RUN if [ -f "/tmp/protheus/dicionario.ZIP" ]; then \
      echo "Descompactando dicionários..." && \
      unzip -q "/tmp/protheus/dicionario.ZIP" -d /totvs/protheus_data/systemload/; \
    fi

# Descompactar Arquivos de Help
RUN if [ -f "/tmp/protheus/help.ZIP" ]; then \
      echo "Descompactando helps..." && \
      unzip -q "/tmp/protheus/help.ZIP" -d /totvs/protheus_data/systemload/; \
    fi

# Descompactar Arquivos de Menu
RUN if [ -f "/tmp/protheus/menu.ZIP" ]; then \
      echo "Descompactando menus..." && \
      unzip -q "/tmp/protheus/menu.ZIP" -d /totvs/protheus_data/system/; \
    fi

# Descompactar DBAccess
RUN if [ -f "/tmp/protheus/dbaccess.TAR.GZ" ]; then \
      echo "Descompactando DBAccess..." && \
      tar -xf "/tmp/protheus/dbaccess.TAR.GZ" -C /totvs/protheus/bin/dbaccess/; \
    fi

# Descompactar AppServer
RUN if [ -f "/tmp/protheus/appserver.TAR.GZ" ]; then \
      echo "Descompactando AppServer..." && \
      tar -xf "/tmp/protheus/appserver.TAR.GZ" -C /totvs/protheus/bin/appbroker/; \
    fi

# Configurar Licença (descontinuado após 12.1.2210, mas mantemos estrutura)
RUN if [ -f "/tmp/protheus/licence.TAR.GZ" ]; then \
      echo "Processando Licença..." && \
      tar -xf "/tmp/protheus/licence.TAR.GZ" -C /totvs/protheus/bin/licenseserver/; \
    fi

# Copiar Repositório de Objetos
RUN if [ -f "/tmp/protheus/TTTM120.RPO" ]; then \
      echo "Copiando repositório..." && \
      cp "/tmp/protheus/TTTM120.RPO" /totvs/protheus/rpo/tttp120.rpo; \
    fi

# Copiar serviços de Broker e Secundários (Lock Server, descontinuado após 12.1.2210)
RUN echo "Configurando serviços..." && \
    if [ -d "/totvs/protheus/bin/appbroker" ] && [ -d "/totvs/protheus/bin/appsec01" ]; then \
      cp -rf /totvs/protheus/bin/appbroker/* /totvs/protheus/bin/appsec01/ 2>/dev/null || true && \
      cp -rf /totvs/protheus/bin/appbroker/* /totvs/protheus/bin/appsec02/ 2>/dev/null || true; \
    fi

# Limpeza de arquivos temporários
RUN echo "Limpando arquivos temporários..." && \
    rm -rf /tmp/protheus && \
    rm -f protheus.zip && \
    echo "Extração completa!"

# Copiar script de inicialização
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Expor porta padrão
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Comando padrão
CMD ["/usr/local/bin/start.sh"]
