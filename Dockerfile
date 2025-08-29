FROM totvsengpro/appserver-dev

RUN mkdir -p /opt/totvs/appserver \
    && mkdir -p /opt/totvs/protheus/apo \
    && mkdir -p /opt/totvs/protheus/protheus_data/systemload

COPY appserver.ini /opt/totvs/appserver/
COPY init-appserver.sh /usr/local/bin/
COPY *.rpo /opt/totvs/protheus/apo/
COPY *.unq /opt/totvs/protheus/protheus_data/systemload/
COPY *.txt /opt/totvs/protheus/protheus_data/systemload/

RUN chmod +x /usr/local/bin/init-appserver.sh

RUN echo "Verificando arquivos copiados:" \
    && ls -la /opt/totvs/appserver/ \
    && ls -la /opt/totvs/protheus/apo/ \
    && ls -la /opt/totvs/protheus/protheus_data/systemload/

EXPOSE 1234 8080 8081 9090

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -sSf http://localhost:8080 > /dev/null || exit 1

CMD ["/usr/local/bin/init-appserver.sh"]
