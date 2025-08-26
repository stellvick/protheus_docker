FROM totvsengpro/appserver-dev

# Copiar arquivos de configuração
COPY appserver.ini /opt/totvs/appserver/appserver.ini
COPY tttm120.rpo /opt/totvs/protheus/apo/tttm120.rpo
COPY sx2.unq /opt/totvs/protheus/protheus_data/systemload/sx2.unq
COPY sxsbra.txt /opt/totvs/protheus/protheus_data/systemload/sxsbra.txt

# Expor as portas necessárias
EXPOSE 1234 8080 8081 9090

# Health check para verificar se o serviço está respondendo
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

# Comando padrão
CMD ["/opt/totvs/appserver/appserver"]
