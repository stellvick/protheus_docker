FROM totvsengpro/appserver-dev
COPY resources/appserver.ini /opt/totvs/appserver/appserver.ini
COPY resources/TTTM120.RPO /opt/totvs/protheus/apo/tttm120.rpo
COPY resources/sx2.unq /opt/totvs/protheus/protheus_data/systemload/sx2.unq
COPY resources/sxsbra.txt /opt/totvs/protheus/protheus_data/systemload/sxsbra.txt
