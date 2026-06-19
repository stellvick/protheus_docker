FROM totvsengpro/postgres-dev:12.1.2210_bra
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
