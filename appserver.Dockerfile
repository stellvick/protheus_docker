FROM totvsengpro/appserver-dev
USER root
RUN if [ -x "$(command -v apt-get)" ]; then \
      apt-get update && apt-get install -y dmidecode; \
    elif [ -x "$(command -v yum)" ]; then \
      yum install -y dmidecode; \
    elif [ -x "$(command -v apk)" ]; then \
      apk add --no-cache dmidecode; \
    elif [ -x "$(command -v dnf)" ]; then \
      dnf install -y dmidecode; \
    elif [ -x "$(command -v zypper)" ]; then \
      zypper install -y dmidecode; \
    fi
COPY resources/appserver.ini /opt/totvs/appserver/appserver.ini
COPY resources/TTTM120.RPO /opt/totvs/protheus/apo/tttm120.rpo
COPY resources/sx2.unq /opt/totvs/protheus/protheus_data/systemload/sx2.unq
COPY resources/sxsbra.txt /opt/totvs/protheus/protheus_data/systemload/sxsbra.txt
