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
COPY help.zip /tmp/

# Debug: mostra se o help.zip realmente está presente e válido
RUN ls -lh /tmp/help.zip && unzip -t /tmp/help.zip || echo "⚠️ help.zip inválido ou corrompido"

# Descompacta help.zip se for válido
RUN if unzip -t /tmp/help.zip >/dev/null 2>&1; then \
      unzip -o /tmp/help.zip -d /tmp/help && \
      cp /tmp/help/*.txt /opt/totvs/protheus/protheus_data/systemload/; \
    else \
      echo "⚠️ help.zip não é válido, pulando etapa de extração."; \
    fi \
    && echo "Verificando arquivos copiados:" \
    && ls -la /opt/totvs/appserver/ \
    && ls -la /opt/totvs/protheus/apo/ \
    && ls -la /opt/totvs/protheus/protheus_data/system/ \
    && ls -la /opt/totvs/protheus/protheus_data/systemload/

# CMD padrão (pode descomentar quando quiser rodar o appserver)
# CMD ["/opt/totvs/appserver/appsrvlinux"]
