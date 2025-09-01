FROM totvsengpro/appserver-dev

RUN mkdir -p /opt/totvs/appserver \
    && mkdir -p /opt/totvs/protheus/apo \
    && mkdir -p /opt/totvs/protheus/protheus_data/systemload

COPY appserver.ini /opt/totvs/appserver/
COPY *.rpo /opt/totvs/protheus/apo/
COPY *.unq /opt/totvs/protheus/protheus_data/systemload/
COPY *.txt /opt/totvs/protheus/protheus_data/systemload/

RUN echo "Verificando arquivos copiados:" \
    && ls -la /opt/totvs/appserver/ \
    && ls -la /opt/totvs/protheus/apo/ \
    && ls -la /opt/totvs/protheus/protheus_data/systemload/
