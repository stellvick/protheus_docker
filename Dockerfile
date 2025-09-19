FROM opensuse/leap:15.4
RUN zypper refresh && zypper install -y \
    unixODBC \
    unixODBC-devel \
    postgresql-odbc \
    && mkdir -p /etc \
    && printf "[PostgreSQL]\nDRIVER=PostgreSQL\nSERVERNAME=postgres-iniciado\nPORT=5432\nDATABASE=protheus\nUSERNAME=postgres\nPASSWORD=postgres\n" > /etc/odbc.ini

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
    iputils \
    && mkdir -p /opt/totvs/appserver \
    && mkdir -p /opt/totvs/protheus/apo \
    && mkdir -p /opt/totvs/protheus/protheus_data/system \
    && mkdir -p /opt/totvs/protheus/protheus_data/systemload

COPY dbaccess.tar.GZ /opt/totvs/dbaccess/
RUN cd /opt/totvs/dbaccess && tar -vzxf dbaccess.tar.GZ && rm dbaccess.tar.GZ

COPY appserver.tar.GZ /opt/totvs/appserver/
COPY smart.tar.GZ /opt/totvs/appserver/
COPY appserver.ini /opt/totvs/appserver/
COPY *.rpo /opt/totvs/protheus/apo/
COPY *.unq /opt/totvs/protheus/protheus_data/systemload/
COPY *.txt /opt/totvs/protheus/protheus_data/systemload/
COPY menus/ /opt/totvs/protheus/protheus_data/system/
COPY help/ /opt/totvs/protheus/protheus_data/

RUN cd /opt/totvs/appserver && tar -vzxf appserver.tar.GZ && rm appserver.tar.GZ
RUN cd /opt/totvs/appserver && tar -vzxf smart.tar.GZ && rm smart.tar.GZ

RUN echo "Verificando arquivos copiados:" \
    && ls -la /opt/totvs/appserver/ \
    && ls -la /opt/totvs/protheus/apo/ \
    && ls -la /opt/totvs/protheus/protheus_data/system/ \
    && ls -la /opt/totvs/protheus/protheus_data/systemload/

CMD ["sh", "-c", "/opt/totvs/dbaccess/tools/dbaccesscfg -u postgres -p postgres -a PostgreSQL -d postgres -c '/usr/lib64/libodbc.so' && /opt/totvs/dbaccess/multi/dbaccess64 && /opt/totvs/appserver/appsrvlinux && tail -f /opt/totvs/appserver/console.log"]
