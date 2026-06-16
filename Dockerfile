FROM opensuse/leap:15.4

RUN zypper refresh && \
    zypper install -y \
    curl \
    net-tools \
    iputils \
    timezone \
    unixODBC \
    postgresql-odbc && \
    zypper clean -a

ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN mkdir -p /etc/unixODBC /tmp/protheus

COPY advpl_config/odbc.ini /etc/unixODBC/odbc.ini
COPY advpl_config/odbcinst.ini /etc/unixODBC/odbcinst.ini
RUN chmod 644 /etc/unixODBC/odbc.ini && \
    chmod 644 /etc/unixODBC/odbcinst.ini

COPY scripts/setup-config.sh /usr/local/bin/setup-config.sh
RUN chmod +x /usr/local/bin/setup-config.sh

ENV ODBCINI=/etc/unixODBC/odbc.ini
ENV ODBCSYSINI=/etc/unixODBC
ENV LD_LIBRARY_PATH=/usr/lib64:$LD_LIBRARY_PATH

WORKDIR /app

CMD ["/bin/bash", "-c", "/usr/local/bin/setup-config.sh && exec tail -f /dev/null"]
