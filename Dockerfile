FROM registry.redhat.io/ubi9/ubi:latest

RUN dnf update -y && dnf install -y \
    unzip \
    tar \
    gzip \
    openssl-libs \
    libcurl \
    libxml2 \
    libxslt \
    postgresql-libs \
    unixODBC \
    && mkdir -p /opt/totvs/appserver \
    && mkdir -p /opt/totvs/protheus/apo \
    && mkdir -p /opt/totvs/protheus/protheus_data/system \
    && mkdir -p /opt/totvs/protheus/protheus_data/systemload

COPY appserver.tar.GZ /tmp/

COPY appserver.ini /opt/totvs/appserver/
COPY *.rpo /opt/totvs/protheus/apo/
COPY *.unq /opt/totvs/protheus/protheus_data/systemload/
COPY *.txt /opt/totvs/protheus/protheus_data/systemload/
COPY menus/ /opt/totvs/protheus/protheus_data/system/
COPY help.ZIP /tmp/

RUN cd /tmp && unzip help.ZIP && cp *.txt /opt/totvs/protheus/protheus_data/systemload/ \
    && echo "Verificando arquivos copiados:" \
    && ls -la /opt/totvs/appserver/ \
    && ls -la /opt/totvs/protheus/apo/ \
    && ls -la /opt/totvs/protheus/protheus_data/system/ \
    && ls -la /opt/totvs/protheus/protheus_data/systemload/

# CMD ["/opt/totvs/appserver/appsrvlinux"]
