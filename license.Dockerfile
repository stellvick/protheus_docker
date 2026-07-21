FROM totvsengpro/license-dev
USER root
COPY resources/dmidecode /usr/sbin/dmidecode
RUN chmod +x /usr/sbin/dmidecode && ln -sf /usr/sbin/dmidecode /usr/bin/dmidecode
