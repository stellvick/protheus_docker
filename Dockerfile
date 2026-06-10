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
    unzip && \
    zypper clean -a

# Instalar gdown para download do Google Drive (melhor para arquivos grandes)
RUN pip3 install --no-cache-dir gdown

# Configurar timezone
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Download Protheus from Google Drive usando gdown (melhor para arquivos grandes)
RUN gdown "https://drive.google.com/uc?id=1MY1-rq6vPlDCz88OSK2tZUADa4JnZu5H" -O /protheus.zip && \
    ls -lh /protheus.zip

# Criar diretório de trabalho
WORKDIR /app

# Copiar arquivos (se houver)
COPY . .

# Extrair Protheus
RUN if [ -f /protheus.zip ] && file /protheus.zip | grep -q "Zip archive"; then \
    echo "Extraindo Protheus..." && \
    unzip -q /protheus.zip -d /app/protheus && \
    ls -lh /app/protheus && \
    echo "Extraindo arquivos TAR.GZ..." && \
    cd /app/protheus && \
    for tar_file in *.TAR.GZ; do \
      if [ -f "$tar_file" ]; then \
        echo "Descompactando $tar_file..."; \
        tar -xzf "$tar_file"; \
      fi; \
    done && \
    rm /protheus.zip && \
    echo "Limpando arquivos TAR.GZ..."; \
    rm -f *.TAR.GZ *.ZIP; \
  else \
    echo "AVISO: protheus.zip não é um arquivo ZIP válido ou não foi baixado corretamente"; \
  fi

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
