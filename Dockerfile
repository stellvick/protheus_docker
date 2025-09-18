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
    net-tools \
    curl \
    && mkdir -p /opt/totvs/appserver \
    && mkdir -p /opt/totvs/protheus/apo \
    && mkdir -p /opt/totvs/protheus/protheus_data/system \
    && mkdir -p /opt/totvs/protheus/protheus_data/systemload

COPY appserver.tar.GZ /opt/totvs/appserver/
COPY appserver.ini /opt/totvs/appserver/
COPY *.rpo /opt/totvs/protheus/apo/
COPY *.unq /opt/totvs/protheus/protheus_data/systemload/
COPY *.txt /opt/totvs/protheus/protheus_data/systemload/
COPY menus/ /opt/totvs/protheus/protheus_data/system/
COPY help/ /opt/totvs/protheus/protheus_data/

RUN cd /opt/totvs/appserver && tar -vzxf appserver.tar.GZ && rm appserver.tar.GZ

RUN echo "Verificando arquivos copiados:" \
    && ls -la /opt/totvs/appserver/ \
    && ls -la /opt/totvs/protheus/apo/ \
    && ls -la /opt/totvs/protheus/protheus_data/system/ \
    && ls -la /opt/totvs/protheus/protheus_data/systemload/

CMD ["/opt/totvs/appserver/appsrvlinux"]
