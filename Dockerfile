FROM opensuse/leap:15.4

RUN zypper refresh && \
    zypper install -y \
    curl \
    wget \
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
    bzip2 \
    unixODBC \
    postgresql-odbc \
    glibc-locale && \
    zypper clean -a

RUN pip3 install --no-cache-dir gdown

ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /app

RUN mkdir -p /app/totvs/protheus/bin/appbroker && \
    mkdir -p /app/totvs/protheus/bin/appsec01 && \
    mkdir -p /app/totvs/protheus/bin/appsec02 && \
    mkdir -p /app/totvs/protheus/bin/dbaccess && \
    mkdir -p /app/totvs/protheus/bin/licenseserver && \
    mkdir -p /app/totvs/protheus/bin/log && \
    mkdir -p /app/totvs/protheus/rpo && \
    mkdir -p /app/totvs/protheus_data/system && \
    mkdir -p /app/totvs/protheus_data/systemload && \
    mkdir -p /tmp/protheus && \
    mkdir -p /etc/unixODBC

ARG PROTHEUS_GDRIVE_ID=1G6aAGlfbAbLv2u8MicoSzjuCdrYJfvf8
RUN echo "Baixando Protheus..." && \
    gdown --id ${PROTHEUS_GDRIVE_ID} --output protheus.zip && \
    echo "Download completo. Extraindo..." && \
    unzip -o protheus.zip -d /app/totvs/ && \
    echo "Extração completa." && \
    ls -lha /app/totvs/protheus/bin/ && \
    ls -lha /app/totvs/protheus/rpo/ && \
    rm -f /app/protheus.zip && \
    echo "Limpeza concluída."

COPY advpl_config/odbc.ini /etc/unixODBC/odbc.ini
COPY advpl_config/odbcinst.ini /etc/unixODBC/odbcinst.ini
RUN chmod 644 /etc/unixODBC/odbc.ini && \
    chmod 644 /etc/unixODBC/odbcinst.ini

COPY scripts/start.sh /usr/local/bin/start.sh
COPY scripts/setup-config.sh /usr/local/bin/setup-config.sh
COPY scripts/setup-permissions.sh /usr/local/bin/setup-permissions.sh
COPY scripts/init-services.sh /usr/local/bin/init-services.sh
RUN chmod +x /usr/local/bin/start.sh \
    /usr/local/bin/setup-config.sh \
    /usr/local/bin/setup-permissions.sh \
    /usr/local/bin/init-services.sh

ENV ODBCINI=/etc/unixODBC/odbc.ini
ENV ODBCSYSINI=/etc/unixODBC
ENV LD_LIBRARY_PATH=/usr/lib64:$LD_LIBRARY_PATH

EXPOSE 3000 6000 7000 8000-8010 9000

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

CMD ["/usr/local/bin/start.sh"]
