FROM totvsengpro/appserver-dev

RUN mkdir -p /opt/totvs/appserver \
    && mkdir -p /opt/totvs/protheus/apo \
    && mkdir -p /opt/totvs/protheus/protheus_data/systemload

COPY appserver.ini /opt/totvs/appserver/appserver.ini
COPY tttm120.rpo /opt/totvs/protheus/apo/tttm120.rpo
COPY sx2.unq /opt/totvs/protheus/protheus_data/systemload/sx2.unq
COPY sxsbra.txt /opt/totvs/protheus/protheus_data/systemload/sxsbra.txt
COPY init-appserver.sh /usr/local/bin/init-appserver.sh

RUN chmod +x /usr/local/bin/init-appserver.sh

RUN ls -la /opt/totvs/appserver/appserver.ini \
    && echo "Arquivo appserver.ini copiado com sucesso" \
    && head -n 3 /opt/totvs/appserver/appserver.ini

EXPOSE 1234 8080 8081 9090

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -sSf http://localhost:8080 > /dev/null || exit 1

CMD ["/usr/local/bin/init-appserver.sh"]
