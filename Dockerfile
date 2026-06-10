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
    tar && \
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
    gdown --id 1MY1-rq6vPlDCz88OSK2tZUADa4JnZu5H --output protheus.zip && \
    echo "Download completo. Verificando arquivo..." && \
    ls -lh protheus.zip && \
    file protheus.zip

# Extrair Protheus
RUN echo "Iniciando extração..." && \
    mkdir -p protheus && \
    unzip -q protheus.zip -d protheus && \
    echo "Primeiro nível extraído:" && \
    ls -lh protheus && \
    echo "" && \
    echo "Descompactando TAR.GZ..." && \
    cd protheus && \
    for tar_file in *.tar.gz *.TAR.GZ; do \
      if [ -f "$tar_file" ]; then \
        echo "Processando: $tar_file"; \
        tar -xzf "$tar_file" || echo "Erro ao extrair $tar_file"; \
      fi; \
    done && \
    cd /app && \
    echo "Limpeza de arquivos compactados..." && \
    rm -f protheus.zip && \
    cd protheus && \
    rm -f *.tar.gz *.TAR.GZ *.zip *.ZIP && \
    cd /app && \
    echo "Extração completa!" && \
    echo "Estrutura final:" && \
    ls -lh protheus

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
