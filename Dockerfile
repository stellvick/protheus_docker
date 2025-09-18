FROM opensuse/leap:15.4

RUN zypper refresh && zypper install -y \
    unzip \
    tar \
    gzip \
    openssl \
    libcurl4 \
    libxml2 \
    libxslt \
    unixODBC \
    && mkdir -p /opt/totvs/appserver \
    && mkdir -p /opt/totvs/protheus/apo \
    && mkdir -p /opt/totvs/protheus/protheus_data/system \
    && mkdir -p /opt/totvs/protheus/protheus_data/systemload

# Copia arquivos necessários
COPY appserver.tar.GZ /tmp/
COPY appserver.ini /opt/totvs/appserver/
COPY *.rpo /opt/totvs/protheus/apo/
COPY *.unq /opt/totvs/protheus/protheus_data/systemload/
COPY *.txt /opt/totvs/protheus/protheus_data/systemload/
COPY menus/ /opt/totvs/protheus/protheus_data/system/
COPY help/ /tmp/

# Debug: mostra se o help folder realmente está presente
RUN ls -lh /tmp/help/ || echo "⚠️ help folder not found"

# Copia arquivos do help se a pasta existir
RUN if [ -d /tmp/help ]; then \
      cp /tmp/help/*.txt /opt/totvs/protheus/protheus_data/systemload/; \
    else \
      echo "⚠️ help folder not found, skipping."; \
    fi \
    && echo "Verificando arquivos copiados:" \
    && ls -la /opt/totvs/appserver/ \
    && ls -la /opt/totvs/protheus/apo/ \
    && ls -la /opt/totvs/protheus/protheus_data/system/ \
    && ls -la /opt/totvs/protheus/protheus_data/systemload/

# CMD padrão (pode descomentar quando quiser rodar o appserver)
# CMD ["/opt/totvs/appserver/appsrvlinux"]
