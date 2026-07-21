FROM totvsengpro/appserver-dev
USER root
COPY resources/dmidecode /usr/sbin/dmidecode
RUN chmod +x /usr/sbin/dmidecode && ln -sf /usr/sbin/dmidecode /usr/bin/dmidecode
COPY resources/appserver.ini /opt/totvs/appserver/appserver.ini
COPY resources/TTTM120.RPO /opt/totvs/protheus/apo/tttm120.rpo
COPY resources/sx2.unq /opt/totvs/protheus/protheus_data/systemload/sx2.unq
COPY resources/sxsbra.txt /opt/totvs/protheus/protheus_data/systemload/sxsbra.txt

COPY resources/language.ini /opt/totvs/appserver/language.ini
RUN chmod 666 /opt/totvs/appserver/language.ini


