FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
    unzip \
    tar \
    gzip \
    libssl1.1 \
    libcurl4 \
    libxml2 \
    libxslt1.1 \
    libpq5 \
    unixodbc \
    && mkdir -p /opt/totvs/appserver \
    && mkdir -p /opt/totvs/protheus/apo \
    && mkdir -p /opt/totvs/protheus/protheus_data/system \
    && mkdir -p /opt/totvs/protheus/protheus_data/systemload

COPY appserver.tar.GZ /tmp/
RUN tar -xzf /tmp/appserver.tar.GZ -C /opt/totvs/ \
    && chmod +x /opt/totvs/appserver/appsrvlinux

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

CMD ["/opt/totvs/appserver/appsrvlinux"]
