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
    unzip && \
    zypper clean -a

# Configurar timezone
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Download Protheus from Google Drive (com suporte para confirmação)
RUN wget --quiet --load-cookies /tmp/cookies.txt \
  "https://drive.google.com/uc?export=download&confirm=t&id=1MY1-rq6vPlDCz88OSK2tZUADa4JnZu5H" \
  -O /protheus.zip && \
  rm -f /tmp/cookies.txt && \
  ls -lh /protheus.zip

# Criar diretório de trabalho
WORKDIR /app

# Copiar arquivos (se houver)
COPY . .

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
