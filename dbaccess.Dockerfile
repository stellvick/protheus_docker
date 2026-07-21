FROM totvsengpro/dbaccess-postgres-dev
USER root
COPY resources/dmidecode /usr/sbin/dmidecode
RUN chmod +x /usr/sbin/dmidecode && ln -sf /usr/sbin/dmidecode /usr/bin/dmidecode
COPY resources/dbaccess.ini /opt/totvs/dbaccess/multi/dbaccess.ini
